(* Copyright (C) 2018 - Hongbo Zhang, Authors of ReScript
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

(*********************************)
(* only [handle_mel_non_obj_ffi] will be used outside *)
(*
   [no_auto_uncurried_arg_types xs]
   check if the FFI have @uncurry attribute.
   if it does not we wrap it in a normal way otherwise
*)
let rec no_auto_uncurried_arg_types
    (xs :
      Melange_ffi.External_arg_spec.label_noname
      Melange_ffi.External_arg_spec.param
      list) =
  match xs with
  | [] -> true
  | { arg_type = Fn_uncurry_arity _; _ } :: _ -> false
  | _ :: xs -> no_auto_uncurried_arg_types xs

let rec transform_uncurried_arg_type loc
    (arg_types :
      Melange_ffi.External_arg_spec.label_noname
      Melange_ffi.External_arg_spec.param
      list) (args : Lam.t list) =
  match (arg_types, args) with
  | { arg_type = Fn_uncurry_arity n; arg_label } :: xs, y :: ys ->
      let o_arg_types, o_args = transform_uncurried_arg_type loc xs ys in
      ( { Melange_ffi.External_arg_spec.arg_type = Nothing; arg_label }
        :: o_arg_types,
        Lam.prim ~primitive:(Pjs_fn_make n) ~args:[ y ] loc :: o_args )
  | x :: xs, y :: ys -> (
      match x with
      | { arg_type = Arg_cst _; _ } ->
          let o_arg_types, o_args = transform_uncurried_arg_type loc xs args in
          (x :: o_arg_types, o_args)
      | _ ->
          let o_arg_types, o_args = transform_uncurried_arg_type loc xs ys in
          (x :: o_arg_types, y :: o_args))
  | ([], [] | _ :: _, [] | [], _ :: _) as ok -> ok

let handle_mel_non_obj_ffi =
  let result_wrap loc
      (result_type : Melange_ffi.External_ffi_types.return_wrapper) result =
    match result_type with
    | Return_replaced_with_unit -> Lam.seq result Lam.unit
    | Return_null_to_opt ->
        Lam.prim ~primitive:Pnull_to_opt ~args:[ result ] loc
    | Return_null_undefined_to_opt ->
        Lam.prim ~primitive:Pnull_undefined_to_opt ~args:[ result ] loc
    | Return_undefined_to_opt ->
        Lam.prim ~primitive:Pundefined_to_opt ~args:[ result ] loc
    | Return_unset | Return_identity -> result
  in
  fun (arg_types :
        Melange_ffi.External_arg_spec.label_noname
        Melange_ffi.External_arg_spec.param
        list) (result_type : Melange_ffi.External_ffi_types.return_wrapper) ffi
      args loc prim_name ~dynamic_import ->
    if no_auto_uncurried_arg_types arg_types then
      result_wrap loc result_type
        (Lam.prim
           ~primitive:(Pjs_call { prim_name; arg_types; ffi; dynamic_import })
           ~args loc)
    else
      let n_arg_types, n_args =
        transform_uncurried_arg_type loc arg_types args
      in
      result_wrap loc result_type
        (Lam.prim
           ~primitive:
             (Pjs_call
                { prim_name; arg_types = n_arg_types; ffi; dynamic_import })
           ~args:n_args loc)
