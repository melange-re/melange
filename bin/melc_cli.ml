(* Copyright (C) 2022- Authors of Melange
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)

open Cmdliner
open Melstd

type t = {
  include_dirs : string list;
  hidden_include_dirs : string list;
  alerts : string list;
  warnings : string list;
  output_name : string option;
  ppx : string list;
  open_modules : string list;
  bs_package_output : string list;
  mel_module_system : Module_system.t option;
  bs_syntax_only : bool;
  bs_package_name : string option;
  bs_module_name : string option;
  as_ppx : bool;
  as_pp : bool;
  no_alias_deps : bool;
  bs_gentype : string option;
  unboxed_types : bool;
  bs_unsafe_empty_array : bool;
  nostdlib : bool;
  color : string option;
  bs_eval : string option;
  bs_cmi_only : bool;
  bs_no_version_header : bool;
  bs_cross_module_opt : bool option;
  bs_diagnose : bool;
  where : bool;
  verbose : bool;
  keep_locs : bool option;
  bs_no_check_div_by_zero : bool;
  bs_noassertfalse : bool;
  noassert : bool;
  bs_loc : bool;
  impl : string option;
  intf : string option;
  intf_suffix : string option;
  cmi_file : string option;
  g : bool;
  source_map : bool;
  source_map_include_sources : bool;
  opaque : bool;
  preamble : string option;
  strict_sequence : bool;
  strict_formats : bool;
  dtypedtree : bool;
  dparsetree : bool;
  drawlambda : bool;
  dsource : bool;
  version : bool;
  pp : string option;
  absname : bool;
  bin_annot : bool option;
  i : bool;
  nopervasives : bool;
  modules : bool;
  nolabels : bool;
  principal : bool;
  rectypes : bool;
  short_paths : bool;
  unsafe : bool;
  warn_help : bool;
  warn_error : string list;
  bs_stop_after_cmj : bool;
  runtime : string option;
  filenames : string list;
  store_occurrences : bool;
}

let repeatable_flag arg_info =
  Term.(
    const (function [] -> false | _ :: _ -> true)
    $ Arg.(value & flag_all & arg_info))

let include_dirs =
  let doc = "Add $(docv) to the list of include directories" in
  let docv = "dir" in
  Arg.(value & opt_all string [] & info [ "I" ] ~doc ~docv)

let hidden_include_dirs =
  let doc = "Add $(docv) to the list of \"hidden\" include directories" in
  let docv = "dir" in
  Arg.(value & opt_all string [] & info [ "H" ] ~doc ~docv)

let alerts =
  let doc =
    "$(docv)  Enable or disable alerts according to $(docv):\n\
    \        +<alertname>  enable alert <alertname>\n\
    \        -<alertname>  disable alert <alertname>\n\
    \        ++<alertname> treat <alertname> as fatal error\n\
    \        --<alertname> treat <alertname> as non-fatal\n\
    \        @<alertname>  enable <alertname> and treat it as fatal error\n\
    \    <alertname> can be 'all' to refer to all alert names"
  in
  let docv = "list" in
  Arg.(value & opt_all string [] & info [ "alert" ] ~doc ~docv)

let warnings =
  let doc =
    "Enable or disable warnings according to $(docv):\n\
     +<spec>   enable warnings in <spec>\n\
     -<spec>   disable warnings in <spec>\n\
     @<spec>   enable warnings in <spec> and treat them as errors\n\
     <spec> can be:\n\
     <num>             a single warning number\n\
     <num1>..<num2>    a range of consecutive warning numbers\n\
     default setting is " ^ Melangelib.Melc_warnings.defaults_w
  in
  let docv = "list" in
  Arg.(value & opt_all string [] & info [ "w" ] ~doc ~docv)

let output_name =
  let doc = "set output file name to $(docv)" in
  let docv = "file" in
  Arg.(value & opt (some string) None & info [ "o" ] ~doc ~docv)

let ppx =
  let doc = "Pipe abstract syntax trees through preprocessor $(docv)" in
  let docv = "command" in
  Arg.(value & opt_all string [] & info [ "ppx" ] ~doc ~docv)

