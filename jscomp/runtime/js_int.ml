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

open Melange_mini_stdlib

(** Provides functions for inspecting and manipulating [int]s *)

type t = int

(** If we use number, we need coerce to int32 by adding `|0`,
    otherwise `+0` can be wrong.
    Most JS API is float oriented, it may overflow int32 or
    comes with [NAN]
  *)
(* + conversion*)

external toExponential : ?digits:t -> string = "toExponential"
[@@mel.send.pipe: t]
(** Formats an [int] using exponential (scientific) notation

{b digits} specifies how many digits should appear after the decimal point. The
value must be in the range \[0, 20\] (inclusive).

{b Returns} a [string] representing the given value in exponential notation

The output will be rounded or padded with zeroes if necessary.

@raise RangeError if digits is not in the range \[0, 20\] (inclusive)

{[
  Js.Int.toExponential 77 = "7.7e+1"
  Js.Int.toExponential ~digits:2 77 = "7.70e+1"
  Js.Int.toExponential ~digits:2 5678 = "5.68e+3"
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/toExponential> MDN
*)

external toPrecision : ?digits:t -> string = "toPrecision"
[@@mel.send.pipe: t]
(** Formats an [int] using some fairly arbitrary rules

{b digits} specifies how many digits should appear in total. The value must
between 1 and some 100.

{b Returns} a [string] representing the given value in fixed-point or scientific notation

The output will be rounded or padded with zeroes if necessary.

[toPrecision] differs from {!Js.Float.toFixed} in that the former will count
all digits against the precision, while the latter will count only the digits
after the decimal point. [toPrecision] will also use scientific notation if the
specified precision is less than the number for digits before the decimal
point.

@raise RangeError if digits is not between 1 and 100.

{[
  Js.Int.toPrecision 123456789 = "123456789"
  Js.Int.toPrecision ~digits:2 123456789 = "1.2e+8"
  Js.Int.toPrecision ~digits:2 0 = "0.0"
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/toPrecision> MDN
*)

external toString : ?radix:t -> string = "toString"
[@@mel.send.pipe: t]
(** Formats an [int] as a string

{b radix} specifies the radix base to use for the formatted number. The
value must be in the range \[2, 36\] (inclusive).

{b Returns} a [string] representing the given value in fixed-point (usually)

@raise RangeError if radix is not in the range \[2, 36\] (inclusive)

{[
  Js.Int.toString 123456789 = "123456789"
  Js.Int.toString ~radix:2 6 = "110"
  Js.Int.toString ~radix:16 3735928559 = "deadbeef"
  Js.Int.toString ~radix:36 123456 = "2n9c"
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/toString> MDN
*)

external toFloat : t -> float = "%floatofint"

let equal (x : t) y = x = y
let max : t = 2147483647
let min : t = -2147483648
