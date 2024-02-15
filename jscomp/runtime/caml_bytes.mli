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

val caml_create_bytes : int -> bytes
val caml_fill_bytes : bytes -> int -> int -> char -> unit
val get : bytes -> int -> char
val set : bytes -> int -> char -> unit
val bytes_to_string : bytes -> string
val caml_blit_bytes : bytes -> int -> bytes -> int -> int -> unit
val caml_blit_string : string -> int -> bytes -> int -> int -> unit
val bytes_of_string : string -> bytes
val caml_bytes_compare : bytes -> bytes -> int
val caml_bytes_greaterthan : bytes -> bytes -> bool
val caml_bytes_greaterequal : bytes -> bytes -> bool
val caml_bytes_lessthan : bytes -> bytes -> bool
val caml_bytes_lessequal : bytes -> bytes -> bool
val caml_bytes_equal : bytes -> bytes -> bool
val bswap16 : int -> int
val bswap32 : int32 -> int32
val bswap64 : int64 -> int64
val get16u : bytes -> int -> int
val get16 : bytes -> int -> int
val get32 : bytes -> int -> int32
val get64 : bytes -> int -> int64
val set16u : bytes -> int -> int -> unit
val set16 : bytes -> int -> int -> unit
val set32u : bytes -> int -> int32 -> unit
val set32 : bytes -> int -> int32 -> unit
val set64u : bytes -> int -> int64 -> unit
val set64 : bytes -> int -> int64 -> unit
