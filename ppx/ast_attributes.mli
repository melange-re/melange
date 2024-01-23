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

type ('a, 'b) st = { get : 'a option; set : 'b option }

val process_method_attributes_rev :
  attribute list ->
  ( (bool * bool, [ `Get | `No_get ]) st * attribute list,
    Location.t * string )
  result

type attr_kind =
  | Nothing
  | Meth_callback of attribute
  | Uncurry of attribute
  | Method of attribute

val warn_if_bs_or_non_namespaced : loc:location -> label -> unit
val process_attributes_rev : attribute list -> attr_kind * attribute list
val process_pexp_fun_attributes_rev : attribute list -> bool * attribute list
val process_uncurried : attribute list -> bool * attribute list
val is_uncurried : attribute -> bool
val mel_get : attribute
val mel_get_index : attribute
val mel_get_arity : attribute
val mel_set : attribute
val internal_expansive : attribute
val has_internal_expansive : attribute list -> bool
val mel_return_undefined : attribute

val iter_process_mel_string_int_unwrap_uncurry :
  attribute list ->
  [ `Nothing | `String | `Int | `Ignore | `Unwrap | `Uncurry of int option ]

val iter_process_mel_string_as : attribute list -> label option
val iter_process_mel_int_as : attribute list -> int option
val has_mel_optional : attribute list -> bool
val has_inline_payload : attribute list -> attribute option
val rs_externals : attribute list -> string list -> bool

type as_const_payload = Int of int | Str of string | Js_literal_str of string

val iter_process_mel_string_or_int_as :
  attribute list -> as_const_payload option

val unboxable_type_in_prim_decl : attribute
val ignored_extra_argument : attribute
val is_mel_as : attribute -> bool
val has_mel_as_payload : attribute list -> attribute list * attribute option
