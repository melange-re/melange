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

[@@@mel.config { flags = [| "-unboxed-types" |] }]

(* DESIGN:
   - It does not have any code, all its code will be inlined so that
       there will never be
   {[ require('js')]}
   - Its interface should be minimal
*)

(** This library provides bindings and necessary support for JS FFI.
    It contains all bindings into [Js] namespace.

    {[
      [| 1;2;3;4|]
      |. Js.Array2.map (fun x -> x + 1 )
      |. Js.Array2.reduce (+) 0
      |. Js.log
    ]}
*)

(* internal types for FFI, these types are not used by normal users
    Absent cmi file when looking up module alias. *)
module Fn = struct
  type 'a arity0 = { i0 : unit -> 'a [@internal] }
  type 'a arity1 = { i1 : 'a [@internal] }
  type 'a arity2 = { i2 : 'a [@internal] }
  type 'a arity3 = { i3 : 'a [@internal] }
  type 'a arity4 = { i4 : 'a [@internal] }
  type 'a arity5 = { i5 : 'a [@internal] }
  type 'a arity6 = { i6 : 'a [@internal] }
  type 'a arity7 = { i7 : 'a [@internal] }
  type 'a arity8 = { i8 : 'a [@internal] }
  type 'a arity9 = { i9 : 'a [@internal] }
  type 'a arity10 = { i10 : 'a [@internal] }
  type 'a arity11 = { i11 : 'a [@internal] }
  type 'a arity12 = { i12 : 'a [@internal] }
  type 'a arity13 = { i13 : 'a [@internal] }
  type 'a arity14 = { i14 : 'a [@internal] }
  type 'a arity15 = { i15 : 'a [@internal] }
  type 'a arity16 = { i16 : 'a [@internal] }
  type 'a arity17 = { i17 : 'a [@internal] }
  type 'a arity18 = { i18 : 'a [@internal] }
  type 'a arity19 = { i19 : 'a [@internal] }
  type 'a arity20 = { i20 : 'a [@internal] }
  type 'a arity21 = { i21 : 'a [@internal] }
  type 'a arity22 = { i22 : 'a [@internal] }
end

module Internal = struct
  external opaqueFullApply : 'a -> 'a = "#full_apply"

  (* Use opaque instead of [._n] to prevent some optimizations happening *)
  external run : 'a Fn.arity0 -> 'a = "#run"
  [@@ocaml.warning "-unboxable-type-in-prim-decl"]

  external opaque : 'a -> 'a = "%opaque"
end

type +'a null
type +'a undefined
type +'a nullable
type re
type 'a dict
type 'a iterator
type 'a array_like
type bigint
type +'a promise

external toOption : 'a nullable -> 'a option = "#nullable_to_opt"
external undefinedToOption : 'a undefined -> 'a option = "#undefined_to_opt"
external nullToOption : 'a null -> 'a option = "#null_to_opt"
external isNullable : 'a nullable -> bool = "#is_nullable"
external import : 'a -> 'a promise = "#import"
external testAny : 'a -> bool = "#is_nullable"
external null : 'a null = "#null"
external undefined : 'a undefined = "#undefined"
external typeof : 'a -> string = "#typeof"
external log : 'a -> unit = "log" [@@mel.scope "console"]
external log2 : 'a -> 'b -> unit = "log" [@@mel.scope "console"]
external log3 : 'a -> 'b -> 'c -> unit = "log" [@@mel.scope "console"]
external log4 : 'a -> 'b -> 'c -> 'd -> unit = "log" [@@mel.scope "console"]

external logMany : 'a array -> unit = "log"
[@@mel.scope "console"] [@@mel.variadic]

external eqNull : 'a -> 'a null -> bool = "%bs_equal_null"
external eqUndefined : 'a -> 'a undefined -> bool = "%bs_equal_undefined"
external eqNullable : 'a -> 'a nullable -> bool = "%bs_equal_nullable"
external unsafe_lt : 'a -> 'a -> bool = "#unsafe_lt"
external unsafe_le : 'a -> 'a -> bool = "#unsafe_le"
external unsafe_gt : 'a -> 'a -> bool = "#unsafe_gt"
external unsafe_ge : 'a -> 'a -> bool = "#unsafe_ge"

type 'a t

(*MODULE_ALIASES*)
module Exn = Js_exn
module String = Js_string
module Null = Js_null
module Undefined = Js_undefined
module Nullable = Js_nullable
module Array = Js_array
module Re = Js_re
module Promise = Js_promise
module Date = Js_date
module Dict = Js_dict
module Global = Js_global
module Json = Js_json
module Math = Js_math
module Obj = Js_obj
module Typed_array = Js_typed_array
module Types = Js_types
module Float = Js_float
module Int = Js_int
module Bigint = Js_bigint
module Console = Js_console
module Set = Js_set
module WeakSet = Js_weakset
module Map = Js_map
module WeakMap = Js_weakmap
module Iterator = Js_iterator
module OO = Js_OO
