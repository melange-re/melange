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

(** JavaScript Array API *)

type 'a t = 'a array
type 'a array_like = 'a Js_array2.array_like

(* commented out until bs has a plan for iterators
   type 'a array_iter = 'a array_like
*)

external from : 'a array_like -> 'a array = "Array.from" [@@mel.val]
(* ES2015 *)

external fromMap : 'a array_like -> (('a -> 'b)[@mel.uncurry]) -> 'b array
  = "Array.from"
  [@@mel.val]
(* ES2015 *)

external isArray : 'a -> bool = "Array.isArray" [@@mel.val]

(* ES2015 *)
(* ES2015 *)

(* Array.of: seems pointless unless you can bind *)
external length : 'a array -> int = "length" [@@mel.get]

(* Mutator functions
*)
external copyWithin : to_:int -> 'this = "copyWithin"
  [@@mel.send.pipe: 'a t as 'this]
(* ES2015 *)

external copyWithinFrom : to_:int -> from:int -> 'this = "copyWithin"
  [@@mel.send.pipe: 'a t as 'this]
(* ES2015 *)

external copyWithinFromRange : to_:int -> start:int -> end_:int -> 'this
  = "copyWithin"
  [@@mel.send.pipe: 'a t as 'this]
(* ES2015 *)

external fillInPlace : 'a -> 'this = "fill" [@@mel.send.pipe: 'a t as 'this]
(* ES2015 *)

external fillFromInPlace : 'a -> from:int -> 'this = "fill"
  [@@mel.send.pipe: 'a t as 'this]
(* ES2015 *)

external fillRangeInPlace : 'a -> start:int -> end_:int -> 'this = "fill"
  [@@mel.send.pipe: 'a t as 'this]
(* ES2015 *)

external pop : 'a option = "pop"
  [@@mel.send.pipe: 'a t as 'this] [@@mel.return undefined_to_opt]
(** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/push *)

external push : 'a -> int = "push" [@@mel.send.pipe: 'a t as 'this]

external pushMany : 'a array -> int = "push"
  [@@mel.send.pipe: 'a t as 'this] [@@mel.splice]

external reverseInPlace : 'this = "reverse" [@@mel.send.pipe: 'a t as 'this]

external shift : 'a option = "shift"
  [@@mel.send.pipe: 'a t as 'this] [@@mel.return { undefined_to_opt }]

external sortInPlace : 'this = "sort" [@@mel.send.pipe: 'a t as 'this]

external sortInPlaceWith : (('a -> 'a -> int)[@mel.uncurry]) -> 'this = "sort"
  [@@mel.send.pipe: 'a t as 'this]

external spliceInPlace : pos:int -> remove:int -> add:'a array -> 'this
  = "splice"
  [@@mel.send.pipe: 'a t as 'this] [@@mel.splice]

external removeFromInPlace : pos:int -> 'this = "splice"
  [@@mel.send.pipe: 'a t as 'this]

external removeCountInPlace : pos:int -> count:int -> 'this = "splice"
  [@@mel.send.pipe: 'a t as 'this]
(* screwy naming, but screwy function *)

external unshift : 'a -> int = "unshift" [@@mel.send.pipe: 'a t as 'this]

external unshiftMany : 'a array -> int = "unshift"
  [@@mel.send.pipe: 'a t as 'this] [@@mel.splice]

(* Accessor functions
*)
external append : 'a -> 'this = "concat"
  [@@mel.send.pipe: 'a t as 'this]
  [@@deprecated "append is not type-safe. Use `concat` instead, and see #1884"]

external concat : 'this -> 'this = "concat" [@@mel.send.pipe: 'a t as 'this]

external concatMany : 'this array -> 'this = "concat"
  [@@mel.send.pipe: 'a t as 'this] [@@mel.splice]

(* TODO: Not available in Node V4  *)
external includes : 'a -> bool = "includes"
  [@@mel.send.pipe: 'a t as 'this]
(** ES2016 *)

external indexOf : 'a -> int = "indexOf" [@@mel.send.pipe: 'a t as 'this]

external indexOfFrom : 'a -> from:int -> int = "indexOf"
  [@@mel.send.pipe: 'a t as 'this]

external join : 'a t -> string = "join"
  [@@mel.send] [@@deprecated "please use joinWith instead"]

external joinWith : string -> string = "join" [@@mel.send.pipe: 'a t as 'this]

external lastIndexOf : 'a -> int = "lastIndexOf"
  [@@mel.send.pipe: 'a t as 'this]

external lastIndexOfFrom : 'a -> from:int -> int = "lastIndexOf"
  [@@mel.send.pipe: 'a t as 'this]

