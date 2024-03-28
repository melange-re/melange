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

type +'a null
(** A value of this type can be either [null] or ['a].
    This type is the same as type [t] in {!Null} *)

type +'a undefined
(** A value of this type can be either [undefined] or ['a].
    This type is the same as type [t] in {!Undefined} *)

type +'a nullable
(** A value of this type can be [undefined], [null] or ['a].
    This type is the same as type [t] n {!Nullable} *)

type re
(** The type for JavaScript [RegExp] *)

type 'a dict
(** The type for a simple key-value dictionary abstraction over native
    JavaScript objects *)

type 'a iterator
(** The type for JavaScript iterators *)

type 'a array_like
(** The type for array-like objects in JavaScript *)

external toOption : 'a nullable -> 'a option = "#nullable_to_opt"
external undefinedToOption : 'a undefined -> 'a option = "#undefined_to_opt"
external nullToOption : 'a null -> 'a option = "#null_to_opt"
external isNullable : 'a nullable -> bool = "#is_nullable"

external testAny : 'a -> bool = "#is_nullable"
(** The same as {!isNullable} except that it is more permissive on the types of
    input *)

external null : 'a null = "#null"
(** The same as [empty] in {!Js.Null} will be compiled as [null]*)

external undefined : 'a undefined = "#undefined"
(** The same as  [empty] {!Js.Undefined} will be compiled as [undefined]*)

external typeof : 'a -> string = "#typeof"
(** [typeof x] will be compiled as [typeof x] in JS
    Please consider functions in {!Types} for a type safe way of reflection *)

external log : 'a -> unit = "log"
[@@mel.scope "console"]
(** A convenience function to log everything *)

external log2 : 'a -> 'b -> unit = "log" [@@mel.scope "console"]
external log3 : 'a -> 'b -> 'c -> unit = "log" [@@mel.scope "console"]
external log4 : 'a -> 'b -> 'c -> 'd -> unit = "log" [@@mel.scope "console"]

external logMany : 'a array -> unit = "log"
[@@mel.scope "console"] [@@mel.variadic]
(** A convenience function to log more than 4 arguments *)

external eqNull : 'a -> 'a null -> bool = "%bs_equal_null"
external eqUndefined : 'a -> 'a undefined -> bool = "%bs_equal_undefined"
external eqNullable : 'a -> 'a nullable -> bool = "%bs_equal_nullable"

(** {4 Operators }*)

external unsafe_lt : 'a -> 'a -> bool = "#unsafe_lt"
(** [unsafe_lt a b] will be compiled as [a < b].
    It is marked as unsafe, since it is impossible
    to give a proper semantics for comparision which applies to any type *)

external unsafe_le : 'a -> 'a -> bool = "#unsafe_le"
(**  [unsafe_le a b] will be compiled as [a <= b].
     See also {!unsafe_lt} *)

external unsafe_gt : 'a -> 'a -> bool = "#unsafe_gt"
(**  [unsafe_gt a b] will be compiled as [a > b].
     See also {!unsafe_lt} *)

external unsafe_ge : 'a -> 'a -> bool = "#unsafe_ge"
(**  [unsafe_ge a b] will be compiled as [a >= b].
     See also {!unsafe_lt} *)

(** Types for JS objects *)

type 'a t
(** This used to be mark a Js object type. *)

(**/**)

module Fn : sig
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

module Internal : sig
  external opaqueFullApply : 'a -> 'a = "#full_apply"

  external run : 'a Fn.arity0 -> 'a = "#run"
  [@@ocaml.warning "-unboxable-type-in-prim-decl"]

  external opaque : 'a -> 'a = "%opaque"
end

(**/**)

(*MODULE_ALIASES*)
module Exn = Js_exn
(** Utilities for dealing with Js exceptions *)

module String = Js_string
(** Bindings to the functions in [String.prototype] *)

module Null = Js_null
(** Utility functions on  {!type-null} *)

module Undefined = Js_undefined
(** Utility functions on {!type-undefined} *)

module Nullable = Js_nullable
(** Utility functions on {!type-nullable} *)

module Array = Js_array
(** Bindings to the functions in [Array.prototype] *)

module Re = Js_re
(** Bindings to the functions in [RegExp.prototype] *)

module Promise = Js_promise
(** Bindings to JS [Promise] functions *)

module Date = Js_date
(** Bindings to the functions in JS's [Date.prototype] *)

module Dict = Js_dict
(** Utility functions to treat a JS object as a dictionary *)

module Global = Js_global
(** Bindings to functions in the JS global namespace *)

module Json = Js_json
(** Utility functions to manipulate JSON values *)

module Math = Js_math
(** Bindings to the functions in the [Math] object *)

module Obj = Js_obj
(** Utility functions on `Js.t` JS objects *)

module Typed_array = Js_typed_array
(** Bindings to the functions in [TypedArray.prototype] *)

module Types = Js_types
(** Utility functions for runtime reflection on JS types *)

module Float = Js_float
(** Bindings to functions in JavaScript's [Number] that deal with floats *)

module Int = Js_int
(** Bindings to functions in JavaScript's [Number] that deal with ints *)

module Bigint = Js_bigint
(** Bindings to functions in JavaScript's [BigInt] *)

module Console = Js_console
(* Bindings to functions in the [console] object *)

module Set = Js_set
(** Bindings to functions in [Set] *)

module WeakSet = Js_weakset
(** Bindings to functions in [WeakSet] *)

module Map = Js_map
(** Bindings to functions in [Map] *)

module WeakMap = Js_weakmap
(** Bindings to functions in [WeakMap] *)

module Iterator = Js_iterator
(** Bindings to functions on [Iterator] *)

(**/**)

module OO = Js_OO

(**/**)
