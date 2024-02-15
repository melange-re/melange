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

let jsop_of_comp (cmp : Lam_compat.integer_comparison) : Js_op.binop =
  match cmp with
  | Ceq -> EqEqEq (* comparison*)
  | Cne -> NotEqEq
  | Clt -> Lt
  | Cgt -> Gt
  | Cle -> Le
  | Cge -> Ge

let jsop_of_float_comp (cmp : Lam_compat.float_comparison) : Js_op.binop =
  match cmp with
  | CFeq -> EqEqEq
  | CFneq -> NotEqEq
  | CFlt -> Lt
  | CFnlt -> Ge
  | CFgt -> Gt
  | CFngt -> Le
  | CFle -> Le
  | CFnle -> Gt
  | CFge -> Ge
  | CFnge -> Lt

let comment_of_tag_info (x : Lam.Tag_info.t) =
  match x with
  | Blk_constructor { name = n; _ } -> Some n
  | Blk_tuple -> Some "tuple"
  | Blk_class -> Some "class"
  | Blk_poly_var -> None
  | Blk_record _ -> None
  | Blk_record_inlined { name = ctor; _ } -> Some ctor
  | Blk_record_ext _ -> None
  | Blk_array ->
      (* so far only appears in {!Translclass}
         and some constant immutable array block
      *)
      Some "array"
  | Blk_module_export | Blk_module _ ->
      (* Turn it on next time to save some noise diff*)
      None
  | Blk_extension (* TODO: enhance it later *) -> None
  | Blk_na s -> if s = "" then None else Some s

(* let module_alias = Some "alias"   *)
