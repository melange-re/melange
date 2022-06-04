let (//) = Filename.concat

(** may nonterminate when [cwd] is '.' *)
let rec unsafe_root_dir_aux cwd  =
  if Sys.file_exists (cwd//Literals.bsconfig_json) then cwd
  else unsafe_root_dir_aux (Filename.dirname cwd)

let project_root = unsafe_root_dir_aux (Sys.getcwd ())
let jscomp = project_root // "jscomp"


let bsc_exe = jscomp // "main" // "melc.exe"
let runtime_dir = jscomp // "runtime"
let others_dir = jscomp // "others"


let stdlib_dir = jscomp // "stdlib-412"

(* let rec safe_dup fd =
  let new_fd = Unix.dup fd in
  if (Obj.magic new_fd : int) >= 3 then
    new_fd (* [dup] can not be 0, 1, 2*)
  else begin
    let res = safe_dup fd in
    Unix.close new_fd;
    res
  end *)

let safe_close fd =
  try Unix.close fd with Unix.Unix_error(_,_,_) -> ()


type output = {
  stderr : string ;
  stdout : string ;
  exit_code : int
}

let read_fd_until_eof fd =
  let buf = Buffer.create 1024 in
  let chan = Unix.in_channel_of_descr fd in
  (try
    while true do
      Buffer.add_string buf (input_line chan);
      Buffer.add_char buf '\n'
    done;
  with
    End_of_file -> ());
  Buffer.contents buf

let perform command args =
  let in_fd_read, in_fd_write = Unix.pipe () in
  let out_fd_read, out_fd_write = Unix.pipe () in
  let err_fd_read, err_fd_write = Unix.pipe () in

  let pid =
    Unix.create_process
      command
      args
      in_fd_read
      out_fd_write
      err_fd_write in
  safe_close in_fd_write;
  (* when all the descriptors on a pipe's input are closed and the pipe is
        empty, a call to [read] on its output returns zero: end of file.
        when all the descriptiors on a pipe's output are closed, a call to
        [write] on its input kills the writing process (EPIPE).
    *)
  safe_close out_fd_write;
  safe_close err_fd_write;
  let stdout = read_fd_until_eof out_fd_read in
  let stderr = read_fd_until_eof err_fd_read in
  let exit_code =
    match snd @@ Unix.waitpid [] pid with
    | Unix.WEXITED exit_code -> exit_code
    | Unix.WSIGNALED _signal_number
    | Unix.WSTOPPED _signal_number  -> 127 in
  { stdout; stderr; exit_code }


let perform_bsc args =
  perform bsc_exe
    (Array.append
       [|bsc_exe ;
         "-bs-package-name" ; "melange";
         "-bs-no-version-header";
         "-bs-cross-module-opt";
         "-w";
         "-40";
         "-I" ;
         runtime_dir ;
         "-I";
         others_dir ;
         "-I" ;
         stdlib_dir
       |] args)

let bsc_check_eval str =
  perform_bsc [|"-bs-eval"; str|]

  let debug_output o =
  Printf.printf "\nexit_code:%d\nstdout:%s\nstderr:%s\n"
    o.exit_code o.stdout o.stderr
