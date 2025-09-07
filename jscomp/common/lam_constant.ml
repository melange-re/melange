(* Copyright (C) 2018- Hongbo Zhang, Authors of ReScript
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

type pointer_info =
  | None
  | Pt_constructor of { name : Lambda.cstr_name; const : int; non_const : int }
  | Pt_assertfalse
  | Some of string

let comment_of_pointer_info (x : pointer_info) : string option =
  match x with
  | Some name -> Some name
  | Pt_constructor { name = { Lambda.name; _ }; _ } -> Some name
  | Pt_assertfalse -> Some "assert_false"
  | None -> None

let modifier_of_pointer_info (x : pointer_info) : Lambda.as_modifier option =
  match x with
  | Pt_constructor { name = { as_modifier = Some modifier; _ }; _ } ->
      Some modifier
  | Pt_constructor { name = { as_modifier = None; _ }; _ }
  | Pt_assertfalse | Some _ | None ->
      None

type t =
  | Const_js_null
  | Const_js_undefined of { is_unit : bool }
  | Const_js_true
  | Const_js_false
  | Const_int of { i : int32; comment : pointer_info }
  | Const_char of char
  | Const_string of { s : string; unicode : bool }
  | Const_float of string
  | Const_int64 of int64
  | Const_pointer of string
  | Const_block of int * Lam_tag_info.t * t list
  | Const_float_array of string list
  | Const_some of t
  | Const_module_alias
(* eventually we can remove it, since we know
   [constant] is [undefined] or not *)

let rec eq_approx (x : t) (y : t) =
  match (x, y) with
  | Const_module_alias, Const_module_alias -> true
  | Const_js_null, Const_js_null -> true
  | Const_js_undefined { is_unit = u1 }, Const_js_undefined { is_unit = u2 } ->
      Bool.equal u1 u2
  | Const_js_true, Const_js_true -> true
  | Const_js_false, Const_js_false -> true
  | Const_int ix, Const_int iy -> Int32.equal ix.i iy.i
  | Const_char ix, Const_char iy -> Char.equal ix iy
  | Const_string { s = sx; unicode = ux }, Const_string { s = sy; unicode = uy }
    ->
      String.equal sx sy && Bool.equal ux uy
  | Const_float ix, Const_float iy -> String.equal ix iy
  | Const_int64 ix, Const_int64 iy -> Int64.equal ix iy
  | Const_pointer ix, Const_pointer iy -> String.equal ix iy
  | Const_block (ix, _, ixs), Const_block (iy, _, iys) ->
      Int.equal ix iy && List.for_all2_no_exn ixs iys ~f:eq_approx
  | Const_float_array ixs, Const_float_array iys ->
      List.for_all2_no_exn ~f:String.equal ixs iys
  | Const_some ix, Const_some iy -> eq_approx ix iy
  | _, _ -> false

let lam_none : t = Const_js_undefined { is_unit = false }
