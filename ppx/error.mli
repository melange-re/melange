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

type t =
  | Unsupported_predicates
  | Conflict_u_mel_this_mel_meth
  | Conflict_attributes
  | Duplicated_mel_as
  | Expect_int_literal
  | Expect_string_literal
  | Expect_int_or_string_or_json_literal
  | Unhandled_poly_type
  | Invalid_underscore_type_in_external
  | Invalid_mel_string_type
  | Invalid_mel_int_type
  | Invalid_mel_unwrap_type
  | Conflict_ffi_attribute of string
  | Cannot_infer_arity_by_syntax
  | Inconsistent_arity of { uncurry_attribute : int; real : int }
  (* We require users to explicit annotate to avoid
     {[ (((int -> int) -> int) -> int )]} *)
  | Not_supported_directive_in_mel_return
  | Expect_opt_in_mel_return_to_opt
  | Misplaced_label_syntax
  | Optional_in_uncurried_mel_attribute
  | Mel_this_simple_pattern
  | Mel_uncurried_arity_too_large

val pp_error : Format.formatter -> t -> unit
val err : loc:Location.t -> t -> 'a
val optional_err : loc:Location.t -> Asttypes.arg_label -> unit
val err_if_label : loc:Location.t -> Asttypes.arg_label -> unit
val err_large_arity : loc:Location.t -> int -> unit
