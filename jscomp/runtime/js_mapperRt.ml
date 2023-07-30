(* Copyright (C) 2017 Hongbo Zhang, Authors of ReScript
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

open Melange_mini_stdlib

external ( .!() ) : int array -> int -> int = "" [@@mel.get_index]

let raiseWhenNotFound x = if Js_internal.testAny x then raise Not_found else x

let rec fromIntAux (enum : int) i len xs =
  if i = len then None
  else
    let k = xs.!(i) in
    if k = enum then Some i else fromIntAux enum (i + 1) len xs

let fromInt len (xs : int array) (enum : int) : 'variant option =
  fromIntAux enum 0 len xs

let rec fromIntAssertAux len (enum : int) i xs =
  if i = len then raise Not_found
  else
    let k = xs.!(i) in
    if k = enum then i else fromIntAssertAux len enum (i + 1) xs

(** [length] is not relevant any more *)
let fromIntAssert len (xs : int array) (enum : int) =
  fromIntAssertAux len enum 0 xs
