(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
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

let (//) = Ext_path.combine

#ifndef BS_RELEASE_BUILD
let executable_name =
  lazy (Unix.realpath (Ext_path.normalize_absolute_path Sys.executable_name))
#endif

let install_dir = lazy (
#ifdef BS_RELEASE_BUILD
  (* we start in `<install-dir>/bin/bsc.exe`.
     (dirname (dirname executable)) == <install-dir> *)
  Filename.(dirname (dirname Sys.executable_name))
#else
  (* <root>/jscomp/main/bsc.exe -> <root> *)
  Filename.(dirname (dirname (Lazy.force executable_name)))
#endif
)

let stdlib_path =
  lazy (match Sys.getenv "MELANGELIB" with
  | value -> value
  | exception _ -> Lazy.force install_dir // Literals.lib // "melange")

let include_dirs =

#ifndef BS_RELEASE_BUILD
  let root =
    (* ./jscomp/main/melc.exe -> ./ *)
    (Lazy.force executable_name)
    |> Filename.dirname
    |> Filename.dirname
    |> Filename.dirname
  in
  [ (root // Literals.lib // Literals.package_name)
  ; (Lazy.force stdlib_path)
  ]
#else
  []
#endif

(** Browser is not set via command line only for internal use *)


let no_version_header = ref false

let cross_module_inline = ref false



let diagnose = ref false
let get_diagnose () =
    !diagnose
#ifndef BS_RELEASE_BUILD
  || Sys.getenv_opt "RES_DEBUG_FILE" <> None
#endif

let no_builtin_ppx = ref false

let tool_name = "Melange"

let check_div_by_zero = ref true
let get_check_div_by_zero () = !check_div_by_zero



let syntax_only = ref false
let binary_ast = ref false



let debug = ref false

let cmi_only = ref false
let cmj_only = ref false

let force_cmi = ref false
let force_cmj = ref false

let jsx_version = ref (-1)

let refmt = ref None


let js_stdout = ref true

let all_module_aliases = ref false

let no_stdlib = ref false

let no_export = ref false

let as_ppx = ref false


(* option to config `@rescript/std`*)
let customize_runtime : string option ref = ref None

let as_pp = ref false

let modules = ref false
