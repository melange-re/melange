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
module Set_string = Depend.String.Set

(* FIXME: [Clflags.open_modules] seems not to be properly used *)
module SMap = Depend.String.Map

let bound_vars = SMap.empty

let ref_protect r v body =
  let old = !r in
  try
    r := v;
    let res = body () in
    r := old;
    res
  with x ->
    r := old;
    raise x

let read_parse_and_extract (type t) (k : t Ml_binary.kind) (ast : t) :
    Set_string.t =
  Depend.free_structure_names := Set_string.empty;
  ref_protect
#if OCAML_VERSION >= (5, 4, 0)
    Clflags.no_alias_deps
#else
    Clflags.transparent_modules
#endif
    false (fun _ ->
      List.iter (* check *)
        ~f:(fun modname ->
          ignore @@ Depend.open_module bound_vars (Longident.Lident modname))
        !Clflags.open_modules;
      (match k with
      | Ml_binary.Ml -> Depend.add_implementation bound_vars ast
      | Ml_binary.Mli -> Depend.add_signature bound_vars ast);
      !Depend.free_structure_names)

let output_deps_set name k ast =
  let set = read_parse_and_extract k ast in
  output_string stdout name;
  output_string stdout ": ";
  Depend.String.Set.iter
    (fun s ->
      if s <> "" && s.[0] <> '*' then (
        output_string stdout s;
        output_string stdout " "))
    set;
  output_string stdout "\n"
