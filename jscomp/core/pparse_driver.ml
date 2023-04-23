module Ast_io = struct
  module Ast = Ppxlib_ast.Ast

  module Ast_io = struct
    module Compiler_version = Ppxlib_ast.Compiler_version

    module type OCaml_version = Ppxlib_ast.OCaml_version

    type input_version = (module OCaml_version)

    let fall_back_input_version = (module Compiler_version : OCaml_version)
    (* This should only be used when the input version can't be determined due to
        loading or preprocessing errors *)

    type 'a t = {
      input_name : string;
      input_version : input_version;
      kind : 'a Ml_binary.kind;
      ast : 'a;
    }

    type read_error =
      | Not_a_binary_ast
      | Unknown_version of string * input_version
      | Source_parse_error of Ppxlib_ast.Location_error.t * input_version
      | System_error of Ppxlib_ast.Location_error.t * input_version

    type input_source = Stdin | File of string

    type 'a input_kind =
      | Possibly_source of {
          filename : string;
          kind : 'a Ml_binary.kind;
          parse_fun : Lexing.lexbuf -> 'a;
        }
      | Necessarily_binary

    let read_error_to_string (error : read_error) =
      match error with
      | Not_a_binary_ast -> "Error: Not a binary ast"
      | Unknown_version (s, _) -> "Error: Unknown version " ^ s
      | Source_parse_error (loc, _) ->
          "Source parse error:" ^ Ppxlib_ast.Location_error.message loc
      | System_error (loc, _) ->
          "System error: " ^ Ppxlib_ast.Location_error.message loc

    let magic_length = String.length Astlib.Config.ast_impl_magic_number

    let read_magic ic =
      let buf = Bytes.create magic_length in
      let len = input ic buf 0 magic_length in
      let s = Bytes.sub_string buf 0 len in
      if len = magic_length then Ok s else Error s

    let from_channel (type a) ch ~(kind : a Ml_binary.kind)
        ~(input_kind : a input_kind) : (a t, read_error) result =
      let input_version = (module Compiler_version : OCaml_version) in
      let module Convert = Ppxlib_ast.Convert in
      let module Find_version = Ppxlib_ast__.Versions.Find_version in
      let module Js = Ppxlib_ast__.Import.Js in
      let handle_non_binary () =
        match input_kind with
        | Possibly_source { kind = _; filename; parse_fun } ->
            seek_in ch 0;
            let lexbuf = Lexing.from_channel ch in
            Location.init lexbuf filename;
            let ast = parse_fun lexbuf in
            Ok { input_name = filename; input_version; ast; kind }
        | Necessarily_binary -> Error Not_a_binary_ast
      in
      match read_magic ch with
      | Error _ -> handle_non_binary ()
      | Ok s -> (
          match Find_version.from_magic s with
          | Intf (module Input_version : OCaml_version) -> (
              let input_name : string = input_value ch in
              Location.set_input_name input_name;
              let ast = input_value ch in
              let module Input_to_ppxlib = Convert (Input_version) (Js) in
              match kind with
              | Mli ->
                  Ok
                    {
                      input_name;
                      input_version = (module Input_version : OCaml_version);
                      ast =
                        Input_to_ppxlib.copy_signature ast
                        |> Melange_ppxlib_ast.Of_ppxlib.copy_signature;
                      kind;
                    }
              | Ml -> assert false)
          | Impl (module Input_version : OCaml_version) -> (
              let input_name : string = input_value ch in
              Location.set_input_name input_name;
              let ast = input_value ch in
              let module Input_to_ppxlib = Convert (Input_version) (Js) in
              match kind with
              | Ml ->
                  Ok
                    {
                      input_name;
                      input_version = (module Input_version : OCaml_version);
                      ast =
                        Input_to_ppxlib.copy_structure ast
                        |> Melange_ppxlib_ast.Of_ppxlib.copy_structure;
                      kind;
                    }
              | Mli -> assert false)
          | Unknown ->
              if
                String.equal (String.sub s 0 9)
                  (String.sub Astlib.Config.ast_impl_magic_number 0 9)
                || String.equal (String.sub s 0 9)
                     (String.sub Astlib.Config.ast_intf_magic_number 0 9)
              then Error (Unknown_version (s, fall_back_input_version))
              else handle_non_binary ())

    let read :
        type a.
        input_source ->
        kind:a Ml_binary.kind ->
        input_kind:a input_kind ->
        (a t, read_error) result =
     fun input_source ~kind ~input_kind ->
      try
        match input_source with
        | Stdin -> from_channel stdin ~kind ~input_kind
        | File fn ->
            Stdppx.In_channel.with_file fn ~f:(from_channel ~kind ~input_kind)
      with exn -> (
        match Ppxlib_ast.Location_error.of_exn exn with
        | None -> raise exn
        | Some error -> Error (System_error (error, fall_back_input_version)))
  end

  include Ast_io
end

(* Optionally preprocess a source file *)

let call_external_preprocessor sourcefile pp =
  let tmpfile = Filename.temp_file "ocamlpp" "" in
  let comm =
    Printf.sprintf "%s %s > %s" pp (Filename.quote sourcefile) tmpfile
  in
  if Ccomp.command comm <> 0 then (
    Misc.remove_file tmpfile;
    Cmd_ast_exception.cannot_run comm);
  tmpfile

let preprocess sourcefile =
  match !Clflags.preprocessor with
  | None -> sourcefile
  | Some pp -> call_external_preprocessor sourcefile pp

let remove_preprocessed inputfile =
  if !Clflags.preprocessor <> None then Misc.remove_file inputfile

(* Parse a file or get a dumped syntax tree from it *)

let parse (type a) (kind : a Ml_binary.kind) : _ -> a =
  match kind with
  | Ml_binary.Ml -> Parse.implementation
  | Ml_binary.Mli -> Parse.interface

(* [filename] is the real file name, e.g. before pre-processing. *)
let file_aux ~filename inputfile (type a) (parse_fun : _ -> a)
    (kind : a Ml_binary.kind) : a =
  match
    Ast_io.read (File inputfile) ~kind
      ~input_kind:(Possibly_source { kind; filename; parse_fun })
  with
  | Ok impl_or_intf -> impl_or_intf.ast
  | Error e -> raise (Arg.Bad (Ast_io.read_error_to_string e))

let parse_file (type a) (kind : a Ml_binary.kind) (sourcefile : string) : a =
  Location.set_input_name sourcefile;
  let inputfile = preprocess sourcefile in
  let ast =
    try file_aux ~filename:sourcefile inputfile (parse kind) kind
    with exn ->
      remove_preprocessed inputfile;
      raise exn
  in
  remove_preprocessed inputfile;
  ast

let parse_implementation sourcefile = parse_file Ml sourcefile
let parse_interface sourcefile = parse_file Mli sourcefile
