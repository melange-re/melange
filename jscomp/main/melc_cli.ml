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

type t = {
  include_dirs : string list;
  warnings : string list;
  output_name : string option;
  bs_read_cmi : bool;
  ppx : string list;
  open_modules : string list;
  bs_jsx : int option;
  bs_package_output : string list;
  bs_ast : bool;
  bs_syntax_only : bool;
  bs_g : bool;
  bs_package_name : string option;
  bs_ns : string option;
  as_ppx : bool;
  as_pp : bool;
  no_alias_deps : bool;
  bs_gentype : string option;
  unboxed_types : bool;
  bs_re_out : bool;
  bs_D : string list;
  bs_unsafe_empty_array : bool;
  nostdlib : bool;
  color : string option;
  bs_list_conditionals : bool;
  bs_eval : string option;
  bs_e : string option;
  bs_cmi_only : bool;
  bs_cmi : bool;
  bs_cmj : bool;
  bs_no_version_header : bool;
  bs_no_builtin_ppx : bool;
  bs_cross_module_opt : bool option;
  bs_diagnose : bool;
  format : Ext_file_extensions.syntax_kind option;
  where : bool;
  verbose : bool;
  keep_locs : bool option;
  bs_no_check_div_by_zero : bool;
  bs_noassertfalse : bool;
  noassert : bool;
  bs_loc : bool;
  impl : string option;
  intf : string option;
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
  short_paths : bool;
  unsafe : bool;
  warn_help : bool;
  help : bool;
  warn_error : string list;
  bs_stop_after_cmj : bool;
  runtime : string option;
  make_runtime : bool;
  make_runtime_test : bool;
  filenames : string list;
}

let include_dirs =
  let doc = "Add $(docv) to the list of include directories" in
  let docv = "dir" in
  Arg.(value & opt_all string [] & info [ "I" ] ~doc ~docv)

let warnings =
  let doc =
    "Enable or disable warnings according to $(docv):\n\
     +<spec>   enable warnings in <spec>\n\
     -<spec>   disable warnings in <spec>\n\
     @<spec>   enable warnings in <spec> and treat them as errors\n\
     <spec> can be:\n\
     <num>             a single warning number\n\
     <num1>..<num2>    a range of consecutive warning numbers\n\
     default setting is " ^ Bsc_warnings.defaults_w
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
  Arg.(value & flag & info [ "bs-syntax-only" ] ~doc)

let bs_g =
  let doc = "Debug mode" in
  Arg.(value & flag & info [ "bs-g" ] ~doc)

let bs_package_name =
  let doc = "Set package name, useful when you want to produce npm packages" in
  Arg.(value & opt (some string) None & info [ "bs-package-name" ] ~doc)

let bs_ns =
  let doc =
    "Set package map, not only set package name but also use it as a namespace"
  in
  Arg.(value & opt (some string) None & info [ "bs-ns" ] ~doc)

let unboxed_types =
  let doc = "Unannotated unboxable types will be unboxed" in
  Arg.(value & flag & info [ "unboxed-types" ] ~doc)

let bs_re_out =
  let doc = "Print compiler output in Reason syntax" in
  Arg.(value & flag & info [ "bs-re-out" ] ~doc)

let bs_D =
  let doc = "Define conditional variable e.g, -D DEBUG=true" in
  Arg.(value & opt_all string [] & info [ "bs-D" ] ~doc)

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

let bs_list_conditionals =
  let doc = "List existing conditional variables" in
  Arg.(value & flag & info [ "bs-list-conditionals" ] ~doc)

let bs_e =
  let doc =
    "(experimental) set the string to be evaluated in ReScript syntax"
  in
  Arg.(value & opt (some string) None & info [ "e" ] ~doc)

