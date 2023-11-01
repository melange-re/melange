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

open Import

let ( // ) = Path.( // )

type file_case = Uppercase | Lowercase
type output_info = { module_system : Module_system.t; suffix : Js_suffix.t }
type batch_info = { path : string; output_info : output_info }

type package_info =
  | Empty
  | Batch_compilation of batch_info list
  | Separate_emission of { module_path : string; module_name : string option }

type t = { name : string option; info : package_info }

let same_package_by_name (x : t) (y : t) =
  match (x.name, y.name) with
  | None, None -> true
  | None, Some _ | Some _, None -> false
  | Some s1, Some s2 -> s1 = s2

(* we don't want force people to use package *)

(**
   TODO: not allowing user to provide such specific package name
   For empty package, [-mel-package-output] does not make sense
   it is only allowed to generate commonjs file in the same directory
*)
let empty : t = { name = None; info = Empty }

let from_name ?(t = empty) (name : string) : t = { t with name = Some name }

let dump_output_info fmt { module_system; suffix } =
  Format.fprintf fmt "%s %s"
    (Module_system.to_string module_system)
    (Js_suffix.to_string suffix)

let dump_package_info (fmt : Format.formatter)
    ({ path = name; output_info } : batch_info) =
  Format.fprintf fmt "@[%s@ %a@]" name dump_output_info output_info

let dump_package_name fmt (x : string option) =
  match x with
  | None -> Format.fprintf fmt "@empty_pkg@"
  | Some s -> Format.pp_print_string fmt s

let dump_packages_info (fmt : Format.formatter) ({ name; info } : t) =
  let dump_info fmt info =
    match info with
    | Empty -> Format.fprintf fmt "(empty)"
    | Separate_emission { module_path; module_name } ->
        Format.fprintf fmt "Separate(module_path: %s, module_name: %a)"
          module_path
          (Format.pp_print_option
             ~none:(fun fmt () -> Format.fprintf fmt "*none*")
             Format.pp_print_string)
          module_name
    | Batch_compilation xs ->
        Format.fprintf fmt "Batch %a"
          (Format.pp_print_list
             ~pp_sep:(fun fmt () -> Format.pp_print_space fmt ())
             dump_package_info)
          xs
  in
  Format.fprintf fmt "@[%a;@  @[%a@]@]" dump_package_name name dump_info info

type path_info = {
  rel_path : string;
  pkg_rel_path : string;
  module_name : string option;
}

type info_query =
  | Package_script
  | Package_not_found
  | Package_found of path_info

(* Note that package-name has to be exactly the same as
   npm package name, otherwise the path resolution will be wrong *)
let query_package_infos (t : t) (module_system : Module_system.t) : info_query =
  match t.info with
  | Empty -> (
      match t.name with Some _ -> Package_not_found | None -> Package_script)
  | Separate_emission { module_path; module_name } -> (
      match t.name with
      | Some pkg_name ->
          Package_found
            {
              rel_path = module_path;
              pkg_rel_path = pkg_name // module_path;
              module_name;
            }
      | None ->
          Package_found
            { rel_path = module_path; pkg_rel_path = module_path; module_name })
  | Batch_compilation module_systems -> (
      match
        List.find
          ~f:(fun k ->
            Module_system.compatible ~dep:k.output_info.module_system
              module_system)
          module_systems
      with
      | k ->
          let pkg_rel_path =
            match t.name with
            | Some pkg_name -> pkg_name // k.path
            | None -> k.path
          in
          Package_found { rel_path = k.path; pkg_rel_path; module_name = None }
      | exception Not_found -> (
          match t.name with
          | Some _ -> Package_not_found
          | None -> Package_script))

let get_js_path (module_systems : batch_info list)
    (module_system : Module_system.t) : string =
  let k =
    List.find
      ~f:(fun k ->
        Module_system.compatible ~dep:k.output_info.module_system module_system)
      module_systems
  in
  k.path

(* XXX(anmonteiro): used for es6-global, which we also need to fix. *)
let get_output_dir ({ info; _ } : t) ~package_dir module_system =
  match info with
  | Empty | Separate_emission _ -> assert false
  | Batch_compilation specs -> package_dir // get_js_path specs module_system

let add_npm_package_path (t : t) ?module_name s =
  match t.info with
  | Empty (* allowed to upgrade *) | Batch_compilation _ ->
      let existing =
        match t.info with
        | Empty -> []
        | Separate_emission _ -> []
        | Batch_compilation xs -> xs
      in
      let new_info =
        match String.split ~keep_empty:true s ':' with
        | [ path ] ->
            (* `--mel-package-output just/the/path/segment' means module system
               / js extension to come later; separate emission *)
            Separate_emission { module_path = path; module_name }
        | [ module_system; path ] ->
            (* `--mel-package-output module_system:the/path/segment' assumes
               `.js' extension. This is batch compilation (`.cmj' + `.js'
               emitted). *)
            Batch_compilation
              ({
                 path;
                 output_info =
                   {
                     module_system = Module_system.of_string_exn module_system;
                     suffix = Js_suffix.default;
                   };
               }
              :: existing)
        | [ module_system; path; suffix ] ->
            (* `--mel-package-output module_system:the/path/segment:.ext', batch
               compilation with all info. *)
            Batch_compilation
              ({
                 path;
                 output_info =
                   {
                     module_system = Module_system.of_string_exn module_system;
                     suffix = Js_suffix.of_string suffix;
                   };
               }
              :: existing)
        | _ -> raise (Arg.Bad ("invalid npm package path: " ^ s))
      in
      { t with info = new_info }
  | Separate_emission _ ->
      raise
        (Arg.Bad
           "Can't add multiple `--mel-package-output` specs when \
            `--mel-stop-after-cmj` is present")

let is_lower_case c =
  (c >= 'a' && c <= 'z')
  || (c >= (* à *) '\224' && c <= (* ö *) '\246')
  || (c >= (* ø *) '\248' && c <= (* ÿ *) '\255')

let module_case t ~output_prefix =
  let module_name =
    match t.info with
    | Separate_emission { module_name = Some module_name; _ } -> module_name
    | Separate_emission { module_name = None; _ } | Empty | Batch_compilation _
      ->
        Filename.basename output_prefix
  in
  match is_lower_case module_name.[0] with
  | true -> Lowercase
  | false -> Uppercase

let default_output_info =
  { suffix = Js_suffix.default; module_system = Module_system.default }

let assemble_output_info (t : t) =
  match t.info with
  | Empty -> [ default_output_info ]
  | Batch_compilation infos ->
      List.map ~f:(fun { output_info; _ } -> output_info) infos
  | Separate_emission _ ->
      (* Combination of `-mel-package-output -just-dir` and the absence of
         `-mel-module-type` *)
      [ default_output_info ]

(* support es6 modules instead
   TODO: enrich ast to support import export
   http://www.ecma-international.org/ecma-262/6.0/#sec-imports
   For every module, we need [Ident.t] for accessing and [filename] for import,
   they are not necessarily the same.

   Es6 modules is not the same with commonjs, we use commonjs currently
   (play better with node)

   FIXME: the module order matters?
*)
