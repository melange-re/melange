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

[@@@bs.config { flags = [| "-unboxed-types" |] }]

include Js_internal

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

module Array2 = Js_array2
(** Provide bindings to Js array*)

module Exn = Js_exn
(** Provide utilities for dealing with Js exceptions *)

module Vector = Js_vector [@@alert deprecated "Use Belt.Array instead"]

module String = Js_string
(** Provide bindings to JS string *)

module TypedArray2 = Js_typed_array2
(** Provide bindings for JS typed array *)

(** {12 nested modules}*)

module Null = Js_null
(** Provide utilities around ['a null] *)

module Undefined = Js_undefined
(** Provide utilities around {!undefined} *)

module Nullable = Js_null_undefined
(** Provide utilities around {!null_undefined} *)

module Null_undefined = Js_null_undefined
(** @deprecated please use {!Js.Nullable} *)

module Array = Js_array
(** Provide bindings to Js array*)

module String2 = Js_string2
(** Provide bindings to JS string *)

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

module Obj = Js_obj
(** Provide utilities for {!Js.t} *)

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

module Option = Js_option
(** Provide utilities for option *)

module Result = Js_result
(** Define the interface for result *)

module List = Js_list
(** Provide utilities for list *)

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

module Cast = Js_cast
module MapperRt = Js_mapperRt

(**/**)
