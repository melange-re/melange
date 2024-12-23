(* Copyright (C) 2022- Authors of Melange
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

(** JavaScript BigInt API *)

type t = Js.bigint

external make : 'a -> t = "BigInt"
(**
  [make repr] creates a new BigInt from the representation [repr]. [repr] can
  be a number, a string, boolean, etc.
 *)

external asIntN : precision:int -> t -> t = "asIntN"
[@@mel.scope "BigInt"]
(**
  [asIntN ~precision bigint] truncates the BigInt value of [bigint] to the
  given number of least significant bits specified by [precision] and returns
  that value as a signed integer. *)

external asUintN : precision:int -> t -> t = "asUintN"
[@@mel.scope "BigInt"]
(**
  [asUintN ~precision bigint] truncates the BigInt value of [bigint] to the
  given number of least significant bits specified by [precision] and returns
  that value as an unsigned integer. *)

type toLocaleStringOptions = { style : string; currency : string }

external toLocaleString :
  locale:string -> ?options:toLocaleStringOptions -> t -> string
  = "toLocaleString"
[@@mel.send]
(**
  [toLocaleString bigint] returns a string with a language-sensitive
  representation of this BigInt. *)

external toString : t -> string = "toLocaleString"
[@@mel.send]
(**
    [toString bigint] returns a string representing the specified BigInt value.
 *)

external neg : t -> t = "%negfloat"
external add : t -> t -> t = "%addfloat"

external sub : t -> t -> t = "%subfloat"
(** Subtraction. *)

external mul : t -> t -> t = "%mulfloat"
(** Multiplication. *)

external div : t -> t -> t = "%divfloat"
(** Division. *)

external rem : t -> t -> t = "caml_fmod_float" "fmod"
