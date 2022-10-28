(* Copyright (C) 2017 Hongbo Zhang, Authors of ReScript
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

[@@@warning "+9"]

let ( // ) = Filename.concat

type output_info = {
  module_system : Ext_module_system.t;
  suffix : Ext_js_suffix.t;
}

type batch_info = { path : string; output_info : output_info }

type package_info =
  | Empty
  | Batch_compilation of batch_info list
  | Separate_emission of string

type t = { name : string option; info : package_info }

let is_runtime_name name =
  Ext_string.starts_with name Literals.mel_runtime_package_prefix

let is_runtime_package (x : t) =
  match x.name with Some name -> is_runtime_name name | None -> false

let for_cmj t =
  if is_runtime_package t then
    {
      t with
      info =
        Batch_compilation
          [
            {
              path = "lib/js";
              output_info = { module_system = NodeJS; suffix = Js };
            };
            {
              path = "lib/es6";
              output_info = { module_system = Es6; suffix = Mjs };
            };
          ];
    }
  else t

let same_package_by_name (x : t) (y : t) =
  match (x.name, y.name) with
  | None, None -> true
  | None, Some _ | Some _, None -> false
  | Some s1, Some s2 ->
      (is_runtime_package x && is_runtime_package y) || s1 = s2

(* we don't want force people to use package *)

(**
   TODO: not allowing user to provide such specific package name
   For empty package, [-bs-package-output] does not make sense
   it is only allowed to generate commonjs file in the same directory
*)
let empty : t = { name = None; info = Empty }

let from_name ?(t = empty) (name : string) : t = { t with name = Some name }

let dump_package_info (fmt : Format.formatter)
    ({ path = name; output_info = { module_system = ms; suffix } } : batch_info)
    =
  Format.fprintf fmt "@[%s@ %s@ %s@]"
    (Ext_module_system.to_string ms)
    name
    (Ext_js_suffix.to_string suffix)

let dump_package_name fmt (x : string option) =
  match x with
  | None -> Format.fprintf fmt "@empty_pkg@"
  | Some s -> Format.pp_print_string fmt s

let dump_packages_info (fmt : Format.formatter) ({ name; info } : t) =
  let dump_info fmt info =
    match info with
    | Empty -> Format.fprintf fmt "(empty)"
    | Separate_emission path -> Format.fprintf fmt "Separate(%s)" path
    | Batch_compilation xs ->
        Format.fprintf fmt "Batch %a"
          (Format.pp_print_list
             ~pp_sep:(fun fmt () -> Format.pp_print_space fmt ())
             dump_package_info)
          xs
  in
  Format.fprintf fmt "@[%a;@  @[%a@]@]" dump_package_name name dump_info info

type path_info = { rel_path : string; pkg_rel_path : string }

type package_found_batch_info = {
  path_info : path_info;
  suffix : Ext_js_suffix.t;
}

type package_found_info =
  | Separate of path_info
  | Batch of package_found_batch_info

type info_query =
  | Package_script
  | Package_not_found
  | Package_found of package_found_info

let runtime_package_name = function
  | Some name when is_runtime_name name -> Some Literals.package_name
  | Some name -> Some name
  | None -> None

let path_info = function
  | Batch { path_info; _ } | Separate path_info -> path_info

(* Note that package-name has to be exactly the same as
   npm package name, otherwise the path resolution will be wrong *)
let query_package_infos (t : t) (module_system : Ext_module_system.t) :
    info_query =
  match t.info with
  | Empty -> (
      match t.name with Some _ -> Package_not_found | None -> Package_script)
  | Separate_emission path -> (
      match runtime_package_name t.name with
      | Some pkg_name ->
          Package_found
            (Separate { rel_path = path; pkg_rel_path = pkg_name // path })
      | None ->
          Package_found (Separate { rel_path = path; pkg_rel_path = path }))
  | Batch_compilation module_systems -> (
      match
        Ext_list.find_first_exn module_systems (fun k ->
            Ext_module_system.compatible ~dep:k.output_info.module_system
              module_system)
      with
      | k ->
          let pkg_rel_path =
            match runtime_package_name t.name with
            | Some pkg_name -> pkg_name // k.path
            | None -> k.path
          in
          Package_found
            (Batch
               {
                 path_info = { rel_path = k.path; pkg_rel_path };
                 suffix = k.output_info.suffix;
               })
      | exception Not_found -> (
          match t.name with
          | Some _ -> Package_not_found
          | None -> Package_script))

let get_js_path (module_systems : batch_info list)
    (module_system : Ext_module_system.t) : string =
  let k =
    Ext_list.find_first_exn module_systems (fun k ->
        Ext_module_system.compatible ~dep:k.output_info.module_system
          module_system)
  in
  k.path

(* for a single pass compilation, [output_dir]
   can be cached
*)
let get_output_dir ({ info; _ } : t) ~package_dir module_system =
  match info with
  | Empty | Separate_emission _ -> assert false
  | Batch_compilation specs ->
      Filename.concat package_dir (get_js_path specs module_system)

let add_npm_package_path (packages_info : t) (s : string) : t =
  let existing =
    match packages_info.info with
    | Empty -> []
    | Separate_emission _ -> []
    | Batch_compilation xs -> xs
  in
  match packages_info.info with
  | Empty (* allowed to upgrade *) | Batch_compilation _ ->
      let new_info =
        match Ext_string.split ~keep_empty:true s ':' with
        | [ path ] ->
            (* -bs-package-output just/the/path/segment *)
            Separate_emission path
        | [ module_system; path ] ->
            Batch_compilation
              ({
                 path;
                 output_info =
                   {
                     module_system =
                       Ext_module_system.of_string_exn module_system;
                     suffix = Js;
                   };
               }
              :: existing)
        | [ module_system; path; suffix ] ->
            Batch_compilation
              ({
                 path;
                 output_info =
                   {
                     module_system =
                       Ext_module_system.of_string_exn module_system;
                     suffix = Ext_js_suffix.of_string suffix;
                   };
               }
              :: existing)
        | _ -> raise (Arg.Bad ("invalid npm package path: " ^ s))
      in
      { packages_info with info = new_info }
  | Separate_emission _ ->
      raise
        (Arg.Bad
           "Can't add multiple `-bs-package-output` specs when \
            `-bs-stop-after-cmj` is present")

let default_output_info = { suffix = Js; module_system = NodeJS }

let assemble_output_info ?output_info (t : t) =
  match output_info with
  | Some info -> [ info ]
  | None -> (
      match t.info with
      | Empty -> []
      | Batch_compilation infos ->
          Ext_list.map infos (fun { output_info; _ } -> output_info)
      | Separate_emission _ ->
          (* Combination of `-bs-package-output -just-dir` and the absence of
             `-bs-module-type` *)
          [ default_output_info ])

(* support es6 modules instead
   TODO: enrich ast to support import export
   http://www.ecma-international.org/ecma-262/6.0/#sec-imports
   For every module, we need [Ident.t] for accessing and [filename] for import,
   they are not necessarily the same.

   Es6 modules is not the same with commonjs, we use commonjs currently
   (play better with node)

   FIXME: the module order matters?
*)
