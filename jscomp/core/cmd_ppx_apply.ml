open Import

(* Note: some of the functions here should go to Ast_mapper instead,
   which would encapsulate the "binary AST" protocol. *)

let write_ast (type a) (kind : a Ml_binary.kind) fn (ast : a) =
  let oc = open_out_bin fn in
  output_string oc (Ml_binary.magic_of_kind kind);
  output_value oc (!Location.input_name : string);
  output_value oc (ast : a);
  close_out oc

let temp_ppx_file () =
  Filename.temp_file "ppx" (Filename.basename !Location.input_name)

let apply_rewriter fn_in ppx =
  let fn_out = temp_ppx_file () in
  let comm =
    Printf.sprintf "%s %s %s" ppx (Filename.quote fn_in) (Filename.quote fn_out)
  in
  let ok = Ccomp.command comm = 0 in
  if not ok then Cmd_ast_exception.cannot_run comm;
  if not (Sys.file_exists fn_out) then Cmd_ast_exception.cannot_run comm;
  fn_out

let read_ast (type a) (kind : a Ml_binary.kind) fn : a =
  let { Ast_io.ast; _ } =
    Ast_io.read_exn (File fn) ~input_kind:Necessarily_binary
  in
  match (kind, ast) with
  | Ml, Impl ast -> ast
  | Mli, Intf ast -> ast
  | _ -> assert false

(** [ppxs] are a stack,
    [-ppx1 -ppx2  -ppx3]
    are stored as [-ppx3; -ppx2; -ppx1]
    [fold_right] happens to process the first one *)
let rewrite kind ppxs ast =
  let fn_in = temp_ppx_file () in
  write_ast kind fn_in ast;
  let temp_files =
    List.fold_right
      ~f:(fun ppx fns ->
        match fns with
        | [] -> assert false
        | fn_in :: _ -> apply_rewriter fn_in ppx :: fns)
      ppxs ~init:[ fn_in ]
  in
  match temp_files with
  | last_fn :: _ ->
      let out = read_ast kind last_fn in
      List.iter ~f:Misc.remove_file temp_files;
      out
  | _ -> assert false

let apply_rewriters_str ?(restore = true) ~tool_name ast =
  match !Clflags.all_ppx with
  | [] -> ast
  | ppxs ->
      ast
      |> Ast_mapper.add_ppx_context_str ~tool_name
      |> rewrite Ml ppxs
      |> Ast_mapper.drop_ppx_context_str ~restore

let apply_rewriters_sig ?(restore = true) ~tool_name ast =
  match !Clflags.all_ppx with
  | [] -> ast
  | ppxs ->
      ast
      |> Ast_mapper.add_ppx_context_sig ~tool_name
      |> rewrite Mli ppxs
      |> Ast_mapper.drop_ppx_context_sig ~restore

let apply_rewriters ?restore ~tool_name (type a) (kind : a Ml_binary.kind)
    (ast : a) : a =
  match kind with
  | Ml_binary.Ml -> apply_rewriters_str ?restore ~tool_name ast
  | Ml_binary.Mli -> apply_rewriters_sig ?restore ~tool_name ast
