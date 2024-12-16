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

type binop =
  | Eq
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

type int_op =
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

type level = Log | Info | Warn | Error
type kind = Ml | Runtime | External of { name : string; default : bool }
type property = Lam_group.let_kind = Strict | Alias | StrictOpt | Variable
type 'a access = Getter | Setter
type float_lit = { f : string } [@@unboxed]

type number =
  | Float of float_lit
  | Int of { i : int32; c : char option }
  | Uint of int32

type mutable_flag = Mutable | Immutable | NA
type direction_flag = Upto | Downto | Up
type recursive_info = SingleRecursive | NonRecursie | NA

type used_stats =
  | Dead_pure
  | Dead_non_pure
  | Exported
  | Once_pure
  | Used
  | Scanning_pure
  | Scanning_non_pure
  | NA

type ident_info = {
  (* mutable recursive_info : recursive_info; *)
  mutable used_stats : used_stats;
}

type exports = Ident.t list
type tag_info = Lam.Tag_info.t
type length_object = Array | String | Bytes | Function | Caml_block

val op_prec : binop -> int * int * int
val op_str : binop -> string
val op_int_prec : int_op -> int * int * int
val op_int_str : int_op -> string
val str_of_used_stats : used_stats -> string
val update_used_stats : ident_info -> used_stats -> unit
val of_lam_mutable_flag : Asttypes.mutable_flag -> mutable_flag
val is_cons : string -> bool
