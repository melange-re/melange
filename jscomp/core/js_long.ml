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

module E = Js_exp_make

type int64_call = J.expression list -> J.expression

let int64_call (fn : string) args =
  E.runtime_call Js_runtime_modules.int64 fn args

(* below should  not depend on layout *)

let of_const (v : Int64.t) =
  match v with
  | 0L -> E.runtime_var_dot Js_runtime_modules.int64 "zero"
  | 1L -> E.runtime_var_dot Js_runtime_modules.int64 "one"
  | -1L -> E.runtime_var_dot Js_runtime_modules.int64 "neg_one"
  | 9223372036854775807L -> E.runtime_var_dot Js_runtime_modules.int64 "max_int"
  | -9223372036854775808L ->
      E.runtime_var_dot Js_runtime_modules.int64 "min_int"
  | _ ->
      let unsigned_lo = E.uint32 (Int64.to_int32 v) in
      let hi = E.int (Int64.to_int32 (Int64.shift_right v 32)) in
      E.array Immutable [ hi; unsigned_lo ]
(* Assume the encoding of Int64 *)

let to_int32 args = int64_call "to_int32" args
(* let get_lo x = E.array_index_by_int x 1l   *)
(* E.to_int32 @@ get_lo (Ext_list.singleton_exn args) *)

let of_int32 (args : J.expression list) =
  match args with
  | [ { expression_desc = Number (Int { i; _ }); _ } ] ->
      of_const (Int64.of_int32 i)
  | _ -> int64_call "of_int32" args

let comp (cmp : Lam_compat.integer_comparison) args =
  E.runtime_call Js_runtime_modules.caml_primitive
    (match cmp with
    | Ceq -> "i64_eq"
    | Cne -> "i64_neq"
    | Clt -> "i64_lt"
    | Cgt -> "i64_gt"
    | Cle -> "i64_le"
    | Cge -> "i64_ge")
    args

let min args = E.runtime_call Js_runtime_modules.caml_primitive "i64_min" args
let max args = E.runtime_call Js_runtime_modules.caml_primitive "i64_max" args
let neg args = int64_call "neg" args
let add args = int64_call "add" args
let sub args = int64_call "sub" args
let mul args = int64_call "mul" args
let div args = int64_call "div" args

(** Note if operands are not pure, we need hold shared value,
    which is  a statement [var x = ... ; x ], it does not fit
    current pipe-line fall back to a function call
*)
let bit_op (* op : E.t -> E.t -> E.t*) runtime_call args =
  int64_call runtime_call args
(*disable optimizations relying on int64 representations
  this maybe outdated when we switch to bigint
*)
(* match args  with
   | [l;r] ->
     (* Int64 is a block in ocaml, a little more conservative in inlining *)
     if Js_analyzer.is_okay_to_duplicate l  &&
        Js_analyzer.is_okay_to_duplicate r then
       make ~lo:(op (get_lo l) (get_lo r))
         ~hi:(op (get_hi l) (get_hi r))
     else
   | _ -> assert false *)

let xor = bit_op "xor"
let or_ = bit_op "or_"
let and_ = bit_op "and_"
let lsl_ args = int64_call "lsl_" args
let lsr_ args = int64_call "lsr_" args
let asr_ args = int64_call "asr_" args
let mod_ args = int64_call "mod_" args
let swap args = int64_call "swap" args

(* Safe constant propgation
   {[
     Number.MAX_SAFE_INTEGER:
       Math.pow(2,53) - 1
   ]}
   {[
     Number.MIN_SAFE_INTEGER:
       - (Math.pow(2,53) -1)
   ]}
   Note that [Number._SAFE_INTEGER] is in ES6,
   we can hard code this number without bringing browser issue.
*)
let of_float (args : J.expression list) = int64_call "of_float" args
let compare (args : J.expression list) = int64_call "compare" args

(* let of_string (args : J.expression list) =
   int64_call "of_string" args *)
(* let get64 = int64_call "get64" *)
let float_of_bits = int64_call "float_of_bits"
let bits_of_float = int64_call "bits_of_float"
let equal_null args = int64_call "equal_null" args
let equal_undefined args = int64_call "equal_undefined" args
let equal_nullable args = int64_call "equal_nullable" args

let to_float (args : J.expression list) =
  match args with
  (* | [ {expression_desc  *)
  (*      = Caml_block (  *)
  (*          [lo =  *)
  (*           {expression_desc = Number (Int {i = lo; _}) }; *)
  (*           hi =  *)
  (*           {expression_desc = Number (Int {i = hi; _}) }; *)
  (*          ], _, _, _); _ }]  *)
  (*   ->  *)
  | [ _ ] -> int64_call "to_float" args
  | _ -> assert false
