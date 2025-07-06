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
  | Invalid_mel_spread_type
  | Invalid_mel_unwrap_type
  | Conflict_ffi_attribute of string
  | Cannot_infer_arity_by_syntax
  | Inconsistent_arity of { uncurry_attribute : int; real : int }
    (* we still require users to have explicit annotation to avoid
       {[ (((int -> int) -> int) -> int )]} *)
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
        "Uncurried function arity is limited to 22 arguments"
    | Misplaced_label_syntax ->
        (* let fn x = ((##) x ~hi) ~lo:1 ~hi:2 *)
        "Label syntax is not supported in this position"
    | Optional_in_uncurried_mel_attribute ->
        "Uncurried function doesn't support optional arguments yet"
    | Expect_opt_in_mel_return_to_opt ->
        "`@mel.return' directive *_to_opt expects the return type to be an \
         option literal type (`_ option')"
    | Not_supported_directive_in_mel_return ->
        "Unsupported `@mel.return' directive. Supported directives are one of:\n\
         - undefined_to_opt\n\
         - null_to_opt\n\
         - nullable / null_undefined_to_opt\n\
         - identity"
    | Cannot_infer_arity_by_syntax ->
        "Cannot infer arity through syntax.\n\
         Use either `[@mel.uncurry n]' or the full arrow type"
    | Inconsistent_arity { uncurry_attribute; real } ->
        Printf.sprintf
          "Inconsistent arity: `[@mel.uncurry %d]' / arrow syntax with `%d' \
           arguments"
          uncurry_attribute real
    | Unsupported_predicates -> "Unsupported predicate"
    | Conflict_u_mel_this_mel_meth ->
        "`@mel.this', `@u' and `@mel.meth' cannot be applied at the same time"
    | Conflict_attributes -> "Conflicting attributes"
    | Expect_string_literal -> "Expected a string literal"
    | Duplicated_mel_as -> "Duplicate `@mel.as'"
    | Expect_int_literal -> "Expected an integer literal"
    | Expect_int_or_string_or_json_literal ->
        "Expected an integer, string or JSON literal (`{json|text here|json}')"
    | Unhandled_poly_type -> "Unhandled polymorphic variant type"
    | Invalid_underscore_type_in_external ->
        "`_' is not allowed in an `external' declaration's (optionally) \
         labelled argument type"
    | Invalid_mel_string_type -> "Invalid type for `[@mel.string]'"
    | Invalid_mel_int_type -> "Invalid type for `[@mel.int]'"
    | Invalid_mel_spread_type -> "Invalid type for `[@mel.spread]'"
    | Invalid_mel_unwrap_type ->
        "Invalid type for `@mel.unwrap'. Type must be an inline variant \
         (closed), and each constructor must have an argument."
    | Conflict_ffi_attribute str ->
        Format.sprintf "Conflicting FFI attributes: %s" str
    | Mel_this_simple_pattern ->
        "`@mel.this' expects a simple pattern: an optionally constrained \
         variable (or wildcard)")

let err ~loc error = Location.raise_errorf ~loc "%a" pp_error error

let optional_err ~loc (lbl : Asttypes.arg_label) =
  match lbl with
  | Optional _ -> err ~loc Optional_in_uncurried_mel_attribute
  | Nolabel | Labelled _ -> ()

let err_if_label ~loc (lbl : Asttypes.arg_label) =
  match lbl with
  | Labelled _ | Optional _ -> err ~loc Misplaced_label_syntax
  | Nolabel -> ()

let err_large_arity ~loc arity =
  if arity > 22 then err ~loc Mel_uncurried_arity_too_large
