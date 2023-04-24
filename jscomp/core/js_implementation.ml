(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 2002 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* adapted by rescript from [driver/compile.ml] for convenience    *)

let module_of_filename outputprefix =
  let basename = Filename.basename outputprefix in
  let name =
    try
      let pos = String.index basename '.' in
      String.sub basename 0 pos
    with Not_found -> basename
  in
  String.capitalize_ascii name

let fprintf = Format.fprintf

let print_if_pipe ppf flag printer arg =
  if !flag then fprintf ppf "%a@." printer arg;
  arg

let print_if ppf flag printer arg = if !flag then fprintf ppf "%a@." printer arg

let output_deps_set name set =
  output_string stdout name;
  output_string stdout ": ";
  Depend.String.Set.iter
    (fun s ->
      if s <> "" && s.[0] <> '*' then (
        output_string stdout s;
        output_string stdout " "))
    set;
  output_string stdout "\n"

let process_with_gentype filename =
  match !Bs_clflags.bs_gentype with
  | None -> ()
  | Some cmd ->
      let comm =
        cmd ^ " -bs-version " ^ Melange_version.version ^ " -cmt-add "
        ^ filename ^ ":" ^ !Location.input_name
      in
      if !Clflags.verbose then (
        prerr_string "+ ";
        prerr_endline comm;
        prerr_newline ());
      ignore (Sys.command comm)

let after_parsing_sig ppf outputprefix ast =
  Ast_config.iter_on_bs_config_sigi ast;
  if !Js_config.modules then
    output_deps_set !Location.input_name
      (Ast_extract.read_parse_and_extract Mli ast);
  if !Js_config.as_pp then (
    output_string stdout Config.ast_intf_magic_number;
    output_value stdout (!Location.input_name : string);
    output_value stdout ast);
  if !Js_config.syntax_only then Warnings.check_fatal ()
  else
    let modulename = module_of_filename outputprefix in
    Lam_compile_env.reset ();
    let initial_env = Res_compmisc.initial_env () in
    Env.set_unit_name modulename;

    let tsg = Typemod.type_interface initial_env ast in
    if !Clflags.dump_typedtree then fprintf ppf "%a@." Printtyped.interface tsg;
    let sg = tsg.sig_type in
    if !Clflags.print_types then
      Printtyp.wrap_printing_env ~error:false initial_env (fun () ->
          Format.(fprintf std_formatter)
            "%a@."
            (Printtyp.printed_signature !Location.input_name)
            sg);
    ignore (Includemod.signatures initial_env ~mark:Mark_both sg sg);
    Typecore.force_delayed_checks ();
    Warnings.check_fatal ();
    if not !Clflags.print_types then (
      let sg =
        let alerts = Builtin_attributes.alerts_of_sig ast in
        Env.save_signature ~alerts tsg.Typedtree.sig_type modulename
          (outputprefix ^ ".cmi")
      in
      Typemod.save_signature modulename tsg outputprefix !Location.input_name
        initial_env sg;
      process_with_gentype (outputprefix ^ ".cmti"))

let interface ~parser ppf fname =
  Res_compmisc.init_path ();
  parser fname |> Ast_deriving_compat.signature
  |> Cmd_ppx_apply.apply_rewriters ~restore:false ~tool_name:Js_config.tool_name
       Mli
  |> Melange_ppx_lib.Ppx_entry.rewrite_signature
  |> print_if_pipe ppf Clflags.dump_parsetree Printast.interface
  |> print_if_pipe ppf Clflags.dump_source Pprintast.signature
  |> after_parsing_sig ppf (Config_util.output_prefix fname)

let all_module_alias (ast : Parsetree.structure) =
  Ext_list.for_all ast (fun { pstr_desc } ->
      match pstr_desc with
      | Pstr_module { pmb_expr = { pmod_desc = Pmod_ident _ } } -> true
      | Pstr_attribute _ -> true
      | Pstr_eval _ | Pstr_value _ | Pstr_primitive _ | Pstr_type _
      | Pstr_typext _ | Pstr_exception _ | Pstr_module _ | Pstr_recmodule _
      | Pstr_modtype _ | Pstr_open _ | Pstr_class _ | Pstr_class_type _
      | Pstr_include _ | Pstr_extension _ ->
          false)

