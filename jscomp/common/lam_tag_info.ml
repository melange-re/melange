(* Copyright (C) 2018-Present Hongbo Zhang, Authors of ReScript
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

(* Similiar to {!Lambda.tag_info}
   In particular,
   it reduces some branches e.g,
   [Blk_some], [Blk_some_not_nested] *)
type t =
  | Blk_tuple
  | Blk_array
  | Blk_poly_var
  | Blk_record of string array
  | Blk_module of string list
  | Blk_extension of { exn : bool }
  | Blk_na of string (* for debugging *)
  | Blk_record_ext of { fields : string array; exn : bool }
  | Blk_record_inlined of {
      name : string;
      num_nonconst : int;
      fields : string array;
      attributes : Parsetree.attributes;
    }
  | Blk_constructor of {
      name : string;
      num_nonconst : int;
      attributes : Parsetree.attributes;
    }
  | Blk_class
  | Blk_module_export

let equal (x : t) y =
  match x with
  | Blk_tuple -> ( match y with Blk_tuple -> true | _ -> false)
  | Blk_array -> ( match y with Blk_array -> true | _ -> false)
  | Blk_poly_var -> ( match y with Blk_poly_var -> true | _ -> false)
  | Blk_record arr1 -> (
      match y with
      | Blk_record arr2 -> Array.equal ~eq:String.equal arr1 arr2
      | _ -> false)
  | Blk_module xs1 -> (
      match y with
      | Blk_module xs2 -> List.equal ~eq:String.equal xs1 xs2
      | _ -> false)
  | Blk_extension { exn = e1 } -> (
      match y with Blk_extension { exn = e2 } -> Bool.equal e1 e2 | _ -> false)
  | Blk_na s1 -> ( match y with Blk_na s2 -> String.equal s1 s2 | _ -> false)
  | Blk_record_ext { fields = fs1; exn = e1 } -> (
      match y with
      | Blk_record_ext { fields = fs2; exn = e2 } ->
          Array.equal ~eq:String.equal fs1 fs2 && Bool.equal e1 e2
      | _ -> false)
  | Blk_record_inlined
      { name = n1; num_nonconst = nc1; fields = fs1; attributes = attrs1 } -> (
      match y with
      | Blk_record_inlined
          { name = n2; num_nonconst = nc2; fields = fs2; attributes = attrs2 }
        ->
          String.equal n1 n2 && Int.equal nc1 nc2
          && Array.equal ~eq:String.equal fs1 fs2
          && List.equal ~eq:( = ) attrs1 attrs2
      | _ -> false)
  | Blk_constructor { name = n1; num_nonconst = nc1; attributes = attrs1 } -> (
      match y with
      | Blk_constructor { name = n2; num_nonconst = nc2; attributes = attrs2 }
        ->
          String.equal n1 n2 && Int.equal nc1 nc2
          && List.equal ~eq:( = ) attrs1 attrs2
      | _ -> false)
  | Blk_class -> ( match y with Blk_class -> true | _ -> false)
  | Blk_module_export -> (
      match y with Blk_module_export -> true | _ -> false)
