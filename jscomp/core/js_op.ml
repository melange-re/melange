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

(** Define some basic types used in JS IR *)

module Binop = struct
  type t =
    | Eq
      (* actually assignment ..
       TODO: move it into statement, so that all expressions
       are side efffect free (except function calls)
    *)
    | Or
    | And
    | EqEqEq
    | NotEqEq (* | InstanceOf *)
    | Lt
    | Le
    | Gt
    | Ge
    | Bor
    | Bxor
    | Band
    | Lsl
    | Lsr
    | Asr
    | Plus
    | Minus
    | Mul
    | Div
    | Mod

  let equal t1 t2 =
    match (t1, t2) with
    | Eq, Eq -> true
    | Or, Or -> true
    | And, And -> true
    | EqEqEq, EqEqEq -> true
    | NotEqEq, NotEqEq -> true
    | Lt, Lt -> true
    | Le, Le -> true
    | Gt, Gt -> true
    | Ge, Ge -> true
    | Bor, Bor -> true
    | Bxor, Bxor -> true
    | Band, Band -> true
    | Lsl, Lsl -> true
    | Lsr, Lsr -> true
    | Asr, Asr -> true
    | Plus, Plus -> true
    | Minus, Minus -> true
    | Mul, Mul -> true
    | Div, Div -> true
    | Mod, Mod -> true
    | _ -> false

  let prec (op : t) =
    match op with
    | Eq -> (1, 13, 1)
    | Or -> (3, 3, 3)
    | And -> (4, 4, 4)
    | EqEqEq | NotEqEq -> (8, 8, 9)
    | Gt | Ge | Lt | Le (* | InstanceOf *) -> (9, 9, 10)
    | Bor -> (5, 5, 5)
    | Bxor -> (6, 6, 6)
    | Band -> (7, 7, 7)
    | Lsl | Lsr | Asr -> (10, 10, 11)
    | Plus | Minus -> (11, 11, 12)
    | Mul | Div | Mod -> (12, 12, 13)

  let to_string op =
    match op with
    | Bor -> "|"
    | Bxor -> "^"
    | Band -> "&"
    | Lsl -> "<<"
    | Lsr -> ">>>"
    | Asr -> ">>"
    | Plus -> "+"
    | Minus -> "-"
    | Mul -> "*"
    | Div -> "/"
    | Mod -> "%"
    | Eq -> "="
    | Or -> "||"
    | And -> "&&"
    | EqEqEq -> "==="
    | NotEqEq -> "!=="
    | Lt -> "<"
    | Le -> "<="
    | Gt -> ">"
    | Ge -> ">="
  (* | InstanceOf -> "instanceof" *)
end

(* literal char *)
type float_lit = { f : string } [@@unboxed]

(* becareful when constant folding +/-,
   since we treat it as js nativeint, bitwise operators:
   https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Bitwise_Operators
   The operands of all bitwise operators are converted to signed 32-bit integers in two's complement format.'
*)

type mutable_flag = Mutable | Immutable | NA

type used_stats =
  | Dead_pure
  (* only [Dead] should be taken serious,
      other status can be converted during
      inlining
      -- all exported symbols can not be dead
      -- once a symbole is called Dead_pure,
      it can not be alive anymore, we should avoid iterating it
  *)
  | Dead_non_pure
  (* we still need iterating it,
     just its bindings does not make sense any more *)
  | Exported (* Once it's exported, shall we change its status anymore? *)
  (* In general, we should count in one pass, and eliminate code in another
     pass, you can not do it in a single pass, however, some simple
     dead code can be detected in a single pass
  *)
  | Once_pure
    (* used only once so that, if we do the inlining, it will be [Dead] *)
  | Used (**)
  | Scanning_pure
  | Scanning_non_pure
  | NA

type ident_info = {
  (* mutable recursive_info : recursive_info; *)
  mutable used_stats : used_stats;
}

(** TODO: define constant - for better constant folding  *)

(* type constant =  *)
(*   | Const_int of int *)
(*   | Const_ *)

(* Refer https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Operator_Precedence
   for precedence
*)

let update_used_stats (ident_info : ident_info) used_stats =
  match ident_info.used_stats with
  | Dead_pure | Dead_non_pure | Exported -> ()
  | Scanning_pure | Scanning_non_pure | Used | Once_pure | NA ->
      ident_info.used_stats <- used_stats

let of_lam_mutable_flag (x : Asttypes.mutable_flag) : mutable_flag =
  match x with Immutable -> Immutable | Mutable -> Mutable

let is_cons = function "::" -> true | _ -> false
