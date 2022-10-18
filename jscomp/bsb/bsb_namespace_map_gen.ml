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

let pp_module_set fmt xs =
  Set_string.iter xs (fun x -> Format.fprintf fmt "%s@\n" x)

(**
  TODO:
  sort filegroupts to ensure deterministic behavior

  if [.bsbuild] is not changed
  [.mlmap] does not need to be changed too

*)
let output oc (namespace : string) (file_groups : Bsb_file_groups.file_groups) =
  let module_set =
    Ext_list.fold_left file_groups Set_string.empty (fun acc x ->
        Map_string.fold x.sources acc (fun k _ acc -> Set_string.add acc k))
  in
  let mlmap_rule =
    Format.asprintf "@\n(rule (with-stdout-to %s%s (run echo \"%a\")))"
      namespace Literals.suffix_mlmap pp_module_set module_set
  in
  output_string oc mlmap_rule
