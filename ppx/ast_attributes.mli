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

type attr = Parsetree.attribute
type t = attr list
type ('a, 'b) st = { get : 'a option; set : 'b option }

val process_method_attributes_rev :
  t -> ((bool * bool, [ `Get | `No_get ]) st * t, Location.t * string) result

type attr_kind =
  | Nothing
  | Meth_callback of attr
  | Uncurry of attr
  | Method of attr

val warn_if_non_namespaced : loc:location -> label -> unit
val process_attributes_rev : t -> attr_kind * t
val process_pexp_fun_attributes_rev : t -> bool * t
val process_uncurried : t -> bool * t
val is_uncurried : attr -> bool
val mel_get : attr
val mel_get_index : attr
val mel_get_arity : attr
val mel_set : attr
val internal_expansive : attr
val has_internal_expansive : t -> bool
val mel_return_undefined : attr

val iter_process_mel_string_int_unwrap_uncurry :
  t -> [ `Nothing | `String | `Int | `Ignore | `Unwrap | `Uncurry of int option ]

val iter_process_mel_string_as : t -> label option
val iter_process_mel_int_as : t -> int option
val has_mel_optional : t -> bool
val has_inline_payload : t -> attr option
val rs_externals : t -> string list -> bool

type as_const_payload = Int of int | Str of string | Js_literal_str of string

val iter_process_mel_string_or_int_as : t -> as_const_payload option
val unboxable_type_in_prim_decl : attr
val ignored_extra_argument : attr
val is_mel_as : attr -> bool
val has_mel_as_payload : t -> attr list * attr option
