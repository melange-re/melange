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

(* borrowed from others/js_math.ml *)
external _LOG2E : float = "Math.LOG2E"
external _LOG10E : float = "Math.LOG10E"
external abs_float : float -> float = "Math.abs"
external floor : float -> float = "Math.floor"
external exp : float -> float = "exp" [@@mel.scope "Math"]
external log : float -> float = "Math.log"
external sqrt : float -> float = "sqrt" [@@mel.scope "Math"]
external pow_float : base:float -> exp:float -> float = "Math.pow"
external int_of_float : float -> int = "%intoffloat"
external float_of_int : int -> float = "%floatofint"

let caml_int32_float_of_bits : int32 -> float =
  [%raw
    {|function(x){
    return new Float32Array(new Int32Array([x]).buffer)[0]
    }|}]
(* let int32 = Int32_array.make [| x |] in
   let float32 = Float32_array.fromBuffer ( Int32_array.buffer int32) in
   Float32_array.unsafe_get float32 0 *)

let caml_int32_bits_of_float : float -> int32 =
  [%raw
    {|function(x){
  return new Int32Array(new Float32Array([x]).buffer)[0]
}|}]
(* let float32 = Float32_array.make [|x|] in
   Int32_array.unsafe_get (Int32_array.fromBuffer (Float32_array.buffer float32)) 0 *)

let caml_modf_float (x : float) : float * float =
  if Caml_float_extern.isFinite x then
    let neg = 1. /. x < 0. in
    let x = abs_float x in
    let i = floor x in
    let f = x -. i in
    if neg then (-.f, -.i) else (f, i)
  else if Caml_float_extern.isNaN x then
    (Caml_float_extern._NaN, Caml_float_extern._NaN)
  else (1. /. x, x)

let caml_ldexp_float (x : float) (exp : int) : float =
  let x', exp' = (ref x, ref (float_of_int exp)) in
  if exp'.contents > 1023. then (
    exp'.contents <- exp'.contents -. 1023.;
    x'.contents <- x'.contents *. pow_float ~base:2. ~exp:1023.;
    if exp'.contents > 1023. then (
      (* in case x is subnormal *)
      exp'.contents <- exp'.contents -. 1023.;
      x'.contents <- x'.contents *. pow_float ~base:2. ~exp:1023.))
  else if exp'.contents < -1023. then (
    exp'.contents <- exp'.contents +. 1023.;
    x'.contents <- x'.contents *. pow_float ~base:2. ~exp:(-1023.));
  x'.contents *. pow_float ~base:2. ~exp:exp'.contents

let caml_frexp_float (x : float) : float * int =
  if x = 0. || not (Caml_float_extern.isFinite x) then (x, 0)
  else
    let neg = x < 0. in
    let x' = ref (abs_float x) in
    let exp = ref (floor (_LOG2E *. log x'.contents) +. 1.) in
    x'.contents <- x'.contents *. pow_float ~base:2. ~exp:(-.exp.contents);
    if x'.contents < 0.5 then (
      x'.contents <- x'.contents *. 2.;
      exp.contents <- exp.contents -. 1.);
    if neg then x'.contents <- -.x'.contents;
    (x'.contents, int_of_float exp.contents)

let caml_copysign_float (x : float) (y : float) : float =
  let x = abs_float x in
  let y = if y = 0. then 1. /. y else y in
  if y < 0. then -.x else x

(* http://www.johndcook.com/blog/cpp_expm1/ *)
let caml_expm1_float : float -> float = function
  | x ->
      let y = exp x in
      let z = y -. 1. in
      if abs_float x > 1. then z else if z = 0. then x else x *. z /. log y

(*
(* http://blog.csdn.net/liyuanbhu/article/details/8544644 *)
let caml_log1p_float : float -> float = function x ->
  let y = 1. +.  x  in
  let z =  y -. 1. in
  if z = 0. then x else x *. log y /. z *)

let caml_hypot_float (x : float) (y : float) : float =
  let x0, y0 = (abs_float x, abs_float y) in
  let a = Pervasives.max x0 y0 in
  let b = Pervasives.min x0 y0 /. if a <> 0. then a else 1. in
  a *. sqrt (1. +. (b *. b))

let caml_log10_float (x : float) : float = _LOG10E *. log x

(*
let caml_cosh_float x = exp x +. exp (-. x) /. 2.
let caml_sin_float x = exp x -. exp (-. x) /. 2.
let caml_tan_float x =
  let y = exp x in
  let z = exp (-. x) in
  (y +. z) /. (y -. z   ) *)
