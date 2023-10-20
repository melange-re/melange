type 'a t

module Fn = Js_internal.Fn

module Internal : sig
  external opaqueFullApply : 'a -> 'a = "#full_apply"
  external opaque : 'a -> 'a = "%opaque"

  external run : 'a Fn.arity0 -> 'a = "#run"
  [@@ocaml.warning "-unboxable-type-in-prim-decl"]
end

type +'a null = 'a Js_null.t
(** nullable, value of this type can be either [null] or ['a]
    this type is the same as type [t] in {!Null}
*)

type +'a undefined = 'a Js_undefined.t
(** value of this type can be either [undefined] or ['a]
    this type is the same as type [t] in {!Undefined}  *)

type +'a nullable = 'a Js_null_undefined.t
(** value of this type can be [undefined], [null] or ['a]
    this type is the same as type [t] n {!Null_undefined} *)

type +'a null_undefined = 'a nullable

external toOption : 'a nullable -> 'a option = "#nullable_to_opt"
external undefinedToOption : 'a undefined -> 'a option = "#undefined_to_opt"
external nullToOption : 'a null -> 'a option = "#null_to_opt"
external isNullable : 'a nullable -> bool = "#is_nullable"

external testAny : 'a -> bool = "#is_nullable"
(** The same as {!test} except that it is more permissive on the types of input *)

external null : 'a null = "#null"
(** The same as [empty] in {!Js.Null} will be compiled as [null]*)

external undefined : 'a undefined = "#undefined"
(** The same as  [empty] {!Js.Undefined} will be compiled as [undefined]*)

external typeof : 'a -> string = "#typeof"
(** [typeof x] will be compiled as [typeof x] in JS
    Please consider functions in {!Types} for a type safe way of reflection
*)

external log : 'a -> unit = "log"
[@@mel.scope "console"]
(** A convenience function to log everything *)

external log2 : 'a -> 'b -> unit = "log" [@@mel.scope "console"]
external log3 : 'a -> 'b -> 'c -> unit = "log" [@@mel.scope "console"]
external log4 : 'a -> 'b -> 'c -> 'd -> unit = "log" [@@mel.scope "console"]

external logMany : 'a array -> unit = "log"
[@@mel.scope "console"] [@@mel.splice]
(** A convenience function to log more than 4 arguments *)

external eqNull : 'a -> 'a null -> bool = "%bs_equal_null"
external eqUndefined : 'a -> 'a undefined -> bool = "%bs_equal_undefined"
external eqNullable : 'a -> 'a nullable -> bool = "%bs_equal_nullable"

(** {4 operators }*)

external unsafe_lt : 'a -> 'a -> bool = "#unsafe_lt"
(** [unsafe_lt a b] will be compiled as [a < b].
    It is marked as unsafe, since it is impossible
    to give a proper semantics for comparision which applies to any type
*)

external unsafe_le : 'a -> 'a -> bool = "#unsafe_le"
(**  [unsafe_le a b] will be compiled as [a <= b].
     See also {!unsafe_lt}
*)

external unsafe_gt : 'a -> 'a -> bool = "#unsafe_gt"
(**  [unsafe_gt a b] will be compiled as [a > b].
     See also {!unsafe_lt}
*)

external unsafe_ge : 'a -> 'a -> bool = "#unsafe_ge"
(**  [unsafe_ge a b] will be compiled as [a >= b].
     See also {!unsafe_lt}
*)

external unsafe_downgrade : 'a t -> 'a = "#unsafe_downgrade"

module Array2 = Js_array2
module Exn = Js_exn
module Vector = Js_vector [@@alert deprecated "Use Belt.Array instead"]
module String = Js_string
module TypedArray2 = Js_typed_array2
module Null = Js_null
module Undefined = Js_undefined
module Nullable = Js_null_undefined
module Null_undefined = Js_null_undefined
module Array = Js_array
module String2 = Js_string2
module Re = Js_re
module Promise = Js_promise
module Date = Js_date
module Dict = Js_dict
module Global = Js_global
module Json = Js_json
module Math = Js_math

module Obj : sig
  (** Provides functions for inspecting and maniplating native JavaScript objects
*)

  external empty : unit -> < .. > t = ""
  [@@mel.obj]
  (** [empty ()] returns the empty object [\{\}] *)

  external assign : < .. > t -> < .. > t -> < .. > t = "Object.assign"

  (** [assign target source] copies properties from [source] to [target]

Properties in [target] will be overwritten by properties in [source] if they
have the same key.

{b Returns} [target]

{[
(* Copy an object *)

let obj = [%obj { a = 1 }]

let copy = Js.Obj.assign (Js.Obj.empty ()) obj

(* prints "{ a: 1 }" *)
let _ = Js.log copy
]}

{[
(* Merge objects with same properties *)

let target = [%obj { a = 1; b = 1; }]
let source = [%obj { b = 2; }]

let obj = Js.Obj.assign target source

(* prints "{ a: 1, b: 2 }" *)
let _ = Js.log obj

(* prints "{ a: 1, b: 2 }", target is modified *)
let _ = Js.log target
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign> MDN
*)

  (* TODO:

     Should we map this API as directly as possible, provide some abstractions, or deliberately nerf it?

     "static":
     - Object.create
     - Object.defineProperty
     - Object.defineProperties
     - Object.entries - experimental
     - Object.getOwnPropertyDescriptor
     - Object.getOwnPropertyDescriptors
     - Object.getOwnPropertyNames
     - Object.getOwnPropertySymbols
     - Object.getPrototypeOf
     - Object.isExtensible
     - Object.isFrozen
     - Object.isSealed
     - Object.preventExtension
     - Object.seal
     - Object.setPrototypeOf
     - Object.values - experimental

     bs.send:
     - hasOwnProperty
     - isPrototypeOf
     - propertyIsEnumerable
     - toLocaleString
     - toString

     Put directly on Js?
     - Object.is
  *)

  external keys : _ t -> string array = "Object.keys"

  (** [keys obj] returns an array of the keys of [obj]'s own enumerable properties

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/keys> MDN
*)
end

module Typed_array = Js_typed_array
module Types = Js_types
module Float = Js_float
module Int = Js_int
module Bigint = Js_bigint
module Option = Js_option
module Result = Js_result
module List = Js_list
module Console = Js_console
module Set = Js_set
module WeakSet = Js_weakset
module Map = Js_map
module WeakMap = Js_weakmap
module Cast = Js_cast
module MapperRt = Js_mapperRt
