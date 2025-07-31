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

type st = { get : (bool * bool) option; set : [ `Get | `No_get ] option }

val process_method_attributes_rev :
  attribute list -> (st * attribute list, Location.t * string) result

module Kind : sig
  type t =
    | Nothing
    | Meth_callback of attribute
    | Uncurry of attribute
    | Method of attribute
end

val process_attributes_rev : attribute list -> Kind.t * attribute list
val process_pexp_fun_attributes_rev : attribute list -> bool * attribute list
val process_uncurried : attribute list -> bool * attribute list
val is_uncurried : attribute -> bool
val mel_get : attribute
val mel_get_index : attribute
val mel_get_arity : attribute
val mel_set : attribute
val internal_expansive : attribute
val mel_return_undefined : attribute

module Param_modifier : sig
  type kind =
    | Nothing
    | Spread
    | Uncurry of int option (* uncurry arity *)
    | Unwrap
    | Ignore
    | String
    | Int

  type t = { kind : kind; loc : Location.t }
end

val iter_process_mel_param_modifier : attribute list -> Param_modifier.t
val iter_process_mel_string_as : attribute list -> label option
val iter_process_mel_int_as : attribute list -> int option
val has_mel_optional : attribute list -> bool
val has_inline_payload : attribute list -> attribute option
val rs_externals : attribute list -> string list -> bool

val iter_process_mel_as_cst :
  attribute list -> Melange_ffi.External_arg_spec.Arg_cst.t option

val unboxable_type_in_prim_decl : attribute
val ignored_extra_argument : attribute
val unused_type_declaration : attribute
val has_mel_as_payload : attribute list -> attribute list * attribute option
val mel_ffi : Melange_ffi.External_ffi_types.t -> attribute
