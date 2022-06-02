(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

let set_abs_input_name sourcefile =
  let sourcefile =
    if !Clflags.absname && Filename.is_relative  sourcefile then
      Ext_path.absolute_cwd_path sourcefile
    else sourcefile in
  Location.set_input_name sourcefile;
  sourcefile


let setup_error_printer (syntax_kind : [ `ml | `reason | `rescript ])=
  Config.syntax_kind := syntax_kind ;
  if syntax_kind = `reason then begin
    Lazy.force Outcome_printer.Reason_outcome_printer_main.setup
  end else if !Config.syntax_kind = `rescript then begin
    Lazy.force Napkin.Res_outcome_printer.setup
  end



let setup_runtime_path path =
  let u0 = Filename.dirname path in
  let std = Filename.basename path in
  let _path = Filename.dirname u0 in
  let rescript = Filename.basename u0 in
  (match rescript.[0] with
   | '@' -> (* scoped package *)
     Bs_version.package_name := rescript ^ "/" ^ std;
   | _ -> Bs_version.package_name := std
   | exception _ ->
     Bs_version.package_name := std);
  Js_config.customize_runtime := Some path

let process_file sourcefile
  ?(kind ) ppf =
  (* This is a better default then "", it will be changed later
     The {!Location.input_name} relies on that we write the binary ast
     properly
  *)
  let kind =
    match kind with
    | None -> Ext_file_extensions.classify_input (Ext_filename.get_extension_maybe sourcefile)
    | Some kind -> kind in
  match kind with
  | Re ->
    let sourcefile = set_abs_input_name  sourcefile in
    setup_error_printer `reason;
    Js_implementation.implementation
      ~parser:Ast_reason_pp.RE.parse_implementation
      ~lang:`reason
      ppf sourcefile
  | Rei ->
    let sourcefile = set_abs_input_name  sourcefile in
    setup_error_printer `reason;
    Js_implementation.interface
      ~parser:Ast_reason_pp.RE.parse_interface
      ~lang:`reason
      ppf sourcefile
  | Ml ->
    let sourcefile = set_abs_input_name  sourcefile in
    Js_implementation.implementation
      ~parser:Pparse_driver.parse_implementation
      ~lang:`ml
      ppf sourcefile
  | Mli  ->
    let sourcefile = set_abs_input_name  sourcefile in
    Js_implementation.interface
      ~parser:Pparse_driver.parse_interface
      ~lang:`ml
      ppf sourcefile
  | Res ->
    let sourcefile = set_abs_input_name  sourcefile in
    setup_error_printer `rescript;
    Js_implementation.implementation
      ~parser:Napkin.Res_driver.parse_implementation
      ~lang:`rescript
      ppf sourcefile
  | Resi ->
    let sourcefile = set_abs_input_name  sourcefile in
    setup_error_printer `rescript;
    Js_implementation.interface
      ~parser:Napkin.Res_driver.parse_interface
      ~lang:`rescript
      ppf sourcefile
  | Intf_ast
    ->
    Js_implementation.interface_mliast ppf sourcefile
    setup_error_printer ;
  | Impl_ast
    ->
    Js_implementation.implementation_mlast ppf sourcefile
    setup_error_printer;
  | Mlmap
    ->
    Location.set_input_name  sourcefile;
    Js_implementation.implementation_map ppf sourcefile
  | Cmi
    ->
    let cmi_sign = (Cmi_format.read_cmi sourcefile).cmi_sign in
    Printtyp.signature Format.std_formatter cmi_sign ;
    Format.pp_print_newline Format.std_formatter ()
  | Cmj ->
    Js_implementation.implementation_cmj ppf sourcefile
  | Unknown ->
    raise (Arg.Bad ("don't know what to do with " ^ sourcefile))


let ppf = Format.err_formatter

(* Error messages to standard error formatter *)
open struct
  open Reason_omp
  module To_current = Convert(OCaml_406)(OCaml_current)
  module From_current = Convert(OCaml_current)(OCaml_406)

  let handle_res_parse_result (parse_result : _ Napkin.Res_driver.parseResult) =
    if parse_result.invalid then begin
        Napkin.Res_diagnostics.printReport parse_result.diagnostics parse_result.source;
        exit 1
    end
end

let print_res_interface ~comments ast =
  Napkin.Res_printer.printInterface ~width:100 ~comments ast

let print_res_implementation ~comments ast =
  Napkin.Res_printer.printImplementation ~width:100 ~comments ast

(* TODO: support printing from AST too. *)
let format_file ~(kind: Ext_file_extensions.syntax_kind) input =
  let ext = Ext_file_extensions.classify_input (Ext_filename.get_extension_maybe input) in
  let impl_format_fn ~comments ast =
    let std = Format.std_formatter in
    match kind, comments with
    | Ml, `Re comments ->
      Ast_reason_pp.ML.format_implementation_with_comments std ~comments ast
    | Ml, `Res _ ->
      Ast_reason_pp.ML.format_implementation_with_comments std ~comments:[] ast
    | Res, `Res comments ->
      let ast = From_current.copy_structure ast in
      output_string stdout (print_res_implementation ~comments ast)
    | Res, `Re _ ->
      let ast = From_current.copy_structure ast in
      output_string stdout (print_res_implementation ~comments:[] ast)
    | Reason, `Re comments ->
      Ast_reason_pp.RE.format_implementation_with_comments std ~comments ast
    | Reason, `Res _ ->
      Ast_reason_pp.RE.format_implementation_with_comments std ~comments:[] ast
    | _ -> raise (Arg.Bad ("don't know what to do with " ^ input))
  in
  let intf_format_fn ~comments ast =
    let std = Format.std_formatter in
    match kind, comments with
    | Ml, `Re comments ->
      Ast_reason_pp.ML.format_interface_with_comments std ~comments ast
    | Ml, `Res _ ->
      Ast_reason_pp.ML.format_interface_with_comments std ~comments:[] ast
    | Res, `Res comments ->
      let ast = From_current.copy_signature ast in
      output_string stdout (print_res_interface ~comments ast)
    | Res, `Re _ ->
      let ast = From_current.copy_signature ast in
      output_string stdout (print_res_interface ~comments:[] ast)
    | Reason, `Re comments ->
      Ast_reason_pp.RE.format_interface_with_comments std ~comments ast
    | Reason, `Res _ ->
      Ast_reason_pp.RE.format_interface_with_comments std ~comments:[] ast
    | _ -> raise (Arg.Bad ("don't know what to do with " ^ input))
  in
  begin match ext with
  | Ml ->
    let ast, comments =
      Ast_reason_pp.ML.parse_implementation_with_comments input
    in
    impl_format_fn ~comments:(`Re comments) ast
  | Mli ->
    let ast, comments = Ast_reason_pp.ML.parse_interface_with_comments input in
    intf_format_fn ~comments:(`Re comments) ast
  | Res ->
    let parse_result =
      Napkin.Res_driver.parsingEngine.parseImplementation ~forPrinter:true ~filename:input
    in
    handle_res_parse_result parse_result;
    impl_format_fn
      ~comments:(`Res parse_result.comments)
      parse_result.parsetree
  | Resi ->
    let parse_result =
      Napkin.Res_driver.parsingEngine.parseInterface ~forPrinter:true ~filename:input
    in
    intf_format_fn
      ~comments:(`Res parse_result.comments)
       parse_result.parsetree
  | Re ->
    let ast, comments = Ast_reason_pp.RE.parse_implementation_with_comments input in
    impl_format_fn ~comments:(`Re comments) ast
  | Rei ->
    let ast, comments = Ast_reason_pp.RE.parse_interface_with_comments input in
    intf_format_fn ~comments:(`Re comments) ast
  | _ -> (raise (Arg.Bad ("don't know what to do with " ^ input)))
  end

let anonymous ~(rev_args : string list) =
  Ext_log.dwarn ~__POS__ "Compiler include dirs: %s@." (String.concat "; " !Clflags.include_dirs);
  if !Js_config.as_ppx then
    match rev_args with
    | [output; input] ->
      `Ok (Ppx_apply.apply_lazy
        ~source:input
        ~target:output
        Ppx_entry.rewrite_implementation
        Ppx_entry.rewrite_signature)
    | _ -> `Error(false, "Wrong format when use -as-ppx")
  else
    begin
        if !Js_config.syntax_only then begin
          Ext_list.rev_iter rev_args (fun filename ->
              begin
                (* Clflags.reset_dump_state (); *)
                (* Warnings.reset (); *)
                process_file filename ppf
              end );
          `Ok ()
          end else

      match rev_args with
      | [filename] ->
        begin match !Js_config.format with
        | Some syntax_kind -> `Ok (format_file ~kind:syntax_kind filename)
        | None -> `Ok (process_file filename ppf)
        end
      | [] -> `Ok ()
      | _ ->
          `Error (false, "can not handle multiple files")
    end

(** used by -impl -intf *)
let impl filename =
  Js_config.js_stdout := false;
  process_file filename ~kind:Ml ppf ;;
let intf filename =
  Js_config.js_stdout := false ;
  process_file filename ~kind:Mli ppf;;

let set_color_option option =
  match Clflags.color_reader.parse option with
  | None -> ()
  | Some setting -> Clflags.color := Some setting

let eval (s : string) ~suffix =
  let tmpfile = Filename.temp_file "eval" suffix in
  Ext_io.write_file tmpfile s;
  let ret = anonymous  ~rev_args:[tmpfile] in
  Ast_reason_pp.clean tmpfile;
  ret

let try_eval ~f =
    try f ()
    with
    | Arg.Bad msg ->
        Format.eprintf "%s@." msg;
        exit 2
    | x ->
      begin
#ifndef BS_RELEASE_BUILD
        Ext_obj.bt ();
#endif
        Location.report_exception ppf x;
        exit 2
      end

module Pp = Rescript_cpp
let define_variable s =
  match Ext_string.split ~keep_empty:true s '=' with
  | [key; v] ->
    if not (Pp.define_key_value key v)  then
       raise  (Arg.Bad("illegal definition: " ^ s))
  | _ -> raise (Arg.Bad ("illegal definition: " ^ s))

let print_standard_library () =
  print_endline (Lazy.force Js_config.stdlib_path);
  exit 0

let bs_version_string =
  "Melange " ^ Bs_version.version ^
  " ( Using OCaml:" ^ Config.version ^ " )"

let print_version_string () =
#ifndef BS_RELEASE_BUILD
    print_string "DEV VERSION: ";
#endif
    print_endline bs_version_string;
    exit 0

(* NOTE(anmonteiro): This function needs to be reentrant, as it might be called
 * multiple times (`-w` CLI flag, [@@@bs.config { flags = ... }] attribute) .*)
let main: Melc_cli.t -> _ Cmdliner.Term.ret
    = fun {
      Melc_cli.include_dirs;
      warnings;
      output_name;
      bs_read_cmi;
      ppx;
      open_modules;
      bs_jsx;
      bs_package_output;
      bs_ast;
      bs_syntax_only;
      bs_g;
      bs_package_name;
      bs_ns;
      as_ppx;
      as_pp;
      no_alias_deps;
      bs_gentype;
      unboxed_types;
      bs_re_out;
      bs_D;
      bs_unsafe_empty_array;
      nostdlib;
      color;
      bs_list_conditionals;
      bs_eval;
      bs_e;
      bs_cmi_only;
      bs_cmi;
      bs_cmj;
      bs_no_version_header;
      bs_no_builtin_ppx;
      bs_cross_module_opt;
      bs_diagnose;
      format;
      where;
      verbose;
      keep_locs;
      bs_no_check_div_by_zero;
      bs_noassertfalse;
      noassert;
      bs_loc;
      impl = impl_source_file;
      intf = intf_source_file;
      dtypedtree;
      dparsetree;
      drawlambda;
      dsource;
      version;
      pp;
      absname;
      bin_annot;
      i;
      nopervasives;
      modules;
      nolabels;
      principal;
      short_paths;
      unsafe;
      warn_help;
      warn_error;
      bs_stop_after_cmj;
      runtime;
      make_runtime;
      make_runtime_test;
      filenames;
      help
    } ->
  if help then `Help (`Auto, None)
  else begin
    Clflags.include_dirs := include_dirs @ !Clflags.include_dirs;
    Ext_list.iter warnings (fun w ->
        Ext_option.iter
          (Warnings.parse_options false w)
          Location.(prerr_alert none));
    Ext_option.iter output_name (fun output_name -> Clflags.output_name := Some output_name);
    if bs_read_cmi then Bs_clflags.assume_no_mli := Mli_exists;
    Clflags.all_ppx := !Clflags.all_ppx @ ppx;
    Clflags.open_modules := !Clflags.open_modules @ open_modules;

    Ext_option.iter bs_jsx (fun bs_jsx ->
      if bs_jsx <> 3 then begin
        raise (Arg.Bad ("Unsupported jsx version : " ^ string_of_int bs_jsx));
      end;
      Js_config.jsx_version := 3);

    Ext_option.iter bs_cross_module_opt (fun bs_cross_module_opt ->
      Js_config.cross_module_inline := bs_cross_module_opt);
    Ext_option.iter runtime setup_runtime_path;
    if make_runtime then Js_packages_state.make_runtime ();
    if make_runtime_test then Js_packages_state.make_runtime_test ();
    Ext_option.iter bs_package_output Js_packages_state.update_npm_package_path;

    if bs_syntax_only then Js_config.syntax_only := bs_syntax_only;

    if bs_ast then (
      Js_config.binary_ast := true;
      Js_config.syntax_only := true);
    if bs_g then (
      Js_config.debug := bs_g;
      Rescript_cpp.replace_directive_bool "DEBUG" true);

    Ext_option.iter bs_package_name Js_packages_state.set_package_name;
    Ext_option.iter bs_ns Js_packages_state.set_package_map;

    if as_ppx then Js_config.as_ppx := as_ppx;
    if as_pp then (
      Js_config.as_pp := true;
      Js_config.syntax_only := true);

    if no_alias_deps then Clflags.transparent_modules := no_alias_deps;
    Ext_option.iter bs_gentype (fun bs_gentype -> Bs_clflags.bs_gentype := Some bs_gentype);
    if unboxed_types then Clflags.unboxed_types := unboxed_types;
    if bs_re_out then Lazy.force Outcome_printer.Reason_outcome_printer_main.setup;
    Ext_list.iter bs_D define_variable;
    if bs_list_conditionals then Pp.list_variables Format.err_formatter;
    if bs_unsafe_empty_array then Config.unsafe_empty_array := bs_unsafe_empty_array;
    if nostdlib then Js_config.no_stdlib := nostdlib;
    Ext_option.iter color set_color_option;

    if bs_cmi_only then Js_config.cmi_only := bs_cmi_only;
    if bs_cmi then Js_config.force_cmi := bs_cmi;
    if bs_cmj then Js_config.force_cmj := bs_cmj;
    if bs_no_version_header then
      Js_config.no_version_header := bs_no_version_header;

    if bs_no_builtin_ppx then Js_config.no_builtin_ppx := bs_no_builtin_ppx;
    if bs_diagnose then Js_config.diagnose := bs_diagnose;
    Ext_option.iter format (fun format -> Js_config.format := Some format);
    if where then print_standard_library ();
    if verbose then Clflags.verbose := verbose;
    Ext_option.iter keep_locs (fun keep_locs -> Clflags.keep_locs := keep_locs);
    if bs_no_check_div_by_zero then Js_config.check_div_by_zero := false;
    if bs_noassertfalse then Bs_clflags.no_assert_false := bs_noassertfalse;
    if noassert then Clflags.noassert := noassert;
    if bs_loc then Clflags.locations := bs_loc;
    if dtypedtree then Clflags.dump_typedtree := dtypedtree;
    if dparsetree then Clflags.dump_parsetree := dparsetree;
    if drawlambda then Clflags.dump_rawlambda := drawlambda;
    if dsource then Clflags.dump_source := dsource;
    if version then print_version_string ();
    Ext_option.iter pp (fun pp -> Clflags.preprocessor := Some pp);
    if absname then Clflags.absname := absname;
    Ext_option.iter bin_annot (fun bin_annot ->  Clflags.binary_annotations := not bin_annot);
    if i then Clflags.print_types := i;
    if nopervasives then Clflags.nopervasives := nopervasives;
    if modules then Js_config.modules := modules;
    if nolabels then Clflags.classic := nolabels;
    if principal then Clflags.principal := principal;
    if short_paths then Clflags.real_paths := false;
    if unsafe then Clflags.unsafe := unsafe;
    if warn_help then Warnings.help_warnings ();
    Ext_list.iter warn_error (fun w ->
        Ext_option.iter
          (Warnings.parse_options true w)
          Location.(prerr_alert none));
    if bs_stop_after_cmj then Js_config.cmj_only := bs_stop_after_cmj;

    Ext_option.iter bs_eval (fun s ->
      try_eval ~f:(fun () ->
        ignore (eval ~suffix:Literals.suffix_ml s: _ Cmdliner.Term.ret )));
    Ext_option.iter bs_e (fun s ->
      try_eval ~f:(fun () ->
        ignore (eval ~suffix:Literals.suffix_res s: _ Cmdliner.Term.ret )));

    Ext_option.iter impl_source_file impl;
    Ext_option.iter intf_source_file intf;

    try
     anonymous ~rev_args:(List.rev filenames)
    with
    | Arg.Bad msg ->
        Format.eprintf "%s@." msg;
        exit 2
    | x ->
      begin
#ifndef BS_RELEASE_BUILD
        Ext_obj.bt ();
#endif
        Location.report_exception ppf x;
        exit 2
      end
end


let melc_cmd =
  let open Cmdliner in
  let doc = "TODO: melc" in
  let info = Cmd.info "melc" ~doc in
  Cmd.v info Term.(ret (const main $ Melc_cli.cmd))

(** parse flags in bs.config *)
let file_level_flags_handler (e : Parsetree.expression option) =
  match e with
  | None -> ()
  | Some { pexp_desc = Pexp_array args; pexp_loc; _ } ->
    let args =
        ( Ext_list.map  args (fun e ->
              match e.pexp_desc with
              | Pexp_constant (Pconst_string(name,_,_)) -> name
              | _ -> Location.raise_errorf ~loc:e.pexp_loc "string literal expected" )) in
    let argv = Melc_cli.normalize_argv (Array.of_list (Sys.argv.(0) :: args)) in
    (match Cmdliner.Cmd.eval ~argv melc_cmd with
    | c when c = Cmdliner.Cmd.Exit.ok -> ()
    | c ->Location.raise_errorf ~loc:pexp_loc "lol?: %d@." c )
  | Some e ->
    Location.raise_errorf ~loc:e.pexp_loc "string array expected"

let _ : unit =
  Bs_conditional_initial.setup_env ();
  let flags = "flags" in
  Ast_config.add_structure
    flags file_level_flags_handler;
  Ast_config.add_signature
    flags file_level_flags_handler;

  let argv = Melc_cli.normalize_argv Sys.argv in
  exit (Cmdliner.Cmd.eval ~argv melc_cmd)
