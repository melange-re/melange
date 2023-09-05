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

open Ppxlib

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
  | Canot_infer_arity_by_syntax
  | Illegal_attribute
  | Inconsistent_arity of int * int
  (* we still rqeuire users to have explicit annotation to avoid
     {[ (((int -> int) -> int) -> int )]}
  *)
  | Not_supported_directive_in_mel_return
  | Expect_opt_in_mel_return_to_opt
  | Misplaced_label_syntax
  | Optional_in_uncurried_mel_attribute
  | Mel_this_simple_pattern
  | Mel_uncurried_arity_too_large

let pp_error fmt err =
  Format.pp_print_string fmt
    (match err with
    | Mel_uncurried_arity_too_large ->
        "Uncurried functions only supports only up to arity 22"
    | Misplaced_label_syntax ->
        "Label syntax is not supported in this position"
        (*
    let fn x = ((##) x ~hi)  ~lo:1 ~hi:2
    *)
    | Optional_in_uncurried_mel_attribute ->
        "Uncurried function doesn't support optional arguments yet"
    | Expect_opt_in_mel_return_to_opt ->
        "@return directive *_to_opt expect return type to be syntax wise `_ \
         option` for safety"
    | Not_supported_directive_in_mel_return -> "Not supported return directive"
    | Illegal_attribute -> "Illegal attributes"
    | Canot_infer_arity_by_syntax ->
        "Cannot infer the arity through the syntax, either [@uncurry n] or \
         write it in arrow syntax"
    | Inconsistent_arity (arity, n) ->
        Printf.sprintf "Inconsistent arity %d vs %d" arity n
    | Unsupported_predicates -> "unsupported predicates"
    | Conflict_u_mel_this_mel_meth ->
        "@this, @bs, @meth can not be applied at the same time"
    | Conflict_attributes -> "conflicting attributes"
    | Expect_string_literal -> "expect string literal"
    | Duplicated_mel_as -> "duplicate @as"
    | Expect_int_literal -> "expect int literal"
    | Expect_int_or_string_or_json_literal ->
        "expect int, string literal or json literal {json|text here|json}"
    | Unhandled_poly_type -> "Unhandled poly type"
    | Invalid_underscore_type_in_external ->
        "_ is not allowed in combination with external optional type"
    | Invalid_mel_string_type -> "Not a valid type for @string"
    | Invalid_mel_int_type -> "Not a valid type for @int"
    | Invalid_mel_unwrap_type ->
        "Not a valid type for @unwrap. Type must be an inline variant \
         (closed), and each constructor must have an argument."
    | Conflict_ffi_attribute str -> "Conflicting attributes: " ^ str
    | Mel_this_simple_pattern ->
        "@this expect its pattern variable to be simple form")

let err ~loc error = Location.raise_errorf ~loc "%a" pp_error error

let optional_err ~loc (lbl : Asttypes.arg_label) =
  match lbl with
  | Optional _ -> err ~loc Optional_in_uncurried_mel_attribute
  | _ -> ()

let err_if_label ~loc (lbl : Asttypes.arg_label) =
  if lbl <> Nolabel then err ~loc Misplaced_label_syntax

let err_large_arity ~loc arity =
  if arity > 22 then err ~loc Mel_uncurried_arity_too_large