let open_modules =
  let doc = "Opens the module $(docv) before typing" in
  let docv = "module" in
  Arg.(value & opt_all string [] & info [ "open" ] ~doc ~docv)

let bs_syntax_only =
  let doc = "Only check syntax" in
  repeatable_flag (Arg.info [ "bs-syntax-only"; "mel-syntax-only" ] ~doc)

let bs_package_name =
  let doc = "Set package name, useful when you want to produce npm packages" in
  Arg.(
    value
    & opt (some string) None
    & info [ "bs-package-name"; "mel-package-name" ] ~doc)

let bs_module_name =
  let doc =
    "Set the module name (if different than the compilation unit name)"
  in
  Arg.(
    value
    & opt (some string) None
    & info [ "bs-module-name"; "mel-module-name" ] ~doc)

let unboxed_types =
  let doc = "Unannotated unboxable types will be unboxed" in
  repeatable_flag (Arg.info [ "unboxed-types" ] ~doc)

let color =
  let doc =
    "Enable or disable colors in compiler messages\n\
     The following settings are supported:\n\
     auto    use heuristics to enable colors only if supported\n\
     always  enable colors\n\
     never   disable colors\n\
     The default setting is 'always'\n\
     The current heuristic for 'auto'\n\
     checks that the TERM environment variable exists and is\n\
     not empty or \"dumb\", and that isatty(stderr) holds."
  in
  Arg.(value & opt (some string) None & info [ "color" ] ~doc)

(* TODO: preamble file? *)
let preamble =
  let doc = "a string to be pre-prended to the generated javascript" in
  Arg.(value & opt (some string) None & info [ "preamble" ] ~doc)

let source_map =
  let doc = "Generate JavaScript source maps" in
  repeatable_flag (Arg.info [ "source-map" ] ~doc)

let source_map_include_sources =
  let doc = "Include sources content in generated source maps" in
  repeatable_flag (Arg.info [ "source-map-include-sources" ] ~doc)

let where =
  let doc = "Print location of standard library and exit" in
  repeatable_flag (Arg.info [ "where" ] ~doc)

let verbose =
  let doc = "Print calls to external commands" in
  repeatable_flag (Arg.info [ "verbose" ] ~doc)

let keep_locs =
  Arg.(
    value & vflag None
    & [
        (Some true, info ~doc:"Keep locations in .cmi files" [ "keep-locs" ]);
        ( Some false,
          info ~doc:"Do not keep locations in .cmi files" [ "no-keep-locs" ] );
      ])

let version =
  let doc = "Print version and exit" in
  repeatable_flag (Arg.info [ "v"; "version" ] ~doc)

let pp =
  let doc = "Pipe sources through preprocessor $(docv)" in
  let docv = "command" in
  Arg.(value & opt (some string) None & info [ "pp" ] ~doc ~docv)

let absname =
  let doc = "Show absolute filenames in error messages" in
  repeatable_flag (Arg.info [ "absname" ] ~doc)

let bin_annot =
  Arg.(
    value & vflag None
    & [
        ( Some true,
          info ~doc:"Enable binary annotations (default: on)" [ "bin-annot" ] );
        ( Some false,
          info ~doc:"Disable binary annotations (default: on)"
            [ "bs-no-bin-annot"; "-no-bin-annot" ] );
      ])

let i =
  let doc = "Print inferred interface" in
  repeatable_flag (Arg.info [ "i" ] ~doc)

let unsafe =
  let doc = "Do not compile bounds checking on array and string access" in
  repeatable_flag (Arg.info [ "unsafe" ] ~doc)

let warn_help =
  let doc = "Show description of warning numbers" in
  repeatable_flag (Arg.info [ "warn-help" ] ~doc)

let warn_error =
  let doc =
    "Enable or disable error status for warnings according\n\
     to $(docv).  See option -w for the syntax of $(docv).\n\
     Default setting is " ^ Melangelib.Melc_warnings.defaults_warn_error
  in
  Arg.(value & opt_all string [] & info [ "warn-error" ] ~doc)

let bs_stop_after_cmj =
  let doc = "Stop after generating the cmj" in
  repeatable_flag (Arg.info [ "bs-stop-after-cmj"; "mel-stop-after-cmj" ] ~doc)

