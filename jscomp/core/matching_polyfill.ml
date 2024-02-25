(* Copyright (C) 2020- Hongbo Zhang, Authors of ReScript
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

let is_nullary_variant (x : Types.constructor_arguments) =
  match x with Types.Cstr_tuple [] -> true | _ -> false

let names_from_construct_pattern
    (pat : Patterns.Head.desc Typedtree.pattern_data) =
  let names_from_type_variant (cstrs : Types.constructor_declaration list) =
    let consts, blocks =
      List.fold_left
        ~f:(fun (consts, blocks) (cstr : Types.constructor_declaration) ->
          if is_nullary_variant cstr.cd_args then
            (Ident.name cstr.cd_id :: consts, blocks)
          else (consts, Ident.name cstr.cd_id :: blocks))
        ~init:([], []) cstrs
    in
    Some
      {
        Lambda.consts = Array.reverse_of_list consts;
        blocks = Array.reverse_of_list blocks;
      }
  in
  let rec resolve_path n path =
    match Env.find_type path pat.pat_env with
    | { type_kind = Type_variant (cstrs, _repr); _ } ->
        names_from_type_variant cstrs
    | { type_kind = Type_abstract _; type_manifest = Some t; _ } -> (
        match Types.get_desc (Ctype.unalias t) with
        | Tconstr (pathn, _, _) ->
            (* Format.eprintf "XXX path%d:%s path%d:%s@." n (Path.name path) (n+1) (Path.name pathn); *)
            resolve_path (n + 1) pathn
        | _ -> None)
    | { type_kind = Type_abstract _; type_manifest = None; _ } -> None
    | { type_kind = Type_record _ | Type_open (* Exceptions *); _ } -> None
  in

  match Types.get_desc pat.pat_type with
  | Tconstr (path, _, _) -> resolve_path 0 path
  | _ -> assert false
