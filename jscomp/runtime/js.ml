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

include Js_internal

(** Types for JS objects *)

type 'a t
(** This used to be mark a Js object type. *)

type +'a null = 'a Js_null.t
(** A value of this type can be either [null] or ['a].
    This type is the same as type [t] in {!Null} *)

type +'a undefined = 'a Js_undefined.t
(** A value of this type can be either [undefined] or ['a].
    This type is the same as type [t] in {!Undefined} *)

type +'a nullable = 'a Js_nullable.t
(** A value of this type can be [undefined], [null] or ['a].
    This type is the same as type [t] n {!Nullable} *)

module Exn = Js_exn
(** Provide utilities for dealing with Js exceptions *)

module String = Js_string
(** Provide bindings to JS string *)

module Null = Js_null
(** Provide utilities around ['a null] *)

module Undefined = Js_undefined
(** Provide utilities around {!type-undefined} *)

module Nullable = Js_nullable
(** Provide utilities around {!null_undefined} *)

module Array = Js_array
(** Provide bindings to Js array*)

module Re = Js_re
(** Provide bindings to Js regex expression *)

module Promise = Js_promise
(** Provide bindings to JS promise *)

module Date = Js_date
(** Provide bindings for JS Date *)

module Dict = Js_dict
(** Provide utilities for JS dictionary object *)

module Global = Js_global
(** Provide bindings to JS global functions in global namespace*)

module Json = Js_json
(** Provide utilities for json *)

module Math = Js_math
(** Provide bindings for JS [Math] object *)

module Obj = struct
  external empty : unit -> < .. > t = "" [@@mel.obj]

  external assign : < .. > t -> < .. > t -> < .. > t = "assign"
  [@@mel.scope "Object"]

  external merge :
    (_[@mel.as {json|{}|json}]) -> < .. > t -> < .. > t -> < .. > t = "assign"
  [@@mel.scope "Object"]
  (** [merge obj1 obj2] assigns the properties in [obj2] to a copy of
      [obj1]. The function returns a new object, and both arguments are not
      mutated *)

  external keys : _ t -> string array = "keys" [@@mel.scope "Object"]
end

module Typed_array = Js_typed_array
(** Provide bindings for JS typed array *)

module Types = Js_types
(** Provide utilities for manipulating JS types  *)

module Float = Js_float
(** Provide utilities for JS float *)

module Int = Js_int
(** Provide utilities for int *)

module Bigint = Js_bigint
(** Provide utilities for bigint *)

module Console = Js_console

module Set = Js_set
(** Provides bindings for ES6 Set *)

module WeakSet = Js_weakset
(** Provides bindings for ES6 WeakSet *)

module Map = Js_map
(** Provides bindings for ES6 Map *)

module WeakMap = Js_weakmap
(** Provides bindings for ES6 WeakMap *)

(**/**)

module Private = struct
  module Js_OO = struct
    include Js_OO

    (* NOTE(anmonteiro): unsafe_downgrade is exposed here instead of Js_OO
       since it depends on `'a Js.t`, defined above. *)
    external unsafe_downgrade : 'a t -> 'a = "#unsafe_downgrade"
  end
end

(**/**)