external lastIndexOf_start : 'a -> int = "lastIndexOf"
  [@@mel.send.pipe: 'a t as 'this] [@@deprecated "Please use `lastIndexOf"]

external slice : start:int -> end_:int -> 'this = "slice"
  [@@mel.send.pipe: 'a t as 'this]

external copy : 'this = "slice" [@@mel.send.pipe: 'a t as 'this]

external slice_copy : unit -> 'this = "slice"
  [@@mel.send.pipe: 'a t as 'this] [@@deprecated "Please use `copy`"]

external sliceFrom : int -> 'this = "slice" [@@mel.send.pipe: 'a t as 'this]

external slice_start : int -> 'this = "slice"
  [@@mel.send.pipe: 'a t as 'this] [@@deprecated "Please use `sliceFrom`"]

external toString : string = "toString" [@@mel.send.pipe: 'a t as 'this]

external toLocaleString : string = "toLocaleString"
  [@@mel.send.pipe: 'a t as 'this]

(* Iteration functions
*)
(* commented out until bs has a plan for iterators
   external entries : (int * 'a) array_iter = "" [@@mel.send.pipe: 'a t as 'this] (* ES2015 *)
*)

external every : (('a -> bool)[@mel.uncurry]) -> bool = "every"
  [@@mel.send.pipe: 'a t as 'this]

external everyi : (('a -> int -> bool)[@mel.uncurry]) -> bool = "every"
  [@@mel.send.pipe: 'a t as 'this]

external filter : (('a -> bool)[@mel.uncurry]) -> 'this = "filter"
  [@@mel.send.pipe: 'a t as 'this]
(** should we use [bool] or [boolean] seems they are intechangeable here *)

external filteri : (('a -> int -> bool)[@mel.uncurry]) -> 'this = "filter"
  [@@mel.send.pipe: 'a t as 'this]

external find : (('a -> bool)[@mel.uncurry]) -> 'a option = "find"
  [@@mel.send.pipe: 'a t as 'this] [@@mel.return { undefined_to_opt }]
(* ES2015 *)

external findi : (('a -> int -> bool)[@mel.uncurry]) -> 'a option = "find"
  [@@mel.send.pipe: 'a t as 'this] [@@mel.return { undefined_to_opt }]
(* ES2015 *)

external findIndex : (('a -> bool)[@mel.uncurry]) -> int = "findIndex"
  [@@mel.send.pipe: 'a t as 'this]
(* ES2015 *)

external findIndexi : (('a -> int -> bool)[@mel.uncurry]) -> int = "findIndex"
  [@@mel.send.pipe: 'a t as 'this]
(* ES2015 *)

external forEach : (('a -> unit)[@mel.uncurry]) -> unit = "forEach"
  [@@mel.send.pipe: 'a t as 'this]

external forEachi : (('a -> int -> unit)[@mel.uncurry]) -> unit = "forEach"
  [@@mel.send.pipe: 'a t as 'this]

(* commented out until bs has a plan for iterators
   external keys : int array_iter = "" [@@mel.send.pipe: 'a t as 'this] (* ES2015 *)
*)

external map : (('a -> 'b)[@mel.uncurry]) -> 'b t = "map"
  [@@mel.send.pipe: 'a t as 'this]

external mapi : (('a -> int -> 'b)[@mel.uncurry]) -> 'b t = "map"
  [@@mel.send.pipe: 'a t as 'this]

external reduce : (('b -> 'a -> 'b)[@mel.uncurry]) -> 'b -> 'b = "reduce"
  [@@mel.send.pipe: 'a t as 'this]

external reducei : (('b -> 'a -> int -> 'b)[@mel.uncurry]) -> 'b -> 'b
  = "reduce"
  [@@mel.send.pipe: 'a t as 'this]

external reduceRight : (('b -> 'a -> 'b)[@mel.uncurry]) -> 'b -> 'b
  = "reduceRight"
  [@@mel.send.pipe: 'a t as 'this]

external reduceRighti : (('b -> 'a -> int -> 'b)[@mel.uncurry]) -> 'b -> 'b
  = "reduceRight"
  [@@mel.send.pipe: 'a t as 'this]

external some : (('a -> bool)[@mel.uncurry]) -> bool = "some"
  [@@mel.send.pipe: 'a t as 'this]

external somei : (('a -> int -> bool)[@mel.uncurry]) -> bool = "some"
  [@@mel.send.pipe: 'a t as 'this]

(* commented out until bs has a plan for iterators
   external values : 'a array_iter = "" [@@mel.send.pipe: 'a t as 'this] (* ES2015 *)
*)
external unsafe_get : 'a array -> int -> 'a = "%array_unsafe_get"
external unsafe_set : 'a array -> int -> 'a -> unit = "%array_unsafe_set"
