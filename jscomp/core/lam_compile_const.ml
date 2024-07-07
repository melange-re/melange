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
module E = Js_exp_make

(** return [val < 0] if not nested [Some (Some (Some None))]*)
let rec is_some_none_aux (x : Lam.Constant.t) acc =
  match x with
  | Const_some v -> is_some_none_aux v (acc + 1)
  | Const_module_alias | Const_js_undefined -> acc
  | _ -> -1

let rec nested_some_none n none =
  if n = 0 then none else nested_some_none (n - 1) (E.optional_block none)

let rec translate_some (x : Lam.Constant.t) : J.expression =
  let depth = is_some_none_aux x 0 in
  if depth < 0 then E.optional_not_nest_block (translate x)
  else nested_some_none depth (E.optional_block (translate Const_js_undefined))

and translate (x : Lam.Constant.t) : J.expression =
  match x with
  | Const_module_alias -> E.undefined (*  TODO *)
  | Const_some s -> translate_some s
  | Const_js_true -> E.bool true
  | Const_js_false -> E.bool false
  | Const_js_null -> E.nil
  | Const_js_undefined -> E.undefined
  | Const_int { i; comment } ->
      E.int i ?comment:(Lam.Constant.string_of_pointer_info comment)
  | Const_char i -> Js_of_lam_string.const_char i
  (* E.float (Int32.to_string i) *)
  | Const_int64 i ->
      (*
            TODO:
       {[
         Int64.to_string 0x7FFFFFFFFFFFFFFFL;;
         - : string = "9223372036854775807"
       ]}
       {[
         Int64.(to_float max_int);;
         - : float = 9.22337203685477581e+18
       ]}
       Note we should compile it to Int64 as JS's
       speical representation --
       it is not representatble in JS number
    *)
      (* E.float (Int64.to_string i) *)
      Js_long.of_const i
      (* https://github.com/google/closure-library/blob/master/closure%2Fgoog%2Fmath%2Flong.js *)
  | Const_nativeint i -> Nativeint.to_int32 i |> E.int
  | Const_float f -> E.float f (* TODO: preserve float *)
  | Const_string { s; unicode = false } -> E.str s
  | Const_string { s; unicode = true } -> E.unicode s
  | Const_pointer name -> E.str name
  | Const_block (tag, tag_info, xs) ->
      Js_of_lam_block.make_block NA tag_info (E.small_int tag)
        (List.map ~f:translate xs)
  | Const_float_array ars ->
      (* according to the compiler
          const_float_array is immutable
         {[ Lprim(Pccall prim_obj_dup, [master]) ]},
          however, we can not translate
         {[ prim_obj_dup(x) =>  x' ]}
          since x' is now mutable, prim_obj_dup does a copy,

          the compiler does this  is mainly to extract common data into data section,
          we  deoptimized this in js backend? so it is actually mutable
      *)
      (* TODO-- *)
      Js_of_lam_array.make_array Mutable (List.map ~f:E.float ars)
(* E.arr Mutable ~comment:"float array" *)
(*   (Ext_list.map (fun x ->  E.float  x ) ars) *)

(* and translate_optional s =
   let  b =
   match s with
   | Const_js_undefined -> E.optional_block (translate s) *)

let translate_arg_cst (cst : Melange_ffi.External_arg_spec.cst) =
  match cst with
  | Arg_int_lit i -> E.int (Int32.of_int i)
  | Arg_string_lit i -> E.str i
  | Arg_js_literal s -> E.raw_js_code (Exp (Js_literal { comment = None })) s
