let if_o ~f o = match o with None -> [] | Some v -> [ f v ]

let assets_in_structure_item (str : Parsetree.structure_item) =
  match str.pstr_desc with
  | Pstr_primitive prim
    when Ast_attributes.rs_externals prim.pval_attributes prim.pval_prim -> (
      let { Parsetree.pval_type; pval_attributes; pval_loc = loc; _ } = prim in
      match prim.pval_prim with
      | [] -> Location.raise_errorf ~loc "empty primitive string"
      | a :: b :: _ ->
          Location.raise_errorf ~loc
            "only a single string is allowed in bs external %S : %S" a b
      | [ v ] ->
          let pval_name = prim.pval_name.txt and prim_name = v in
          let prim_name_or_pval_name =
            if String.length prim_name = 0 then `Nm_val (lazy pval_name)
            else `Nm_external prim_name
          in
          let _result_type, arg_types_ty =
            Ast_core_type.list_of_arrow pval_type
          in
          let no_arguments = arg_types_ty = [] in
          let _unused_attrs, external_desc =
            Ast_external_process.parse_external_attributes no_arguments
              prim_name prim_name_or_pval_name pval_attributes
          in
          let bundle { External_ffi_types.bundle; module_bind_name = _ } =
            bundle
          in
          [
            if_o external_desc.external_module_name ~f:bundle;
            if_o external_desc.module_as_val ~f:bundle;
          ]
          |> List.concat
          (* Filename.is_relative "foo" returns true *)
          |> List.filter (String.starts_with ~prefix:"."))
  | _ -> []

let handle_structure stru = List.concat_map assets_in_structure_item stru

let process_file sourcefile =
  let kind =
    Ext_file_extensions.classify_input
      (Ext_filename.get_extension_maybe sourcefile)
  in
  match kind with
  | Ml | Impl_ast ->
      let stru = Pparse_driver.parse_implementation sourcefile in
      let (assets : _ list) = handle_structure stru in
      Csexp.List
        [ Atom sourcefile; List (List.map (fun x -> Csexp.Atom x) assets) ]
  | Mli ->
      let _sig_ = Pparse_driver.parse_interface sourcefile in
      Csexp.List []
  | Intf_ast | Mlmap | Cmi | Cmj | Unknown ->
      raise (Arg.Bad ("don't know what to do with " ^ sourcefile))

module Cli = struct
  open Cmdliner

  let filenames =
    let docv = "filename" in
    Arg.(value & pos_all string [] & info [] ~docv)

  let main filenames =
    let impl = match filenames with [ impl ] -> impl | _ -> assert false in
    let csexp = process_file impl in
    Format.printf "%s" (Csexp.to_string csexp)

  let cmd =
    let term = Term.(const main $ filenames) in
    let info = Cmd.info "melassets" in
    Cmd.v info term

  let () =
    let argv = Ext_cli_args.normalize_argv Sys.argv in
    exit (Cmdliner.Cmd.eval ~argv cmd)
end
