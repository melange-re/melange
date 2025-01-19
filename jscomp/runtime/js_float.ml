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

(** Provides functions for inspecting and manipulating [float]s *)

type t = float

external _NaN : t = "NaN"
(** The special value "Not a Number"

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/NaN> MDN
*)

external isNaN : t -> bool = "isNaN"
[@@mel.scope "Number"]
(** Tests if the given value is [_NaN]

Note that both [_NaN = _NaN] and [_NaN == _NaN] will return [false]. [isNaN] is
therefore necessary to test for [_NaN].

{b Returns} [true] if the given value is [_NaN], [false] otherwise

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/isNaN> MDN
*)

external isFinite : t -> bool = "isFinite"
[@@mel.scope "Number"]
(** Tests if the given value is finite

{b Returns} [true] if the given value is a finite number, [false] otherwise

{[
(* returns [false] *)
let _ = Js.Float.isFinite infinity

(* returns [false] *)
let _ = Js.Float.isFinite neg_infinity

(* returns [false] *)
let _ = Js.Float.isFinite _NaN

(* returns [true] *)
let _ = Js.Float.isFinite 1234
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/isFinite> MDN
*)

external toExponential : ?digits:int -> (t[@mel.this]) -> string
  = "toExponential"
[@@mel.send]
(** Formats a [float] using exponential (scientific) notation

{b digits} specifies how many digits should appear after the decimal point. The
value must be in the range \[0, 20\] (inclusive).

{b Returns} a [string] representing the given value in exponential notation

The output will be rounded or padded with zeroes if necessary.

@raise RangeError if digits is not in the range \[0, 20\] (inclusive)

{[
  Js.Float.toExponential 77.1234 = "7.71234e+1"
  Js.Float.toExponential 77. = "7.7e+1"
  Js.Float.toExponential ~digits:2 77.1234 = "7.71e+1"
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/toExponential> MDN
*)

external toFixed : ?digits:int -> (t[@mel.this]) -> string = "toFixed"
[@@mel.send]
(** Formats a [float] using fixed point notation

{b digits} specifies how many digits should appear after the decimal point. The
value must be in the range \[0, 20\] (inclusive). Defaults to [0].

{b Returns} a [string] representing the given value in fixed-point notation (usually)

The output will be rounded or padded with zeroes if necessary.

@raise RangeError if digits is not in the range \[0, 20\] (inclusive)

{[
  Js.Float.toFixed 12345.6789 = "12346"
  Js.Float.toFixed 1.2e21 = "1.2e+21"
  Js.Float.toFixed ~digits:1 12345.6789 = "12345.7"
  Js.Float.toFixed ~digits:2 0. = "0.00"
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/toFixed> MDN
*)

external toPrecision : ?digits:int -> (t[@mel.this]) -> string = "toPrecision"
[@@mel.send]
(** Formats a [float] using some fairly arbitrary rules

{b digits} specifies how many digits should appear in total. The
value must between 0 and some arbitrary number that's hopefully at least larger
than 20 (for Node it's 21. Why? Who knows).

{b Returns} a [string] representing the given value in fixed-point or scientific notation

The output will be rounded or padded with zeroes if necessary.

[toPrecision] differs from [toFixed] in that the former
will count all digits against the precision, while the latter will count only
the digits after the decimal point. [toPrecision] will also use
scientific notation if the specified precision is less than the number for digits
before the decimal point.

@raise RangeError if digits is not in the range accepted by this function (what do you mean "vague"?)

{[
  Js.Float.toPrecision 12345.6789 = "12345.6789"
  Js.Float.toPrecision 1.2e21 = "1.2e+21"
  Js.Float.toPrecision ~digits:1 12345.6789 = "1e+4"
  Js.Float.toPrecision ~digits:2 0. = "0.0"
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/toPrecision> MDN
*)

external toString : ?radix:int -> (t[@mel.this]) -> string = "toString"
[@@mel.send]
(** Formats a [float] as a string

{b radix} specifies the radix base to use for the formatted number. The
value must be in the range \[2, 36\] (inclusive).

{b Returns} a [string] representing the given value in fixed-point (usually)

@raise RangeError if radix is not in the range \[2, 36\] (inclusive)

{[
  Js.Float.toString 12345.6789 = "12345.6789"
  Js.Float.toString ~radix:2 6. = "110"
  Js.Float.toString ~radix:2 3.14 = "11.001000111101011100001010001111010111000010100011111"
  Js.Float.toString ~radix:16 3735928559. = "deadbeef"
  Js.Float.toString ~radix:36 123.456 = "3f.gez4w97ry0a18ymf6qadcxr"
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/toString> MDN
*)

external fromString : string -> t = "Number"
(** Parses the given [string] into a [float] using JavaScript semantics

{b Returns} the number as a [float] if successfully parsed, [_NaN] otherwise.

{[
Js.Float.fromString "123" = 123.
Js.Float.fromString "12.3" = 12.3
Js.Float.fromString "" = 0.
Js.Float.fromString "0x11" = 17.
Js.Float.fromString "0b11" = 3.
Js.Float.fromString "0o11" = 9.
Js.Float.fromString "foo" = _NaN
Js.Float.fromString "100a" = _NaN
]}
*)
