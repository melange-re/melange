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

external floor : float -> float = "Math.floor"
(** *)

external int_of_float : float -> int = "%intoffloat"
external float_of_int : int -> float = "%floatofint"
val caml_int32_float_of_bits : int32 -> float
val caml_int32_bits_of_float : float -> int32
val caml_modf_float : float -> float * float
val caml_ldexp_float : float -> int -> float
val caml_frexp_float : float -> float * int
val caml_copysign_float : float -> float -> float
val caml_expm1_float : float -> float
val caml_hypot_float : float -> float -> float
val caml_log10_float : float -> float
