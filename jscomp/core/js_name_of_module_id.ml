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

let fix_path_for_windows : string -> string =
  let replace_backward_slash (x : string) =
    match String.index x '\\' with
    | _i -> String.map ~f:(function '\\' -> '/' | x -> x) x
    | exception Not_found -> x
  in
  if Sys.win32 || Sys.cygwin then replace_backward_slash else fun s -> s

let js_name_of_modulename s (case : Js_packages_info.file_case) suffix : string
    =
  let s =
    match case with Lowercase -> String.uncapitalize_ascii s | Uppercase -> s
  in
  s ^ Js_suffix.to_string suffix

let js_file_name ~(path_info : Js_packages_info.path_info) ~case ~suffix
    (dep_module_id : Lam_module_ident.t) =
  let module_name =
    match path_info.module_name with
    | Some module_name -> module_name
    | None -> Ident.name dep_module_id.id
  in
  js_name_of_modulename module_name case suffix

(* dependency is runtime module *)
let get_runtime_module_path ~package_info ~output_info
    (dep_module_id : Lam_module_ident.t) =
  let { Js_packages_info.module_system; suffix } = output_info in
  let js_file =
    js_name_of_modulename (Ident.name dep_module_id.id) Lowercase suffix
  in
  match Js_packages_info.query_package_infos package_info module_system with
  | Package_not_found -> assert false
  | Package_script -> Module_system.runtime_package_path js_file
  | Package_found _path_info -> (
      match module_system with
      | CommonJS | ESM -> Module_system.runtime_package_path js_file
      (* Note we did a post-processing when working on Windows *)
      | ESM_global ->
          (* lib/ocaml/xx.cmj --
              HACKING: FIXME
              maybe we can caching relative package path calculation or employ package map *)
          let dep_path =
            "lib"
            (* // Module_system.runtime_dir module_system  *)
          in
          (* TODO(anmonteiro): This doesn't work yet *)
          Path.rel_normalized_absolute_path
            ~from:
              (Js_packages_info.get_output_dir
                 package_info (* ~package_dir:(Lazy.force Path.package_dir) *)
                 ~package_dir:(Sys.getcwd ()) module_system)
            (* Invariant: the package path to `node_modules/melange`, it is used to
               calculate relative js path *)
            (Filename.dirname (Filename.dirname Sys.executable_name)
            // dep_path // js_file))

(* [output_dir] is decided by the command line argument *)
let string_of_module_id ~package_info ~output_info
    (dep_module_id : Lam_module_ident.t) ~(output_dir : string) : string =
  let { Js_packages_info.module_system; suffix } = output_info in
  fix_path_for_windows
    (match dep_module_id.kind with
    | External { name; _ } -> name (* the literal string for external package *)
    (* This may not be enough,
        1. For cross packages, we may need settle
        down a single js package
        2. We may need es6 path for dead code elimination
         But frankly, very few JS packages have no dependency,
         so having plugin may sound not that bad
    *)
    | Runtime ->
        get_runtime_module_path ~package_info ~output_info dep_module_id
    | Ml -> (
        let dep_package_info, case =
          Lam_compile_env.get_dependency_info_from_cmj dep_module_id
        in
        match
          ( Js_packages_info.query_package_infos dep_package_info module_system,
            Js_packages_info.query_package_infos package_info module_system )
        with
        | _, Package_not_found ->
            (* Impossible to not find the current package. *)
            assert false
        | Package_not_found, _ ->
            Mel_exception.error
              (Missing_ml_dependency (Ident.name dep_module_id.id))
        | Package_script, Package_found _ ->
            Mel_exception.error
              (Dependency_script_module_dependent_not
                 (Ident.name dep_module_id.id))
        | Package_found path_info, Package_script ->
            let js_file = js_file_name ~case ~suffix ~path_info dep_module_id in
            path_info.pkg_rel_path // js_file
        | Package_found dep_info, Package_found cur_pkg -> (
            let js_file =
              js_file_name ~case ~suffix ~path_info:dep_info dep_module_id
            in
            match
              Js_packages_info.same_package_by_name package_info
                dep_package_info
            with
            | true ->
                (* If this is the same package, we know all imports are
                   relative. *)
                Path.node_rebase_file ~from:cur_pkg.rel_path
                  ~to_:dep_info.rel_path js_file
            | false -> (
                match module_system with
                | CommonJS | ESM -> dep_info.pkg_rel_path // js_file
                (* Note we did a post-processing when working on Windows *)
                | ESM_global ->
                    Path.rel_normalized_absolute_path
                      ~from:
                        (Js_packages_info.get_output_dir
                           package_info
                           (* ~package_dir:(Lazy.force Path.package_dir) *)
                           (* FIXME *)
                           ~package_dir:(Sys.getcwd ()) module_system)
                      (* FIXME: https://github.com/melange-re/melange/issues/559 *)
                      ("$package_path" // dep_info.rel_path // js_file)))
        | Package_script, Package_script -> (
            let js_file =
              js_name_of_modulename
                (Ident.name dep_module_id.id)
                case Js_suffix.default
            in
            match Initialization.find_in_path_exn js_file with
            | file ->
                let basename = Filename.basename file in
                let dirname = Filename.dirname file in
                Path.node_rebase_file
                  ~from:(Path.absolute_cwd_path output_dir)
                  ~to_:(Path.absolute_cwd_path dirname)
                  basename
            | exception Not_found -> Mel_exception.error (Js_not_found js_file))
        ))
