open Import

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

let parse (type a) (kind : a Ml_binary.kind) : _ -> Ast_io.Intf_or_impl.t =
  match kind with
  | Ml_binary.Ml ->
      fun impl -> Ast_io.Intf_or_impl.Impl (Parse.implementation impl)
  | Ml_binary.Mli -> fun intf -> Ast_io.Intf_or_impl.Intf (Parse.interface intf)

(* [filename] is the real file name, e.g. before pre-processing. *)
let file_aux ~filename inputfile (parse_fun : _ -> Ast_io.Intf_or_impl.t) =
  let { Ast_io.ast; _ } =
    Ast_io.read_exn (File inputfile)
      ~input_kind:(Possibly_source { filename; parse_fun })
  in
  ast

let parse_file (type a) (kind : a Ml_binary.kind) (sourcefile : string) : a =
  Location.set_input_name sourcefile;
  let inputfile = preprocess sourcefile in
  let ast =
    try file_aux ~filename:sourcefile inputfile (parse kind)
    with exn ->
      remove_preprocessed inputfile;
      raise exn
  in
  remove_preprocessed inputfile;
  match (kind, ast) with
  | Ml, Impl ast ->
      let ast : Parsetree.structure = Obj.magic ast in
      ast
  | Mli, Intf ast ->
      let ast : Parsetree.signature = Obj.magic ast in
      ast
  | _ -> assert false

let parse_implementation sourcefile = parse_file Ml sourcefile
let parse_interface sourcefile = parse_file Mli sourcefile