let format =
  let ext_conv =
    let parse ext =
      match Ext_string.trim ext with
      | "re" -> Ok Ext_file_extensions.Reason
      | "res" -> Ok Res
      | "ml" -> Ok Ml
      | x ->
          Error
            (`Msg
              (Format.asprintf
                 "invalid option `%s` passed to -format, expected `re`, `res` \
                  or `ml`"
                 x))
    in
    let print fmt ext =
      let s =
        match ext with
        | Ext_file_extensions.Reason -> "re"
        | Res -> "res"
        | Ml -> "ml"
      in
      Format.fprintf fmt "%s" s
    in
    Arg.conv ~docv:"ext" (parse, print)
  in
  let doc = "Format as Res syntax" in
  Arg.(value & opt (some ext_conv) None & info [ "format" ] ~doc)

let where =
  let doc = "Print location of standard library and exit" in
  Arg.(value & flag & info [ "where" ] ~doc)

let verbose =
  let doc = "Print calls to external commands" in
  Arg.(value & flag & info [ "verbose" ] ~doc)

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
  Arg.(value & flag & info [ "v"; "version" ] ~doc)

let pp =
  let doc = "Pipe sources through preprocessor $(docv)" in
  let docv = "command" in
  Arg.(value & opt (some string) None & info [ "pp" ] ~doc ~docv)

let absname =
  let doc = "Show absolute filenames in error messages" in
  Arg.(value & flag & info [ "absname" ] ~doc)

let bin_annot =
  Arg.(
    value & vflag None
    & [
        ( Some true,
          info ~doc:"Enable binary annotations (default: on)" [ "bin-annot" ] );
        ( Some false,
          info ~doc:"Disable binary annotations (default: on)"
            [ "bs-no-bin-annot" ] );
      ])

let i =
  let doc = "Print inferred interface" in
  Arg.(value & flag & info [ "i" ] ~doc)

let unsafe =
  let doc = "Do not compile bounds checking on array and string access" in
  Arg.(value & flag & info [ "unsafe" ] ~doc)

let warn_help =
  let doc = "Show description of warning numbers" in
  Arg.(value & flag & info [ "warn-help" ] ~doc)

let warn_error =
  let doc =
    "Enable or disable error status for warnings according\n\
     to $(docv).  See option -w for the syntax of $(docv).\n\
     Default setting is " ^ Bsc_warnings.defaults_warn_error
  in
  Arg.(value & opt_all string [] & info [ "warn-error" ] ~doc)

let bs_stop_after_cmj =
  let doc = "Stop after generating the cmj" in
  Arg.(value & flag & info [ "bs-stop-after-cmj" ] ~doc)

module Internal = struct
  let bs_read_cmi =
    let doc = "*internal* Assume corresponding interface file is present" in
    Arg.(value & flag & info [ "bs-read-cmi" ] ~doc)

  let bs_jsx =
    let doc = "*internal* Set jsx version" in
    Arg.(value & opt (some int) None & info [ "bs-jsx" ] ~doc)

  let bs_package_output =
    let doc =
      "*internal* Set npm-output-path: [opt_module]:path, for example: \
       'lib/cjs', 'amdjs:lib/amdjs', 'es6:lib/es6' "
    in
    Arg.(value & opt_all (string) [] & info [ "bs-package-output" ] ~doc)

  let bs_ast =
    let doc = "*internal* Generate binary .mli_ast and ml_ast and stop" in
    Arg.(value & flag & info [ "bs-ast" ] ~doc)

  let as_ppx =
    let doc = "*internal* As ppx for editor integration" in
    Arg.(value & flag & info [ "as-ppx" ] ~doc)

  let as_pp =
    let doc = "*internal* As pp to interact with native tools" in
    Arg.(value & flag & info [ "as-pp" ] ~doc)

  let no_alias_deps =
    let doc = "*internal*Do not record dependencies for module aliases" in
    Arg.(value & flag & info [ "no-alias-deps" ] ~doc)

  let bs_gentype =
    let doc = "*internal* Pass gentype command" in
    Arg.(value & opt (some string) None & info [ "bs-gentype" ] ~doc)

  let bs_unsafe_empty_array =
    let doc = "*internal* Allow [||] to be polymorphic" in
    Arg.(value & flag & info [ "bs-unsafe-empty-array" ] ~doc)

  let nostdlib =
    let doc = "*internal* Don't use stdlib" in
    Arg.(value & flag & info [ "nostdlib" ] ~doc)

  let bs_eval =
    let doc =
      "*internal* (experimental) set the string to be evaluated in OCaml syntax"
    in
    Arg.(value & opt (some string) None & info [ "bs-eval" ] ~doc)

  let bs_cmi_only =
    let doc = "*internal* Stop after generating cmi file" in
    Arg.(value & flag & info [ "bs-cmi-only" ] ~doc)

  let bs_cmi =
    let doc = "*internal*  Not using cached cmi, always generate cmi" in
    Arg.(value & flag & info [ "bs-cmi" ] ~doc)

  let bs_cmj =
    let doc = "*internal*  Not using cached cmj, always generate cmj" in
    Arg.(value & flag & info [ "bs-cmj" ] ~doc)

  let bs_no_version_header =
    let doc = "*internal*Don't print version header" in
    Arg.(value & flag & info [ "bs-no-version-header" ] ~doc)

  let bs_no_builtin_ppx =
    let doc = "*internal* Disable built-in ppx" in
    Arg.(value & flag & info [ "bs-no-builtin-ppx" ] ~doc)

  let bs_cross_module_opt =
    Arg.(
      value & vflag None
      & [
          ( Some true,
            info
              ~doc:
                "*internal* Enable cross module inlining(experimental), \
                 default(false)"
              [ "bs-cross-module-opt" ] );
          ( Some false,
            info ~doc:"*internal* Disable cross module inlining(experimental)"
              [ "bs-no-cross-module-opt" ] );
        ])

  let bs_diagnose =
    let doc = "*internal* More verbose output" in
    Arg.(value & flag & info [ "bs-diagnose" ] ~doc)

  let bs_no_check_div_by_zero =
    let doc =
      "*internal* unsafe mode, don't check div by zero and mod by zero"
    in
    Arg.(value & flag & info [ "bs-no-check-div-by-zero" ] ~doc)

  let bs_noassertfalse =
    let doc = "*internal*  no code for assert false" in
    Arg.(value & flag & info [ "bs-noassertfalse" ] ~doc)

  let noassert =
    let doc = "*internal* Do not compile assertion checks" in
    Arg.(value & flag & info [ "noassert" ] ~doc)

  let bs_loc =
    let doc =
      "*internal*  dont display location with -dtypedtree, -dparsetree"
    in
    Arg.(value & flag & info [ "bs-loc" ] ~doc)

  let impl =
    let doc = "*internal* Compile $(docv) as a .ml file" in
    let docv = "file" in
    Arg.(value & opt (some string) None & info [ "impl" ] ~doc ~docv)

  let intf =
    let doc = "*internal* <file>  Compile <file> as a .mli file" in
    Arg.(value & opt (some string) None & info [ "intf" ] ~doc)

  let dtypedtree =
    let doc = "*internal* debug typedtree" in
    Arg.(value & flag & info [ "dtypedtree" ] ~doc)

  let dparsetree =
    let doc = "*internal* debug parsetree" in
    Arg.(value & flag & info [ "dparsetree" ] ~doc)

  let drawlambda =
    let doc = "*internal* debug raw lambda" in
    Arg.(value & flag & info [ "drawlambda" ] ~doc)

  let dsource =
    let doc = "*internal* print source" in
    Arg.(value & flag & info [ "dsource" ] ~doc)

  let nopervasives =
    let doc = "*internal*" in
    Arg.(value & flag & info [ "nopervasives" ] ~doc)

  let modules =
    let doc = "*internal* serve similar to ocamldep" in
    Arg.(value & flag & info [ "modules" ] ~doc)

  let nolabels =
    let doc = "*internal* Ignore non-optional labels in types" in
    Arg.(value & flag & info [ "nolabels" ] ~doc)

  let principal =
    let doc = "*internal* Check principality of type inference" in
    Arg.(value & flag & info [ "principal" ] ~doc)

  let short_paths =
    let doc = "*internal* Shorten paths in types" in
    Arg.(value & flag & info [ "short-paths" ] ~doc)

  let runtime =
    let doc = "*internal* Set the runtime directory" in
    Arg.(value & opt (some string) None & info [ "runtime" ] ~doc)

  let make_runtime =
    let doc = "*internal* make runtime library" in
    Arg.(value & flag & info [ "make-runtime" ] ~doc)

  let make_runtime_test =
    let doc = "*internal* make runtime test library" in
    Arg.(value & flag & info [ "make-runtime-test" ] ~doc)
end

let filenames =
  let docv = "filenames" in
  Arg.(value & pos_all string [] & info [] ~docv)

let help =
  let doc =
    "Show this help. The format is pager or plain whenever the TERM env var is \
     dumb or undefined."
  in
  Arg.(value & flag & info [ "h" ] ~doc)

module Compat = struct
  (* The args in this module are accepted by the CLI but ignored. They exist
   * for compatibility with currently published packages. *)

  let doc = "Ignored. Kept for compatibility"
  let bs_super_errors = Arg.(value & flag & info [ "bs-super-errors" ] ~doc)
  let c = Arg.(value & flag & info [ "c" ] ~doc)
end

let parse help include_dirs warnings output_name bs_read_cmi ppx open_modules
    bs_jsx bs_package_output bs_ast bs_syntax_only bs_g bs_package_name bs_ns
    as_ppx as_pp no_alias_deps bs_gentype unboxed_types bs_re_out bs_D
    bs_unsafe_empty_array nostdlib color bs_list_conditionals bs_eval bs_e
    bs_cmi_only bs_cmi bs_cmj bs_no_version_header bs_no_builtin_ppx
    bs_cross_module_opt bs_diagnose format where verbose keep_locs
    bs_no_check_div_by_zero bs_noassertfalse noassert bs_loc impl intf
    dtypedtree dparsetree drawlambda dsource version pp absname bin_annot i
    nopervasives modules nolabels principal short_paths unsafe warn_help
    warn_error bs_stop_after_cmj runtime make_runtime make_runtime_test
    filenames _bs_super_errors _c =
  {
    help;
    include_dirs;
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
    impl;
    intf;
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
  }

let cmd =
  Term.(
    const parse $ help $ include_dirs $ warnings $ output_name
    $ Internal.bs_read_cmi $ ppx $ open_modules $ Internal.bs_jsx
    $ Internal.bs_package_output $ Internal.bs_ast $ bs_syntax_only $ bs_g
    $ bs_package_name $ bs_ns $ Internal.as_ppx $ Internal.as_pp
    $ Internal.no_alias_deps $ Internal.bs_gentype $ unboxed_types $ bs_re_out
    $ bs_D $ Internal.bs_unsafe_empty_array $ Internal.nostdlib $ color
    $ bs_list_conditionals $ Internal.bs_eval $ bs_e $ Internal.bs_cmi_only
    $ Internal.bs_cmi $ Internal.bs_cmj $ Internal.bs_no_version_header
    $ Internal.bs_no_builtin_ppx $ Internal.bs_cross_module_opt
    $ Internal.bs_diagnose $ format $ where $ verbose $ keep_locs
    $ Internal.bs_no_check_div_by_zero $ Internal.bs_noassertfalse
    $ Internal.noassert $ Internal.bs_loc $ Internal.impl $ Internal.intf
    $ Internal.dtypedtree $ Internal.dparsetree $ Internal.drawlambda
    $ Internal.dsource $ version $ pp $ absname $ bin_annot $ i
    $ Internal.nopervasives $ Internal.modules $ Internal.nolabels
    $ Internal.principal $ Internal.short_paths $ unsafe $ warn_help
    $ warn_error $ bs_stop_after_cmj $ Internal.runtime $ Internal.make_runtime
    $ Internal.make_runtime_test $ filenames $ Compat.bs_super_errors $ Compat.c)

(* Different than Ext_cli_args because we need to normalize `-w -foo` to
 * `-w=-foo` *)
let separator = "--"
let is_number = function '0' .. '9' -> true | _ -> false

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
  if !nidx < len then Array.sub normalized 0 !nidx else normalized

let split_argv_at_separator argv =
  let len = Array.length argv in
  let i = Ext_array.rfind_with_index argv Ext_string.equal separator in
  if i < 0 then (argv, [||])
  else (Array.sub argv 0 i, Array.sub argv (i + 1) (len - i - 1))