module Internal = struct
  let bs_package_output =
    let doc =
      "*internal* Set npm-output-path: [opt_module]:path, for example: \
       'lib/cjs', 'amdjs:lib/amdjs', 'es6:lib/es6' "
    in
    Arg.(
      value & opt_all string []
      & info [ "bs-package-output"; "mel-package-output" ] ~doc)

  let mel_module_system =
    let module_system_conv =
      let parse m =
        match Module_system.of_string m with
        | Some module_system -> Ok module_system
        | None -> Error (`Msg (Format.asprintf "Invalid module system %s" m))
      in
      let print fmt ms = Format.fprintf fmt "%s" (Module_system.to_string ms) in
      Arg.conv ~docv:"module system" (parse, print)
    in
    let doc = "Specify the module type for JS imports" in
    let docv = "module-type" in
    Arg.(
      value
      & opt (some module_system_conv) None
      & info
          [ "bs-module-type"; "mel-module-type"; "mel-module-system" ]
          ~doc ~docv)

  let as_ppx =
    let doc = "*internal* As ppx for editor integration" in
    repeatable_flag (Arg.info [ "as-ppx" ] ~doc)

  let as_pp =
    let doc = "*internal* As pp to interact with native tools" in
    repeatable_flag (Arg.info [ "as-pp" ] ~doc)

  let no_alias_deps =
    let doc = "*internal*Do not record dependencies for module aliases" in
    repeatable_flag (Arg.info [ "no-alias-deps" ] ~doc)

  let bs_gentype =
    let doc = "*internal* Pass gentype command" in
    Arg.(
      value & opt (some string) None & info [ "bs-gentype"; "mel-gentype" ] ~doc)

  let bs_unsafe_empty_array =
    let doc = "*internal* Allow [||] to be polymorphic" in
    repeatable_flag
      (Arg.info [ "bs-unsafe-empty-array"; "mel-unsafe-empty-array" ] ~doc)

  let nostdlib =
    let doc = "*internal* Don't use stdlib" in
    repeatable_flag (Arg.info [ "nostdlib" ] ~doc)

  let bs_eval =
    let doc =
      "*internal* (experimental) set the string to be evaluated in OCaml syntax"
    in
    Arg.(value & opt (some string) None & info [ "bs-eval"; "eval" ] ~doc)

  let bs_cmi_only =
    let doc = "*internal* Stop after generating cmi file" in
    repeatable_flag (Arg.info [ "bs-cmi-only"; "mel-cmi-only" ] ~doc)

  let bs_no_version_header =
    let doc = "*internal* Don't print version header" in
    repeatable_flag
      (Arg.info [ "bs-no-version-header"; "mel-no-version-header" ] ~doc)

  let bs_cross_module_opt =
    Arg.(
      value & vflag None
      & [
          ( Some true,
            info
              ~doc:
                "*internal* Enable cross module inlining(experimental), \
                 default(false)"
              [ "bs-cross-module-opt"; "mel-cross-module-opt" ] );
          ( Some false,
            info ~doc:"*internal* Disable cross module inlining(experimental)"
              [ "bs-no-cross-module-opt"; "mel-no-cross-module-opt" ] );
        ])

  let bs_diagnose =
    let doc = "*internal* More verbose output" in
    repeatable_flag (Arg.info [ "bs-diagnose"; "mel-diagnose" ] ~doc)

  let bs_no_check_div_by_zero =
    let doc =
      "*internal* unsafe mode, don't check div by zero and mod by zero"
    in
    repeatable_flag
      (Arg.info [ "bs-no-check-div-by-zero"; "mel-no-check-div-by-zero" ] ~doc)

  let bs_noassertfalse =
    let doc = "*internal*  no code for assert false" in
    repeatable_flag (Arg.info [ "bs-noassertfalse"; "mel-noassertfalse" ] ~doc)

  let noassert =
    let doc = "*internal* Do not compile assertion checks" in
    repeatable_flag (Arg.info [ "noassert" ] ~doc)

  let bs_loc =
    let doc =
      "*internal*  dont display location with -dtypedtree, -dparsetree"
    in
    repeatable_flag (Arg.info [ "bs-loc"; "mel-loc" ] ~doc)

  let impl =
    let doc = "*internal* Compile $(docv) as a .ml file" in
    let docv = "file" in
    Arg.(value & opt (some string) None & info [ "impl" ] ~doc ~docv)

  let intf =
    let doc = "*internal* <file>  Compile <file> as a .mli file" in
    Arg.(value & opt (some string) None & info [ "intf" ] ~doc)

  let intf_suffix =
    let doc = "*internal* <file> Suffix for interface files (default: .mli)" in
    Arg.(value & opt (some string) None & info [ "intf-suffix" ] ~doc)

  let cmi_file =
    let doc = "*internal* Use the <file> interface file to type-check" in
    Arg.(value & opt (some string) None & info [ "cmi-file" ] ~doc)

  let g =
    let doc = "*internal* Save debugging information" in
    repeatable_flag (Arg.info [ "g" ] ~doc)

  let opaque =
    let doc =
      "*internal* <file> Does not generate cross-module optimization \
       information (reduces necessary recompilation on module change)"
    in
    repeatable_flag (Arg.info [ "opaque" ] ~doc)

  let strict_sequence =
    let doc = "*internal* Left-hand part of a sequence must have type unit" in
    repeatable_flag (Arg.info [ "strict-sequence" ] ~doc)

  let strict_formats =
    let doc =
      "*internal* Reject invalid formats accepted by legacy implementations"
    in
    repeatable_flag (Arg.info [ "strict-formats" ] ~doc)

  let dtypedtree =
    let doc = "*internal* debug typedtree" in
    repeatable_flag (Arg.info [ "dtypedtree" ] ~doc)

  let dparsetree =
    let doc = "*internal* debug parsetree" in
    repeatable_flag (Arg.info [ "dparsetree" ] ~doc)

  let drawlambda =
    let doc = "*internal* debug raw lambda" in
    repeatable_flag (Arg.info [ "drawlambda" ] ~doc)

  let dsource =
    let doc = "*internal* print source" in
    repeatable_flag (Arg.info [ "dsource" ] ~doc)

  let nopervasives =
    let doc = "*internal*" in
    repeatable_flag (Arg.info [ "nopervasives" ] ~doc)

  let modules =
    let doc = "*internal* serve similar to ocamldep" in
    repeatable_flag (Arg.info [ "modules" ] ~doc)

  let nolabels =
    let doc = "*internal* Ignore non-optional labels in types" in
    repeatable_flag (Arg.info [ "nolabels" ] ~doc)

  let principal =
    let doc = "*internal* Check principality of type inference" in
    repeatable_flag (Arg.info [ "principal" ] ~doc)

  let rectypes =
    let doc = "Allow arbitrary recursive types" in
    repeatable_flag (Arg.info [ "rectypes" ] ~doc)

  let short_paths =
    let doc = "*internal* Shorten paths in types" in
    repeatable_flag (Arg.info [ "short-paths" ] ~doc)

  let runtime =
    let doc = "*internal* Set the runtime directory" in
    Arg.(value & opt (some string) None & info [ "runtime" ] ~doc)
end

let filenames =
  let docv = "filenames" in
  Arg.(value & pos_all string [] & info [] ~docv)

let store_occurrences =
  let doc =
    "Store every occurrence of a bound name in the .cmt file.\n\
     This information can be used by external tools to provide\n\
     features such as project-wide occurrences. This flag has\n\
     no effect in the absence of '-bin-annot'."
  in
  repeatable_flag (Arg.info [ "bin-annot-occurrences" ] ~doc)

module Compat = struct
  (* The args in this module are accepted by the CLI but ignored. They exist
   * for compatibility with OCaml compilation. *)

  let doc = "Ignored. Kept for compatibility"
  let c = repeatable_flag (Arg.info [ "c" ] ~doc)
end

let parse include_dirs hidden_include_dirs alerts warnings output_name ppx
    open_modules bs_package_output mel_module_system bs_syntax_only
    bs_package_name bs_module_name as_ppx as_pp no_alias_deps bs_gentype
    unboxed_types bs_unsafe_empty_array nostdlib color bs_eval bs_cmi_only
    bs_no_version_header bs_cross_module_opt bs_diagnose where verbose keep_locs
    bs_no_check_div_by_zero bs_noassertfalse noassert bs_loc impl intf
    intf_suffix cmi_file g source_map source_map_include_sources opaque preamble
    strict_sequence strict_formats
    dtypedtree dparsetree drawlambda dsource version pp absname bin_annot i
    nopervasives modules nolabels principal rectypes short_paths unsafe
    warn_help warn_error bs_stop_after_cmj runtime filenames _c
    store_occurrences =
  {
    include_dirs;
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
    impl;
    intf;
    intf_suffix;
    cmi_file;
    g;
    source_map;
    source_map_include_sources;
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
    runtime;
    filenames;
    store_occurrences;
  }

let cmd =
  Term.(
    const parse $ include_dirs $ hidden_include_dirs $ alerts $ warnings
    $ output_name $ ppx $ open_modules $ Internal.bs_package_output
    $ Internal.mel_module_system $ bs_syntax_only $ bs_package_name
    $ bs_module_name $ Internal.as_ppx $ Internal.as_pp $ Internal.no_alias_deps
    $ Internal.bs_gentype $ unboxed_types $ Internal.bs_unsafe_empty_array
    $ Internal.nostdlib $ color $ Internal.bs_eval $ Internal.bs_cmi_only
    $ Internal.bs_no_version_header $ Internal.bs_cross_module_opt
    $ Internal.bs_diagnose $ where $ verbose $ keep_locs
    $ Internal.bs_no_check_div_by_zero $ Internal.bs_noassertfalse
    $ Internal.noassert $ Internal.bs_loc $ Internal.impl $ Internal.intf
    $ Internal.intf_suffix $ Internal.cmi_file $ Internal.g $ source_map
    $ source_map_include_sources $ Internal.opaque $ preamble
    $ Internal.strict_sequence $ Internal.strict_formats
    $ Internal.dtypedtree $ Internal.dparsetree $ Internal.drawlambda
    $ Internal.dsource $ version $ pp $ absname $ bin_annot $ i
    $ Internal.nopervasives $ Internal.modules $ Internal.nolabels
    $ Internal.principal $ Internal.rectypes $ Internal.short_paths $ unsafe
    $ warn_help $ warn_error $ bs_stop_after_cmj $ Internal.runtime $ filenames
    $ Compat.c $ store_occurrences)

let normalize_argv argv =
  let len = Array.length argv in
  let normalized = Array.make len "" in
  let idx = ref 0 in
  let nidx = ref 0 in
  while !idx < len do
    let s = argv.(!idx) in
    let is_w = s.[0] = '-' && s.[1] = 'w' && String.length s = 2 in
    if
      is_w
      || (s.[0] = '-' && s.[1] = 'w' && s = "-warn-error")
      || (s.[0] = '-' && s.[1] = '-' && s.[2] = 'w' && s = "-warn-error")
      || (s.[0] = '-' && s.[1] = 'a' && s = "-alert")
      || (s.[0] = '-' && s.[1] = '-' && s.[2] = 'a' && s = "-alert")
    then (
      let s =
        if !idx >= len - 1 then
          if s.[0] = '-' && s.[1] != '-' && String.length s > 2 then "-" ^ s
          else s
        else
          let s =
            if s.[0] = '-' && s.[1] != '-' && String.length s > 2 then "-" ^ s
            else s
          in
          if is_w then
            (* https://github.com/dbuenzli/cmdliner/issues/157 *)
            Format.asprintf "%s%s" s argv.(!idx + 1)
          else Format.asprintf "%s=%s" s argv.(!idx + 1)
      in
      incr idx;
      normalized.(!nidx) <- s;
      incr nidx)
    else if String.length s <= 2 then (
      normalized.(!nidx) <- s;
      incr nidx)
    else if s.[0] = '-' && s.[1] <> '-' then (
      normalized.(!nidx) <- "-" ^ s;
      incr nidx)
    else (
      normalized.(!nidx) <- s;
      incr nidx);
    incr idx
  done;
  if !nidx < len then Array.sub normalized ~pos:0 ~len:!nidx else normalized
