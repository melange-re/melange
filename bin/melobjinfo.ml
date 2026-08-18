open Cmdliner
open Melangelib

type dependencies = {
  ml : string list;
  runtime : string list;
  external_ : string list;
}

let dependencies (cmj : Js_cmj_format.t) =
  List.fold_right
    (fun (module_id : J.module_id) dependencies ->
      let name = Lam_module_ident.name module_id in
      match module_id.kind with
      | Ml -> { dependencies with ml = name :: dependencies.ml }
      | Runtime -> { dependencies with runtime = name :: dependencies.runtime }
      | External _ ->
          { dependencies with external_ = name :: dependencies.external_ })
    cmj.delayed_program.modules
    { ml = []; runtime = []; external_ = [] }

let print_names heading names =
  match names with
  | [] -> ()
  | _ ->
      Printf.printf "%s:\n" heading;
      List.iter (Printf.printf "  %s\n") names

(* CMJs do not store dependency digests. Dashes keep this compatible with the
   implementation-import rows printed by ocamlobjinfo. *)
let print_implementation name =
  Printf.printf "  --------------------------------  %s\n" name

let print_file file =
  let cmj = Js_cmj_format.from_file file in
  let { ml; runtime; external_ } = dependencies cmj in
  Printf.printf "File %s\n" file;
  print_names "Runtime modules imported" runtime;
  print_names "JavaScript modules imported" external_;
  Printf.printf "Implementations imported:\n";
  List.iter print_implementation ml

let run files =
  match files with
  | [] -> `Error (true, "at least one CMJ file is required")
  | _ -> (
      try
        List.iter print_file files;
        `Ok ()
      with exn -> `Error (false, Printexc.to_string exn))

let files =
  let doc = "CMJ files to inspect." in
  Arg.(value & pos_all file [] & info [] ~doc ~docv:"CMJ")

let cmd =
  let doc = "print information about Melange CMJ files" in
  Cmd.v (Cmd.info "melobjinfo" ~doc) Term.(ret (const run $ files))

let () = exit (Cmd.eval cmd)
