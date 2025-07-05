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

open Import

let executable_name =
  lazy (Unix.realpath (Paths.normalize_absolute_path Sys.executable_name))

let stdlib_paths =
  let ( // ) = Paths.( // ) in
  let package_name = "melange" in
  lazy
    (match Sys.getenv "MELANGELIB" with
    | value -> (
        let dirs =
          String.split_on_char ~sep:Paths.path_sep value
          |> List.filter_map ~f:(function
            | "" -> None
            | dir ->
                Some
                  (if Filename.is_relative dir then
                     Filename.dirname (Lazy.force executable_name) // dir
                   else dir))
        in

        match List.exists ~f:(fun dir -> not (Sys.is_directory dir)) dirs with
        | false -> dirs
        | true -> raise (Arg.Bad "$MELANGELIB should only contain directories")
        | exception Sys_error _ -> raise (Arg.Bad "$MELANGELIB dirs must exist")
        )
    | exception Not_found ->
        let root =
          (* <root>/bin/melc *)
          Lazy.force executable_name |> Filename.dirname |> Filename.dirname
        in
        (* <root>/<path>/melange *)
        List.map
          ~f:(fun path -> root // path // package_name)
          Include_dirs.paths)

let no_version_header = ref false
let cross_module_inline = ref false
let diagnose = ref false
let tool_name = "Melange"
let check_div_by_zero = ref true
let syntax_only = ref false
let cmi_only = ref false
let cmj_only = ref false
let js_stdout = ref true
let all_module_aliases = ref false
let no_stdlib = ref false
let std_include_dirs () = if !no_stdlib then [] else Lazy.force stdlib_paths
let no_export = ref false
let as_ppx = ref false
let as_pp = ref false
let modules = ref false
let preamble = ref None
