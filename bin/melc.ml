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

open Melange_compiler_libs
open Melstd

#ifndef MELANGE_RELEASE_BUILD
let print_backtrace () =
  let raw_bt = Printexc.backtrace_slots (Printexc.get_raw_backtrace ()) in
  match raw_bt with
  | None -> ()
  | Some raw_bt ->
      let acc = ref [] in
      for i = Array.length raw_bt - 1 downto 0 do
        let slot = raw_bt.(i) in
        match Printexc.Slot.location slot with
        | None -> ()
        | Some bt -> (
            match !acc with
            | [] -> acc := [ bt ]
            | hd :: _ -> if hd <> bt then acc := bt :: !acc)
      done;
      List.iter ~f:(fun (bt: Printexc.location) ->
          Printf.eprintf "File \"%s\", line %d, characters %d-%d\n" bt.filename
            bt.line_number bt.start_char bt.end_char) !acc
#endif

let set_abs_input_name sourcefile =
  let sourcefile =
    if !Clflags.absname && Filename.is_relative  sourcefile then
      Paths.absolute_cwd_path sourcefile
    else sourcefile in
  Location.set_input_name sourcefile;
  sourcefile

let process_file sourcefile
  ?(kind ) ppf =
  let open Melangelib in
  (* This is a better default then "", it will be changed later
     The {!Location.input_name} relies on that we write the binary ast
     properly
  *)
  let kind =
    match kind with
    | None -> Artifact_extension.Valid_input.classify (Filename.get_extension_maybe sourcefile)
    | Some kind -> kind in
  match kind with
  | Ml ->
    let sourcefile = set_abs_input_name  sourcefile in
    Js_implementation.implementation
      ~parser:Pparse_driver.parse_implementation
      ppf sourcefile
  | Mli  ->
    let sourcefile = set_abs_input_name  sourcefile in
    Js_implementation.interface
      ~parser:Pparse_driver.parse_interface
      ppf sourcefile
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

module As_ppx = struct
  open Melangelib

  let apply: 'a. kind:'a Ml_binary.kind -> 'a -> 'a = fun ~kind ast ->
    Clflags.all_ppx := [ "melppx" ];
    Cmd_ppx_apply.apply_rewriters ~tool_name:"melppx" kind ast


module Melange_ast_version = Melangelib.Ast_io.Melange_ast_version

module Convert =
  Ppxlib_ast.Convert
    (Melange_ast_version)
    (Ppxlib_ast__.Versions.OCaml_current)

let apply_lazy ~source ~target =
  let { Ast_io.ast; _ } =
    Ast_io.read_exn (File source) ~input_kind:Necessarily_binary
  in
  let oc = open_out_bin target in
  match ast with
  | Intf ast ->
      let ast: Ppxlib_ast__.Versions.OCaml_current.Ast.Parsetree.signature =
        let ast = apply ~kind:Ml_binary.Mli ast in
        let ppxlib_ast: Melange_ast_version.Ast.Parsetree.signature =
          Obj.magic ast
        in
        Convert.copy_signature ppxlib_ast
      in
      output_string oc
        Ppxlib_ast.Compiler_version.Ast.Config.ast_intf_magic_number;
      output_value oc !Location.input_name;
      output_value oc ast
  | Impl ast ->
      let ast: Ppxlib_ast__.Versions.OCaml_current.Ast.Parsetree.structure =
        let ast = apply ~kind:Ml_binary.Ml ast in
        let ppxlib_ast: Melange_ast_version.Ast.Parsetree.structure =
          Obj.magic ast
        in
        Convert.copy_structure ppxlib_ast
      in
      output_string oc
        Ppxlib_ast.Compiler_version.Ast.Config.ast_impl_magic_number;
      output_value oc !Location.input_name;
      output_value oc ast;
      close_out oc
end

module Js_config = Melangelib.Js_config