let no_export (rest : Parsetree.structure) : Parsetree.structure =
  match rest with
  | head :: _ ->
      let loc = head.pstr_loc in
      Ast_helper.
        [
          Str.include_ ~loc
            (Incl.mk ~loc
               (Mod.constraint_ ~loc (Mod.structure ~loc rest)
                  (Mty.signature ~loc [])));
        ]
  | _ -> rest

let after_parsing_impl ppf fname (ast : Parsetree.structure) =
  let outputprefix = Config_util.output_prefix fname in
  let sourceintf = Filename.remove_extension fname ^ !Config.interface_suffix in
  Js_config.all_module_aliases :=
    (not (Sys.file_exists sourceintf)) && all_module_alias ast;
  Ast_config.iter_on_bs_config_stru ast;
  let ast = if !Js_config.no_export then no_export ast else ast in
  if !Js_config.modules then
    output_deps_set !Location.input_name
      (Ast_extract.read_parse_and_extract Ml ast);
  if !Js_config.as_pp then (
    output_string stdout Config.ast_impl_magic_number;
    output_value stdout (!Location.input_name : string);
    output_value stdout ast);
  if !Js_config.syntax_only then Warnings.check_fatal ()
  else
    let modulename = Ext_filename.module_name outputprefix in
    Lam_compile_env.reset ();
    let env = Res_compmisc.initial_env () in
    Env.set_unit_name modulename;
    let ({ Typedtree.structure = typedtree; coercion; _ } as implementation), _
        =
      Typemod.type_implementation_more
        ?check_exists:(if !Js_config.force_cmi then None else Some ())
        fname outputprefix modulename env ast
    in
    let typedtree_coercion = (typedtree, coercion) in
    print_if ppf Clflags.dump_typedtree Printtyped.implementation_with_coercion
      implementation;
    (if !Clflags.print_types || !Js_config.cmi_only then Warnings.check_fatal ()
     else
       let lambda =
         Translmod.transl_implementation modulename typedtree_coercion
       in
       let js_program =
         print_if_pipe ppf Clflags.dump_rawlambda Printlambda.lambda lambda.code
         |> Lam_compile_main.compile outputprefix
       in
       if not !Js_config.cmj_only then
         (* XXX(anmonteiro): important that we get package_info after
            processing, as `[@@@config {flags = [| ... |]}]` could have added to
            package specs. *)
         let package_info = Js_packages_state.get_packages_info () in
         Lam_compile_main.lambda_as_module ~package_info js_program outputprefix);
    process_with_gentype (outputprefix ^ ".cmt")

let implementation ~parser ppf fname =
  Res_compmisc.init_path ();
  parser fname |> Ast_deriving_compat.structure
  |> Cmd_ppx_apply.apply_rewriters ~restore:false ~tool_name:Js_config.tool_name
       Ml
  |> Melange_ppx_lib.Ppx_entry.rewrite_implementation
  |> print_if_pipe ppf Clflags.dump_parsetree Printast.implementation
  |> print_if_pipe ppf Clflags.dump_source Pprintast.structure
  |> after_parsing_impl ppf fname

let implementation_cmj _ppf fname =
  (* this is needed because the path is used to find other modules path *)
  Res_compmisc.init_path ();
  let cmj = Js_cmj_format.from_file fname in
  (* NOTE(anmonteiro): If we're generating JS from a `.cmj`, we take the
     resulting JS extension from the `-o FILENAME.EXT1.EXT2` argument. In this
     case, we need to make sure we're removing all the extensions from the
     output prefix. *)
  let output_prefix =
    match !Clflags.output_name with
    | None -> Filename.remove_extension fname
    | Some oname -> Ext_filename.chop_all_extensions_maybe oname
  in
  Lam_compile_main.lambda_as_module ~package_info:cmj.package_spec
    cmj.delayed_program output_prefix
