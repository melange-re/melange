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
      ppf sourcefile
  | Rei ->
    let sourcefile = set_abs_input_name  sourcefile in
    setup_error_printer `reason;
    Js_implementation.interface
      ~parser:Ast_reason_pp.RE.parse_interface
      ppf sourcefile
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
  | Res ->
    let sourcefile = set_abs_input_name  sourcefile in
    setup_error_printer `rescript;
    Js_implementation.implementation
      ~parser:Napkin.Res_driver.parse_implementation
      ppf sourcefile
  | Resi ->
    let sourcefile = set_abs_input_name  sourcefile in
    setup_error_printer `rescript;
    Js_implementation.interface
      ~parser:Napkin.Res_driver.parse_interface
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
    Bsc_args.bad_arg ("don't know what to do with " ^ sourcefile)
let usage = "Usage: bsc <options> <files>\nOptions are:"

let ppf = Format.err_formatter

(* Error messages to standard error formatter *)
open struct
  open Reason_migrate_parsetree
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
    | _ -> Bsc_args.bad_arg ("don't know what to do with " ^ input)
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
    | _ -> Bsc_args.bad_arg ("don't know what to do with " ^ input)
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
  | _ -> Bsc_args.bad_arg ("don't know what to do with " ^ input)
  end

let anonymous ~(rev_args : string list) =
  if !Js_config.as_ppx then
    match rev_args with
    | [output; input] ->
      Ppx_apply.apply_lazy
        ~source:input
        ~target:output
        Ppx_entry.rewrite_implementation
        Ppx_entry.rewrite_signature
    | _ -> Bsc_args.bad_arg "Wrong format when use -as-ppx"
  else
    begin
      match rev_args with
      | [filename] ->
        begin match !Js_config.format with
        | Some syntax_kind -> format_file ~kind:syntax_kind filename
        | None -> process_file filename ppf
        end
      | [] -> ()
      | _ ->
        if !Js_config.syntax_only then
          Ext_list.rev_iter rev_args (fun filename ->
              begin
                (* Clflags.reset_dump_state (); *)
                (* Warnings.reset (); *)
                process_file filename ppf
              end )
        else
          Bsc_args.bad_arg "can not handle multiple files"
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
  anonymous  ~rev_args:[tmpfile];
  Ast_reason_pp.clean tmpfile


(* let (//) = Filename.concat *)




module Pp = Rescript_cpp
let define_variable s =
  match Ext_string.split ~keep_empty:true s '=' with
  | [key; v] ->
    if not (Pp.define_key_value key v)  then
       Bsc_args.bad_arg ("illegal definition: " ^ s)
  | _ -> Bsc_args.bad_arg ("illegal definition: " ^ s)

let print_standard_library () =
  print_endline (Lazy.force Js_config.stdlib_path);
  exit 0

let bs_version_string =
  "ReScript " ^ Bs_version.version ^
  " ( Using OCaml:" ^ Config.version ^ " )"

let print_version_string () =
#ifndef BS_RELEASE_BUILD
    print_string "DEV VERSION: ";
#endif
    print_endline bs_version_string;
    exit 0

let [@inline] set s : Bsc_args.spec = Unit (Unit_set s)
let [@inline] clear s : Bsc_args.spec = Unit (Unit_clear s)
let [@inline] unit_lazy s : Bsc_args.spec = Unit(Unit_lazy s)
let [@inline] string_call s : Bsc_args.spec =
  String (String_call s)
let [@inline] string_optional_set s : Bsc_args.spec =
  String (String_optional_set s)

let [@inline] unit_call s : Bsc_args.spec =
  Unit (Unit_call s)
let [@inline] string_list_add s : Bsc_args.spec =
  String (String_list_add s)

(* mostly common used to list in the beginning to make search fast
*)
let buckle_script_flags : (string * Bsc_args.spec * string) array =
  [|
    "-I", string_list_add  Clflags.include_dirs ,
    "<dir>  Add <dir> to the list of include directories" ;

    "-w", string_call (Warnings.parse_options false),
    "<list>  Enable or disable warnings according to <list>:\n\
     +<spec>   enable warnings in <spec>\n\
     -<spec>   disable warnings in <spec>\n\
     @<spec>   enable warnings in <spec> and treat them as errors\n\
     <spec> can be:\n\
     <num>             a single warning number\n\
     <num1>..<num2>    a range of consecutive warning numbers\n\
     default setting is " ^ Bsc_warnings.defaults_w;


    "-o", string_optional_set Clflags.output_name,
    "<file>  set output file name to <file>";

    "-bs-read-cmi",  unit_call (fun _ -> Bs_clflags.assume_no_mli := Mli_exists),
    "*internal* Assume mli always exist ";

    "-ppx", string_list_add Clflags.all_ppx,
    "<command>  Pipe abstract syntax trees through preprocessor <command>";

    "-open", string_list_add Clflags.open_modules,
    "<module>  Opens the module <module> before typing";

    "-bs-jsx", string_call (fun i ->
        (if i <> "3" then Bsc_args.bad_arg (" Not supported jsx version : " ^  i));
        Js_config.jsx_version := 3),
    "*internal* Set jsx version";

    "-bs-package-output", string_call Js_packages_state.update_npm_package_path,
    "*internal* Set npm-output-path: [opt_module]:path, for example: 'lib/cjs', 'amdjs:lib/amdjs', 'es6:lib/es6' ";

    "-bs-ast", unit_call(fun _ ->  Js_config.binary_ast := true; Js_config.syntax_only := true),
    "*internal* Generate binary .mli_ast and ml_ast and stop";

    "-bs-syntax-only", set Js_config.syntax_only,
    "Only check syntax";

    "-bs-g", unit_call (fun _ -> Js_config.debug := true; Pp.replace_directive_bool "DEBUG" true),
    "Debug mode";

    "-bs-v", string_call ignore,
    "*internal* version check to force a rebuild";
    "-bs-package-name", string_call Js_packages_state.set_package_name,
    "Set package name, useful when you want to produce npm packages";

    "-bs-ns", string_call Js_packages_state.set_package_map,
    "Set package map, not only set package name but also use it as a namespace" ;

    "-as-ppx", set Js_config.as_ppx,
    "*internal*As ppx for editor integration";
    "-as-pp", unit_call(fun _ ->  Js_config.as_pp := true ; Js_config.syntax_only := true),
    "*internal*As pp to interact with native tools";
    "-no-alias-deps", set Clflags.transparent_modules,
    "*internal*Do not record dependencies for module aliases";

    "-bs-gentype", string_optional_set Bs_clflags.bs_gentype ,
    "*internal* Pass gentype command";

    (******************************************************************************)


    (* XXX(anmonteiro): flag kept for compatibility. *)
    "-bs-super-errors", unit_call ignore,
    "Better error message combined with other tools ";

    "-unboxed-types", set Clflags.unboxed_types,
    "Unannotated unboxable types will be unboxed";

    "-bs-re-out", unit_lazy Outcome_printer.Reason_outcome_printer_main.setup,
    "Print compiler output in Reason syntax";

    "-bs-refmt", string_optional_set Js_config.refmt,
    "*internal* set customized refmt path";

    "-bs-D",  string_call define_variable,
    "Define conditional variable e.g, -D DEBUG=true";

    "-bs-unsafe-empty-array",  set Config.unsafe_empty_array,
    "*internal* Allow [||] to be polymorphic";

    "-nostdlib",  set Js_config.no_stdlib,
    "*internal* Don't use stdlib";

    (* XXX(anmonteiro): flag kept for compatibility. *)
    "-bs-internal-check",  unit_call ignore,
    "*internal* Built in check corrupted data";

    "-color", string_call set_color_option,
    "Enable or disable colors in compiler messages\n\
     The following settings are supported:\n\
     auto    use heuristics to enable colors only if supported\n\
     always  enable colors\n\
     never   disable colors\n\
     The default setting is 'always'\n\
     The current heuristic for 'auto'\n\
     checks that the TERM environment variable exists and is\n\
     not empty or \"dumb\", and that isatty(stderr) holds.";

    "-bs-list-conditionals", unit_call (fun () -> Pp.list_variables Format.err_formatter),
    "List existing conditional variables";

    "-bs-eval", string_call (fun  s -> eval s ~suffix:Literals.suffix_ml),
    "*internal* (experimental) set the string to be evaluated in OCaml syntax";

    "-e",  string_call (fun  s -> eval s ~suffix:Literals.suffix_res),
    "(experimental) set the string to be evaluated in ReScript syntax";

    "-bs-cmi-only", set Js_config.cmi_only,
    "*internal* Stop after generating cmi file";

    "-bs-cmi", set Js_config.force_cmi,
    "*internal*  Not using cached cmi, always generate cmi";

    "-bs-cmj", set Js_config.force_cmj,
    "*internal*  Not using cached cmj, always generate cmj";

    "-bs-no-version-header", set Js_config.no_version_header,
    "*internal*Don't print version header";

    "-bs-no-builtin-ppx", set Js_config.no_builtin_ppx,
    "*internal* Disable built-in ppx";

    "-bs-cross-module-opt", set Js_config.cross_module_inline,
    "*internal* Enable cross module inlining(experimental), default(false)";

    "-bs-no-cross-module-opt", clear Js_config.cross_module_inline,
    "*internal* Disable cross module inlining(experimental)";

    "-bs-diagnose", set Js_config.diagnose,
    "*internal* More verbose output";

    "-bs-no-check-div-by-zero", clear Js_config.check_div_by_zero,
    "*internal* unsafe mode, don't check div by zero and mod by zero";

    "-bs-noassertfalse", set Bs_clflags.no_assert_false,
    "*internal*  no code for assert false";

    "-noassert", set Clflags.noassert,
    "*internal* Do not compile assertion checks";

    "-bs-loc", set Clflags.locations,
    "*internal*  dont display location with -dtypedtree, -dparsetree";

    "-impl",  string_call impl,
    "*internal* <file>  Compile <file> as a .ml file";

    "-intf", string_call intf,
    "*internal* <file>  Compile <file> as a .mli file";

    "-dtypedtree", set Clflags.dump_typedtree,
    "*internal* debug typedtree";

    "-dparsetree", set Clflags.dump_parsetree,
    "*internal* debug parsetree";

    "-drawlambda", set Clflags.dump_rawlambda,
    "*internal* debug raw lambda";

    "-dsource", set Clflags.dump_source,
    "*internal* print source";

    "-format", string_call (fun ext ->
      let syntax: Ext_file_extensions.syntax_kind = match Ext_string.trim ext with
      | "re" -> Reason
      | "res" -> Res
      | "ml" -> Ml
      | x ->
        Location.raise_errorf
          "invalid option `%s` passed to -format, expected `re`, `res` or `ml`"
          x
      in
      Js_config.format := Some syntax),
    "Format as Res syntax";

    "-where", unit_call print_standard_library,
    "Print location of standard library and exit";

    "-verbose", set Clflags.verbose,
    "Print calls to external commands";

    "-keep-locs", set Clflags.keep_locs,
    "Keep locations in .cmi files";

    "-no-keep-locs", clear Clflags.keep_locs,
    "Do not keep locations in .cmi files";

    "-nopervasives", set Clflags.nopervasives,
    "*internal*";

    "-v", unit_call print_version_string,
    " Print compiler version and location of standard library and exit";

    "-version", unit_call print_version_string,
    "Print version and exit";

    "-pp", string_optional_set Clflags.preprocessor,
    "<command>  Pipe sources through preprocessor <command>";

    "-absname", set Clflags.absname,
    "Show absolute filenames in error messages";
    (* Not used, the build system did the expansion *)

    "-bs-no-bin-annot",  clear Clflags.binary_annotations,
    "Disable binary annotations (by default on)";

    "-i", set Clflags.print_types,
    "Print inferred interface";

    "-modules", set Js_config.modules,
    "*internal* serve similar to ocamldep";

    "-nolabels", set Clflags.classic,
    "*internal* Ignore non-optional labels in types";

    "-principal", set Clflags.principal,
    "*internal* Check principality of type inference";

    "-short-paths", clear Clflags.real_paths,
    "*internal* Shorten paths in types";

    "-unsafe", set Clflags.unsafe,
    "Do not compile bounds checking on array and string access";

    "-warn-help", unit_call Warnings.help_warnings,
    "Show description of warning numbers";
    "-bin-annot", Unit_dummy,
    "*internal* keep the compatibility with RLS";
    "-c", Unit_dummy,
    "*internal* keep the compatibility with RLS";
    "-warn-error", string_call (Warnings.parse_options true),
    "<list>  Enable or disable error status for warnings according\n\
     to <list>.  See option -w for the syntax of <list>.\n\
     Default setting is " ^ Bsc_warnings.defaults_warn_error;
    "-runtime",string_call setup_runtime_path,
    "*internal* Set the runtime directory";
    "-make-runtime", unit_call Js_packages_state.make_runtime,
    "*internal* make runtime library";
    "-make-runtime-test", unit_call Js_packages_state.make_runtime_test,
    "*internal* make runtime test library";

    "-bs-stop-after-cmj", set Js_config.cmj_only,
    "Stop after generating the cmj"
  |]



(** parse flags in bs.config *)
let file_level_flags_handler (e : Parsetree.expression option) =
  match e with
  | None -> ()
  | Some { pexp_desc = Pexp_array args; pexp_loc; _ } ->
    let args = Array.of_list
        ( Ext_list.map  args (fun e ->
              match e.pexp_desc with
              | Pexp_constant (Pconst_string(name,_,_)) -> name
              | _ -> Location.raise_errorf ~loc:e.pexp_loc "string literal expected" )) in
    (try Bsc_args.parse_exn ~start:0
           ~argv:args buckle_script_flags (fun ~rev_args:_ -> ()) ~usage
     with _ -> Location.prerr_warning pexp_loc (Preprocessor "invalid flags for bsc"))
  | Some e ->
    Location.raise_errorf ~loc:e.pexp_loc "string array expected"

let _ : unit =
  Bs_conditional_initial.setup_env ();
  let flags = "flags" in
  Ast_config.add_structure
    flags file_level_flags_handler;
  Ast_config.add_signature
    flags file_level_flags_handler;
  try
    Bsc_args.parse_exn
      ~argv:Sys.argv
      buckle_script_flags anonymous ~usage;
  with
  | Bsc_args.Bad msg ->
    Format.eprintf "%s@." msg ;
    exit 2
  | x ->
    begin
#if false
(* undefined BS_RELEASE_BUILD *)
        Ext_obj.bt ();
#endif
      Location.report_exception ppf x;
      exit 2
    end
