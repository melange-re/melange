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

type env_value =
  | Ml of { id : Ident.t; cmj_load_info : Js_cmj_format.cmj_load_info }
  | External of Ident.t
      (** Also a js file, but this belong to third party we never load
          runtime/*.cmj *)

(*
   refer: [Env.find_pers_struct]
   [ find_in_path_uncap !load_path (name ^ ".cmi")]
*)

(** It stores module => env_value mapping *)
let cached_tbl : env_value Lam_module_ident.Hashtbl.t =
  Lam_module_ident.Hashtbl.create 31

(* For each compilation we need reset to make it re-entrant *)
let reset () =
  Translmod.reset ();
  Js_config.no_export := false;
  (* This is needed in the playground since one no_export can make it true
     In the payground, it seems we need reset more states
  *)
  Lam_module_ident.Hashtbl.clear cached_tbl

(** We should not provide "#moduleid" as output
    since when we print it in the end, it will
    be escaped quite ugly
*)
let add_js_module (hint_name : Melange_ffi.External_ffi_types.module_bind_name)
    (module_name : string) ~default ~dynamic_import : Ident.t =
  let lam_module_ident : Lam_module_ident.t =
    let module_id =
      Ident.create_local
        (match hint_name with
        | Phint_name hint_name -> String.capitalize_ascii hint_name
        (* make sure the module name is capitalized
           TODO: maybe a warning if the user hint is not good *)
        | Phint_nothing -> Modulename.js_id_name_of_hint_name module_name)
    in
    Lam_module_ident.external_ module_id ~dynamic_import ~name:module_name
      ~default
  in
  match Lam_module_ident.Hashtbl.find cached_tbl lam_module_ident with
  | Ml { id; cmj_load_info = _ } | External id -> id
  | exception Not_found ->
      let module_id = lam_module_ident.id in
      Lam_module_ident.Hashtbl.replace cached_tbl lam_module_ident
        (External module_id);
      module_id

let query_external_id_info_exn ~dynamic_import (module_id : Ident.t)
    (name : string) : Js_cmj_format.keyed_cmj_value =
  let oid = Lam_module_ident.of_ml ~dynamic_import module_id in
  let cmj_table =
    match Lam_module_ident.Hashtbl.find_opt cached_tbl oid with
    | None ->
        let cmj_load_info = Js_cmj_format.load_unit (Ident.name module_id) in
        Lam_module_ident.Hashtbl.replace cached_tbl oid
          (Ml { cmj_load_info; id = module_id });
        cmj_load_info.cmj_table
    | Some (Ml { cmj_load_info = { cmj_table; _ }; id = _ }) -> cmj_table
    | Some (External _) -> assert false
  in
  Js_cmj_format.query_by_name cmj_table name

let query_external_id_info ~dynamic_import module_id name =
  try Some (query_external_id_info_exn ~dynamic_import module_id name)
  with Mel_exception.Error (Cmj_not_found _) -> None

let get_dependency_info_from_cmj (module_id : Lam_module_ident.t) :
    Js_packages_info.t * Js_packages_info.file_case =
  let cmj_load_info =
    match Lam_module_ident.Hashtbl.find_opt cached_tbl module_id with
    | Some (Ml { cmj_load_info; id = _ }) -> cmj_load_info
    | Some (External _) -> assert false
    (* called by {!Js_name_of_module_id.string_of_module_id}
       can not be External *)
    | None -> (
        match module_id.kind with
        | Runtime | External _ -> assert false
        | Ml ->
            let cmj_load_info =
              Js_cmj_format.load_unit (Lam_module_ident.name module_id)
            in
            Lam_module_ident.Hashtbl.replace cached_tbl module_id
              (Ml { cmj_load_info; id = module_id.id });
            cmj_load_info)
  in
  let cmj_table = cmj_load_info.cmj_table in
  (cmj_table.package_spec, cmj_table.case)

(* Conservative interface *)
let is_pure_module (oid : Lam_module_ident.t) =
  match oid.kind with
  | Runtime -> true
  | External _ -> false
  | Ml -> (
      match Lam_module_ident.Hashtbl.find_opt cached_tbl oid with
      | None -> (
          match Js_cmj_format.load_unit (Lam_module_ident.name oid) with
          | cmj_load_info ->
              Lam_module_ident.Hashtbl.replace cached_tbl oid
                (Ml { cmj_load_info; id = oid.id });
              cmj_load_info.cmj_table.pure
          | exception _ -> false)
      | Some (Ml { cmj_load_info = { cmj_table; _ }; id = _ }) -> cmj_table.pure
      | Some (External _) -> false)

let add = Lam_module_ident.Hash_set.add

let populate_required_modules extras
    (hard_dependencies : Lam_module_ident.Hash_set.t) =
  Lam_module_ident.Hashtbl.iter
    (fun id _ -> if not (is_pure_module id) then add hard_dependencies id)
    cached_tbl;
  Lam_module_ident.Hash_set.iter extras ~f:(fun id ->
      if not (is_pure_module id) then add hard_dependencies id)
