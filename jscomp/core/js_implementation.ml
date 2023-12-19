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

open Import

(* adapted by rescript from [driver/compile.ml] for convenience    *)

module Ppx_entry = struct
  let rewrite_signature (ast : Parsetree.signature) : Parsetree.signature =
    Ast_config.iter_on_mel_config_sigi ast;
    Mel_ast_invariant.emit_external_warnings_on_signature ast;
    ast

  let rewrite_implementation (ast : Parsetree.structure) : Parsetree.structure =
    Ast_config.iter_on_mel_config_stru ast;
    let ast = Melange_ffi.Utf8_string.rewrite_structure ast in
    Mel_ast_invariant.emit_external_warnings_on_structure ast;
    ast
end

(** TODO: improve efficiency
   given a path, calculate its module name
   Note that `ocamlc.opt -c aa.xx.mli` gives `aa.xx.cmi`
   we can not strip all extensions, otherwise
   we can not tell the difference between "x.cpp.ml"
   and "x.ml"
*)
let module_name =
  let capitalize_sub s len =
    let sub = Bytes.sub (Bytes.unsafe_of_string s) 0 len in
    if Bytes.length sub < 0 then invalid_arg "capitalize_sub"
    else (
      Bytes.set sub 0 (Char.uppercase_ascii (Bytes.get sub 0));
      Bytes.unsafe_to_string sub)
  in
  fun name ->
    let rec search_dot i name =
      if i < 0 then String.capitalize_ascii name
      else if String.unsafe_get name i = '.' then capitalize_sub name i
      else search_dot (i - 1) name
    in
    let name = Filename.basename name in
    let name_len = String.length name in
    search_dot (name_len - 1) name

let print_if_pipe ppf flag printer arg =
  if !flag then Format.fprintf ppf "%a@." printer arg;
  arg

let print_if ppf flag printer arg =
  if !flag then Format.fprintf ppf "%a@." printer arg

(*
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
*)

let after_parsing_sig ppf outputprefix ast =
  if !Js_config.modules then Meldep.output_deps_set !Location.input_name Mli ast;
  if !Js_config.as_pp then (
    output_string stdout Config.ast_intf_magic_number;
    output_value stdout (!Location.input_name : string);
    output_value stdout ast);
  if !Js_config.syntax_only then Warnings.check_fatal ()
  else
    let modulename = module_name outputprefix in
    Lam_compile_env.reset ();
    let initial_env = Initialization.Perfile.initial_env () in
    Env.set_unit_name modulename;

    let tsg = Typemod.type_interface initial_env ast in
    if !Clflags.dump_typedtree then
      Format.fprintf ppf "%a@." Printtyped.interface tsg;
    let sg = tsg.sig_type in
    if !Clflags.print_types then
      Printtyp.wrap_printing_env ~error:false initial_env (fun () ->
          Format.fprintf Format.std_formatter "%a@."
            (Printtyp.printed_signature !Location.input_name)
            sg);
    ignore (Includemod.signatures initial_env ~mark:Mark_both sg sg);
    Typecore.force_delayed_checks ();
    Warnings.check_fatal ();
    if not !Clflags.print_types then
      let sg =
        let alerts = Builtin_attributes.alerts_of_sig ast in
        Env.save_signature ~alerts tsg.Typedtree.sig_type modulename
          (Artifact_extension.append_extension outputprefix Cmi)
      in
      Typemod.save_signature modulename tsg outputprefix !Location.input_name
        initial_env sg
(* process_with_gentype *)
(* (Artifact_extension.append_extension outputprefix Cmti) *)

let output_prefix ?(f = Filename.remove_extension) name =
  match !Clflags.output_name with
  | None -> Filename.remove_extension name
  | Some oname -> f oname

let interface ~parser ppf fname =
  Initialization.Perfile.init_path ();
  parser fname
  |> Cmd_ppx_apply.apply_rewriters ~restore:false ~tool_name:Js_config.tool_name
       Mli
  |> Ppx_entry.rewrite_signature
  |> print_if_pipe ppf Clflags.dump_parsetree Printast.interface
  |> print_if_pipe ppf Clflags.dump_source Pprintast.signature
  |> after_parsing_sig ppf (output_prefix fname)

let all_module_alias (ast : Parsetree.structure) =
  List.for_all
    ~f:(fun { Parsetree.pstr_desc; _ } ->
      match pstr_desc with
      | Pstr_module { pmb_expr = { pmod_desc = Pmod_ident _; _ }; _ } -> true
      | Pstr_attribute _ -> true
      | Pstr_eval _ | Pstr_value _ | Pstr_primitive _ | Pstr_type _
      | Pstr_typext _ | Pstr_exception _ | Pstr_module _ | Pstr_recmodule _
      | Pstr_modtype _ | Pstr_open _ | Pstr_class _ | Pstr_class_type _
      | Pstr_include _ | Pstr_extension _ ->
          false)
    ast

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
  let outputprefix = output_prefix fname in
  let sourceintf = Filename.remove_extension fname ^ !Config.interface_suffix in
  Js_config.all_module_aliases :=
    (not (Sys.file_exists sourceintf)) && all_module_alias ast;
  let ast = if !Js_config.no_export then no_export ast else ast in
  if !Js_config.modules then Meldep.output_deps_set !Location.input_name Ml ast;
  if !Js_config.as_pp then (
    output_string stdout Config.ast_impl_magic_number;
    output_value stdout (!Location.input_name : string);
    output_value stdout ast);
  if !Js_config.syntax_only then Warnings.check_fatal ()
  else
    let modulename = module_name outputprefix in
    Lam_compile_env.reset ();
    let env = Initialization.Perfile.initial_env () in
    Env.set_unit_name modulename;
    let ({ Typedtree.structure = typedtree; coercion; _ } as implementation) =
      Typemod.type_implementation fname outputprefix modulename env ast
    in
    let typedtree_coercion = (typedtree, coercion) in
    print_if ppf Clflags.dump_typedtree Printtyped.implementation_with_coercion
      implementation;
    if !Clflags.print_types || !Js_config.cmi_only then Warnings.check_fatal ()
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
        Lam_compile_main.lambda_as_module ~package_info js_program outputprefix
(* process_with_gentype (Artifact_extension.append_extension outputprefix Cmt) *)

let implementation ~parser ppf fname =
  Initialization.Perfile.init_path ();
  parser fname
  |> Cmd_ppx_apply.apply_rewriters ~restore:false ~tool_name:Js_config.tool_name
       Ml
  |> Ppx_entry.rewrite_implementation
  |> print_if_pipe ppf Clflags.dump_parsetree Printast.implementation
  |> print_if_pipe ppf Clflags.dump_source Pprintast.structure
  |> after_parsing_impl ppf fname

let implementation_cmj _ppf fname =
  (* this is needed because the path is used to find other modules path *)
  Initialization.Perfile.init_path ();
  let cmj = Js_cmj_format.from_file fname in
  (* NOTE(anmonteiro): If we're generating JS from a `.cmj`, we take the
     resulting JS extension from the `-o FILENAME.EXT1.EXT2` argument. In this
     case, we need to make sure we're removing all the extensions from the
     output prefix. *)
  let output_prefix =
    output_prefix ~f:Filename.chop_all_extensions_maybe fname
  in
  Lam_compile_main.lambda_as_module ~package_info:cmj.package_spec
    cmj.delayed_program output_prefix
