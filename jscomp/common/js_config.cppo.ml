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

let executable_name =
  lazy (Unix.realpath (Ext_path.normalize_absolute_path Sys.executable_name))

let stdlib_paths =
  lazy (
    let root =
#ifndef BS_RELEASE_BUILD
      (* ./bin/melc.exe -> ./ *)
      (Lazy.force executable_name)
      |> Filename.dirname
      |> Filename.dirname
#else
      (* <root>/bin/melc *)
      Lazy.force executable_name
      |> Filename.dirname
      |> Filename.dirname
#endif
    in
    begin match Sys.getenv "MELANGELIB" with
    | value ->
      let dirs =
        String.split_on_char Ext_path.path_sep value
        |> List.filter (fun s -> String.length s > 0)
        |> List.map (fun dir ->
            if Filename.is_relative dir
            then (Filename.dirname (Lazy.force executable_name)) // dir
            else dir)
      in
      begin match List.exists (fun dir -> not (Sys.is_directory dir)) dirs with
      | false -> dirs
      | true -> raise (Arg.Bad "$MELANGELIB should only contain directories")
      | exception Sys_error _ -> raise (Arg.Bad "$MELANGELIB dirs must exist")
      end
    | exception Not_found ->
#ifndef BS_RELEASE_BUILD
      [ root // "jscomp" // "stdlib" // ".stdlib.objs" // Literals.package_name
      ; root // "jscomp" // "runtime" // ".js.objs" // Literals.package_name
      ; root // "jscomp" // "others" // ".belt.objs" // Literals.package_name
      ; root // "jscomp" // "others" // ".dom.objs" // Literals.package_name ]
#else
      [ root // Literals.lib // Literals.package_name // Literals.package_name
      ; root // Literals.lib // Literals.package_name // "js" // Literals.package_name
      ; root // Literals.lib // Literals.package_name // "belt" // Literals.package_name
      ; root // Literals.lib // Literals.package_name // "dom" // Literals.package_name ]
#endif
  end)

(** Browser is not set via command line only for internal use *)


let no_version_header = ref false

let cross_module_inline = ref false
let diagnose = ref false

let no_builtin_ppx = ref false

let tool_name = "Melange"

let check_div_by_zero = ref true
let get_check_div_by_zero () = !check_div_by_zero



let syntax_only = ref false


let debug = ref false

let cmi_only = ref false
let cmj_only = ref false

let force_cmi = ref false
let force_cmj = ref false

let refmt = ref None


let js_stdout = ref true

let all_module_aliases = ref false

let no_stdlib = ref false
let std_include_dirs () =
  (if !no_stdlib then [] else Lazy.force stdlib_paths)

let no_export = ref false

let as_ppx = ref false


(* option to config `@rescript/std`*)
let customize_runtime : string option ref = ref None

let as_pp = ref false

let modules = ref false

let preamble = ref None

