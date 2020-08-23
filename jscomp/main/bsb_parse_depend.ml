let input_lines =
  let rec loop ic acc =
    match input_line ic with
    | exception End_of_file -> List.rev acc
    | line -> loop ic (line :: acc)
  in
  fun ic -> loop ic []

let split2 s ~sep =
  match String.index_opt s sep with
  | None -> None
  | Some i ->
    Some (String.sub s 0 i, String.sub s (i + 1) (String.length s - i - 1))

let extract_words s ~is_word_char =
  let rec skip_blanks i =
    if i = String.length s then
      []
    else if is_word_char s.[i] then
      parse_word i (i + 1)
    else
      skip_blanks (i + 1)
  and parse_word i j =
    if j = String.length s then
      [ String.sub s i (j - i) ]
    else if is_word_char s.[j] then
      parse_word i (j + 1)
    else
      String.sub s i (j - i) :: skip_blanks (j + 1)
  in
  skip_blanks 0

let extract_blank_separated_words s =
  extract_words s ~is_word_char:(function
    | ' '
    | '\t' ->
      false
    | _ -> true)

let parse_deps_exn ~file lines =
  match lines with
  | [] -> []
  | line :: _ ->
    match split2 line ~sep:':' with
    | None -> assert false
    | Some (basename, deps) ->
      extract_blank_separated_words deps

let parse_depends ~hash files =
 let buf = Buffer.create 1024 in
 Ext_list.iter files (fun file ->
  let chan = open_in_bin file in
  let deps = parse_deps_exn ~file (input_lines chan) in
  close_in chan;
  Buffer.add_string buf "\n(rule (targets ";
  Buffer.add_string buf (Ext_filename.new_extension file Literals.suffix_depends);
  Buffer.add_string buf ")\n (action (write-file %{targets} ";
  Buffer.add_string buf hash;
  Buffer.add_string buf "))\n ";
  if deps <> [] then begin
  Buffer.add_string buf "(deps";
    Ext_list.iter deps (fun dep ->
      Buffer.add_string buf Ext_string.single_space;
      Buffer.add_string buf dep);
    Buffer.add_string buf ")"
  end;
  Buffer.add_string buf ")\n");
 Bsb_ninja_targets.revise_dune Literals.dune_bsb_inc buf

let () =
  let argv = Sys.argv in
  let l = Array.length argv in
  let current = ref 1 in
  let hash = ref None in
  let rev_list = ref [] in
  while !current < l do
    let s = argv.(!current) in
    incr current;
    if s <> "" && s.[0] = '-' then begin
      match s with
      | "-help" ->
        prerr_endline ("usage: bsb_parse_depend.exe [-help] file1 file2 ...");
        exit 0
      | "-hash" ->
        hash := Some (argv.(!current));
        incr current
      | s ->
        prerr_endline ("unknown option: " ^ s);
        prerr_endline ("usage: bsb_parse_depend.exe [-help] file1 file2 ...");
        exit 2
    end else
      rev_list := s :: !rev_list
  done;
  match !hash with
  | None ->
    prerr_endline "-hash is a required option";
    exit 2
  | Some hash ->
    parse_depends ~hash !rev_list
;;