let anonymous =
  let executed = ref false in
  fun ~(rev_args : string list) ->
    match !executed with
    | true ->
      (* Don't re-run anonymous arguments again if this function has already
       * been executed. If this code is executing the 2nd time, it's coming
       * from a [@mel.config { flags = [| ... |] }].. *)
      `Ok ()
    | false ->
      executed := true;
      if !Js_config.as_ppx then
        match rev_args with
        | [output; input] ->
          `Ok (As_ppx.apply_lazy ~source:input ~target:output)
        | _ -> `Error(false, "`--as-ppx` requires 2 arguments: `melc --as-ppx input output`")
      else
        begin
            if !Js_config.syntax_only then begin
              List.rev_iter rev_args ~f:(fun filename ->
                  begin
                    (* Clflags.reset_dump_state (); *)
                    (* Warnings.reset (); *)
                    process_file filename ppf
                  end );
              `Ok ()
              end else

          match rev_args with
          | [filename] -> `Ok (process_file filename ppf)
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

let clean tmpfile =
  if not !Clflags.verbose then try Sys.remove tmpfile with _ -> ()

let eval (s : string) =
  let tmpfile = Filename.temp_file "eval" Melangelib.Artifact_extension.ml in
  let oc = (open_out_bin tmpfile) in
  Fun.protect
    ~finally:(fun () -> close_out oc)
    (fun () -> output_string oc s);
  let ret = anonymous ~rev_args:[tmpfile] in
  clean tmpfile;
  ret

let print_standard_library () =
  print_endline (String.concat ~sep:":" (Js_config.std_include_dirs ()));
  exit 0

let bs_version_string =
  "Melange " ^ Melangelib.Melange_version.version ^
  " (Using OCaml:" ^ Config.version ^ ")"

let print_version_string () =
#ifndef MELANGE_RELEASE_BUILD
    print_string "DEV VERSION: ";
#endif
    print_endline bs_version_string;
    exit 0

(* NOTE(anmonteiro): This function needs to be reentrant, as it might be called
 * multiple times (`-w` CLI flag, [@@@mel.config { flags = ... }] attribute) .*)
let main: Melc_cli.t -> _ Cmdliner.Term.ret
    = fun {
      Melc_cli.include_dirs;
      hidden_include_dirs;
      alerts;
      warnings;
      output_name;
      ppx;
      open_modules;
      bs_package_output;
      mel_module_system;
      bs_syntax_only;
      bs_package_name;
      bs_module_name;
      as_ppx;
      as_pp;
      no_alias_deps;
      bs_gentype;
      unboxed_types;
      bs_unsafe_empty_array;
      nostdlib;
      color;
      bs_eval;
      bs_cmi_only;
      bs_no_version_header;
      bs_cross_module_opt;
      bs_diagnose;
      where;
      verbose;
      keep_locs;
      bs_no_check_div_by_zero;
      bs_noassertfalse;
      noassert;
      bs_loc;
      impl = impl_source_file;
      intf = intf_source_file;
      intf_suffix;
      cmi_file;
      g;
      opaque;
      preamble;
      strict_sequence;
      strict_formats;
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
      rectypes;
      short_paths;
      unsafe;
      warn_help;
      warn_error;
      bs_stop_after_cmj;
      runtime = _;
      filenames;
      help;
      store_occurrences = _store_occurrences
    } ->
  let open Melangelib in
  if help then `Help (`Auto, None)
  else begin try
    Clflags.include_dirs :=
      (* The OCaml compiler expects include_dirs in reverse CLI order, but
         cmdliner returns it in CLI order. *)
      List.rev_append include_dirs !Clflags.include_dirs;
#if OCAML_VERSION >= (5,2,0)
    Clflags.hidden_include_dirs :=
      List.rev_append hidden_include_dirs !Clflags.hidden_include_dirs;
#else
    let _hidden_include_dirs = hidden_include_dirs in
#endif

    List.iter alerts ~f:Warnings.parse_alert_option;
    List.iter warnings ~f:(Melc_warnings.parse_warnings ~warn_error:false);

    Option.iter output_name
      ~f:(fun output_name -> Clflags.output_name := Some output_name);
    Clflags.all_ppx := !Clflags.all_ppx @ ppx;
    Clflags.open_modules := !Clflags.open_modules @ open_modules;

    Option.iter bs_cross_module_opt ~f:(fun bs_cross_module_opt ->
        Js_config.cross_module_inline := bs_cross_module_opt);
    if bs_syntax_only then Js_config.syntax_only := true;

    Option.iter ~f:Js_packages_state.set_package_name bs_package_name;
    begin match mel_module_system, bs_package_output with
    | None, [] -> ()
    | Some mel_module_system, [] ->
      let suffix = match output_name with
        | Some output_name ->
          (match Filename.get_all_extensions_maybe output_name with
          | None ->
            raise (Arg.Bad "`-o FILENAME` needs to include a valid extension")
          | Some ext -> Js_suffix.of_string ext)
        | None ->
          raise (Arg.Bad "`-o FILENAME` is required when passing `-bs-module-type`")
      in
      Js_packages_state.set_output_info ~suffix mel_module_system
    | None, bs_package_output ->
      List.iter
        ~f:(Js_packages_state.update_npm_package_path ?module_name:bs_module_name)
        bs_package_output;
    | Some _, _ :: _ ->
      raise (Arg.Bad ("Can't pass both `-bs-package-output` and `-bs-module-type`"))
    end;

    if as_ppx then Js_config.as_ppx := as_ppx;
    if as_pp then (
      Js_config.as_pp := true;
      Js_config.syntax_only := true);

    if no_alias_deps then
#if OCAML_VERSION >= (5, 4, 0)
      Clflags.no_alias_deps := true
#else
      Clflags.transparent_modules := true
#endif
      ;
    Option.iter bs_gentype
      ~f:(fun bs_gentype -> Bs_clflags.bs_gentype := Some bs_gentype);
    if unboxed_types then Clflags.unboxed_types := unboxed_types;
    if bs_unsafe_empty_array then Config.unsafe_empty_array := bs_unsafe_empty_array;
    if nostdlib then Js_config.no_stdlib := nostdlib;
    Option.iter ~f:set_color_option color;

    if bs_cmi_only then Js_config.cmi_only := bs_cmi_only;
    if bs_no_version_header then
      Js_config.no_version_header := bs_no_version_header;
    if bs_diagnose then Js_config.diagnose := bs_diagnose;
    if where then print_standard_library ();
    if verbose then begin
      Log.set_level Verbose;
      Clflags.verbose := verbose
    end;
    Option.iter ~f:(fun keep_locs -> Clflags.keep_locs := keep_locs) keep_locs;
    if bs_no_check_div_by_zero then Js_config.check_div_by_zero := false;
    if bs_noassertfalse then Bs_clflags.no_assert_false := bs_noassertfalse;
    if noassert then Clflags.noassert := noassert;
    if bs_loc then Clflags.locations := bs_loc;
    if dtypedtree then Clflags.dump_typedtree := dtypedtree;
    if dparsetree then Clflags.dump_parsetree := dparsetree;
    if drawlambda then Clflags.dump_rawlambda := drawlambda;
    if dsource then Clflags.dump_source := dsource;
    if version then print_version_string ();
    Option.iter ~f:(fun pp -> Clflags.preprocessor := Some pp) pp;
    if absname then Clflags.absname := absname;
    Option.iter ~f:(fun bin_annot ->  Clflags.binary_annotations := bin_annot) bin_annot;
    if i then Clflags.print_types := i;
    if nopervasives then Clflags.nopervasives := nopervasives;
    if modules then Js_config.modules := modules;
    if nolabels then Clflags.classic := nolabels;
    if principal then Clflags.principal := principal;
    if rectypes then Clflags.recursive_types := rectypes;
    if short_paths then Clflags.real_paths := false;
    if unsafe then Clflags.unsafe := unsafe;
    if warn_help then Warnings.help_warnings ();
    List.iter ~f:(Melc_warnings.parse_warnings ~warn_error:true) warn_error ;
    if bs_stop_after_cmj then Js_config.cmj_only := bs_stop_after_cmj;

    Option.iter bs_eval ~f:(fun s -> ignore (eval s: _ Cmdliner.Term.ret));
    Option.iter intf_suffix ~f:(fun suffix -> Config.interface_suffix := suffix);
    Option.iter cmi_file ~f:(fun cmi_file -> Clflags.cmi_file := Some cmi_file);
    if g then Clflags.debug := g;
    if opaque then Clflags.opaque := opaque;
    Js_config.preamble := preamble;
    if strict_sequence then Clflags.strict_sequence := strict_sequence;
    if strict_formats then Clflags.strict_formats := strict_formats;
#if OCAML_VERSION >= (5,2,0)
    if _store_occurrences then Clflags.store_occurrences := _store_occurrences;
#endif

    Option.iter ~f:impl impl_source_file;
    Option.iter ~f:intf intf_source_file;
    anonymous ~rev_args:(List.rev filenames)
    with
    | Arg.Bad msg ->
      `Error (false, msg)
    | x ->
      begin
#ifndef MELANGE_RELEASE_BUILD
        print_backtrace ();
#endif
        Location.report_exception ppf x;
        exit 2
      end
  end


let melc_cmd =
  let open Cmdliner in
  let doc = "the Melange compiler" in
  let info = Cmd.info "melc" ~doc in
  Cmd.v info Term.(ret (const main $ Melc_cli.cmd))

(** parse flags in @mel.config *)
let file_level_flags_handler (e : Parsetree.expression option) =
  match e with
  | None -> ()
  | Some { pexp_desc = Pexp_array args; pexp_loc; _ } ->
    let args =
      ( List.map ~f:(fun (e: Parsetree.expression) ->
          match e.pexp_desc with
#if OCAML_VERSION >= (5, 3, 0)
          | Pexp_constant { pconst_desc = Pconst_string(name,_,_); _ }
#else
          | Pexp_constant (Pconst_string(name,_,_))
#endif
            -> name
          | _ -> Location.raise_errorf ~loc:e.pexp_loc "Flags must be a literal array of strings") args)
    in
    let argv = Melc_cli.normalize_argv (Array.of_list (Sys.argv.(0) :: args)) in
    (match Cmdliner.Cmd.eval ~argv melc_cmd with
    | c when c = Cmdliner.Cmd.Exit.ok -> ()
    | _c -> Location.raise_errorf ~loc:pexp_loc "Invalid configuration")
  | Some e ->
    Location.raise_errorf ~loc:e.pexp_loc "Flags must be a literal array of strings"

let () =
  Melangelib.Initialization.Global.run ();
  let flags = "flags" in
  Melangelib.Ast_config.add_structure
    flags file_level_flags_handler;
  Melangelib.Ast_config.add_signature
    flags file_level_flags_handler;

  let argv = Melc_cli.normalize_argv Sys.argv in
  exit (Cmdliner.Cmd.eval ~argv melc_cmd)
