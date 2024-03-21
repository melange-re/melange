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
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)

open Melange_mini_stdlib

(** JavaScript Math API *)

external _E : float = "E" [@@mel.scope "Math"]
(** Euler's number *)

external _LN2 : float = "LN2" [@@mel.scope "Math"]
(** natural logarithm of 2 *)

external _LN10 : float = "LN10"
[@@mel.scope "Math"]
(** natural logarithm of 10 *)

external _LOG2E : float = "LOG2E"
[@@mel.scope "Math"]
(** base 2 logarithm of E *)

external _LOG10E : float = "LOG10E"
[@@mel.scope "Math"]
(** base 10 logarithm of E *)

external _PI : float = "PI"
[@@mel.scope "Math"]
(** Pi... (ratio of the circumference and diameter of a circle) *)

external _SQRT1_2 : float = "SQRT1_2"
[@@mel.scope "Math"]
(** square root of 1/2 *)

external _SQRT2 : float = "SQRT2" [@@mel.scope "Math"]
(** square root of 2 *)

external abs_int : int -> int = "abs" [@@mel.scope "Math"]
(** absolute value *)

external abs_float : float -> float = "abs"
[@@mel.scope "Math"]
(** absolute value *)

external acos : float -> float = "acos"
[@@mel.scope "Math"]
(** arccosine in radians, can return NaN *)

external acosh : float -> float = "acosh"
[@@mel.scope "Math"]
(** hyperbolic arccosine in raidans, can return NaN, ES2015 *)

external asin : float -> float = "asin"
[@@mel.scope "Math"]
(** arcsine in radians, can return NaN *)

external asinh : float -> float = "asinh"
[@@mel.scope "Math"]
(** hyperbolic arcsine in raidans, ES2015 *)

external atan : float -> float = "atan"
[@@mel.scope "Math"]
(** arctangent in radians *)

external atanh : float -> float = "atanh"
[@@mel.scope "Math"]
(** hyperbolic arctangent in radians, can return NaN, ES2015 *)

external atan2 : y:float -> x:float -> float = "atan2"
[@@mel.scope "Math"]
(** arctangent of the quotient of x and y, mostly... this one's a bit weird *)

external cbrt : float -> float = "cbrt"
[@@mel.scope "Math"]
(** cube root, can return NaN, ES2015 *)

external unsafe_ceil_int : float -> int = "ceil"
[@@mel.scope "Math"]
(** may return values not representable by [int] *)

open struct
  module Int = struct
    type t = int

    external toFloat : t -> float = "%floatofint"

    let max : t = 2147483647
    let min : t = -2147483648
  end
end

(** smallest int greater than or equal to the argument *)
let ceil_int (f : float) : int =
  if f > Int.toFloat Int.max then Int.max
  else if f < Int.toFloat Int.min then Int.min
  else unsafe_ceil_int f

external ceil_float : float -> float = "ceil"
[@@mel.scope "Math"]
(** smallest float greater than or equal to the argument *)

external clz32 : int -> int = "clz32"
[@@mel.scope "Math"]
(** number of leading zero bits of the argument's 32 bit int representation,
    ES2015 *)
(* can convert string, float etc. to number *)

external cos : float -> float = "cos"
[@@mel.scope "Math"]
(** cosine in radians *)

external cosh : float -> float = "cosh"
[@@mel.scope "Math"]
(** hyperbolic cosine in radians, ES2015 *)

external exp : float -> float = "exp"
[@@mel.scope "Math"]
(** natural exponentional *)

external expm1 : float -> float = "expm1"
[@@mel.scope "Math"]
(** natural exponential minus 1, ES2015 *)

external unsafe_floor_int : float -> int = "floor"
[@@mel.scope "Math"]
(** may return values not representable by [int] *)

(** largest int greater than or equal to the arugment *)
let floor_int f =
  if f > Int.toFloat Int.max then Int.max
  else if f < Int.toFloat Int.min then Int.min
  else unsafe_floor_int f

external floor_float : float -> float = "floor" [@@mel.scope "Math"]

external fround : float -> float = "fround"
[@@mel.scope "Math"]
(** round to nearest single precision float, ES2015 *)

external hypot : float -> float -> float = "hypot"
[@@mel.scope "Math"]
(** pythagorean equation, ES2015 *)

external hypotMany : float array -> float = "hypot"
[@@mel.variadic] [@@mel.scope "Math"]
(** generalized pythagorean equation, ES2015 *)

external imul : int -> int -> int = "imul"
[@@mel.scope "Math"]
(** 32-bit integer multiplication, ES2015 *)

external log : float -> float = "log"
[@@mel.scope "Math"]
(** natural logarithm, can return NaN *)

external log1p : float -> float = "log1p"
[@@mel.scope "Math"]
(** natural logarithm of 1 + the argument, can return NaN, ES2015 *)

external log10 : float -> float = "log10"
[@@mel.scope "Math"]
(** base 10 logarithm, can return NaN, ES2015 *)

external log2 : float -> float = "log2"
[@@mel.scope "Math"]
(** base 2 logarithm, can return NaN, ES2015 *)

external max_int : int -> int -> int = "max"
[@@mel.scope "Math"]
(** max value *)

external maxMany_int : int array -> int = "max"
[@@mel.variadic] [@@mel.scope "Math"]
(** max value *)

external max_float : float -> float -> float = "max"
[@@mel.scope "Math"]
(** max value *)

external maxMany_float : float array -> float = "max"
[@@mel.variadic] [@@mel.scope "Math"]
(** max value *)

external min_int : int -> int -> int = "min"
[@@mel.scope "Math"]
(** min value *)

external minMany_int : int array -> int = "min"
[@@mel.variadic] [@@mel.scope "Math"]
(** min value *)

external min_float : float -> float -> float = "min"
[@@mel.scope "Math"]
(** min value *)

external minMany_float : float array -> float = "min"
[@@mel.variadic] [@@mel.scope "Math"]
(** min value *)

external pow_float : base:float -> exp:float -> float = "pow"
[@@mel.scope "Math"]
(** base to the power of the exponent *)

external random : unit -> float = "random"
[@@mel.scope "Math"]
(** random number in \[0,1) *)

(** random number in \[min,max) *)
let random_int min max = floor_int (random () *. Int.toFloat (max - min)) + min

external unsafe_round : float -> int = "round"
[@@mel.scope "Math"]
(** rounds to nearest integer, returns a value not representable as [int] if
    NaN *)

external round : float -> float = "round"
[@@mel.scope "Math"]
(** rounds to nearest integer *)

external sign_int : int -> int = "sign"
[@@mel.scope "Math"]
(** the sign of the argument, 1, -1 or 0, ES2015 *)

external sign_float : float -> float = "sign"
[@@mel.scope "Math"]
(** the sign of the argument, 1, -1, 0, -0 or NaN, ES2015 *)

external sin : float -> float = "sin" [@@mel.scope "Math"]
(** sine in radians *)

external sinh : float -> float = "sinh"
[@@mel.scope "Math"]
(** hyperbolic sine in radians, ES2015 *)

external sqrt : float -> float = "sqrt"
[@@mel.scope "Math"]
(** square root, can return NaN *)

external tan : float -> float = "tan"
[@@mel.scope "Math"]
(** tangent in radians *)

external tanh : float -> float = "tanh"
[@@mel.scope "Math"]
(** hyperbolic tangent in radians, ES2015 *)

external unsafe_trunc : float -> int = "trunc"
[@@mel.scope "Math"]
(** truncate, ie. remove fractional digits, returns a value not representable
    as [int] if NaN, ES2015 *)

external trunc : float -> float = "trunc"
[@@mel.scope "Math"]
(** truncate, ie. remove fractional digits, returns a value not representable
    as [int] if NaN, ES2015 *)
