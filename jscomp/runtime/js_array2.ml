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
type 'a array_like

(* commented out until bs has a plan for iterators
   type 'a array_iter = 'a array_like
*)

external from : 'a array_like -> 'a array = "Array.from"
(* ES2015 *)

external fromMap : 'a array_like -> (('a -> 'b)[@mel.uncurry]) -> 'b array
  = "Array.from"

(* ES2015 *)

external isArray : 'a -> bool = "Array.isArray"

(* ES2015 *)
(* ES2015 *)

(* Array.of: seems pointless unless you can bind *)
external length : 'a array -> int = "length" [@@mel.get]

(* Mutator functions
*)
external copyWithin : 'a t -> to_:int -> 'a t = "copyWithin" [@@mel.send]
(* ES2015 *)

external copyWithinFrom : 'a t -> to_:int -> from:int -> 'a t = "copyWithin"
[@@mel.send]
(* ES2015 *)

external copyWithinFromRange : 'a t -> to_:int -> start:int -> end_:int -> 'a t
  = "copyWithin"
[@@mel.send]
(* ES2015 *)

external fillInPlace : 'a t -> 'a -> 'a t = "fill" [@@mel.send] (* ES2015 *)
external fillFromInPlace : 'a t -> 'a -> from:int -> 'a t = "fill" [@@mel.send]
(* ES2015 *)

external fillRangeInPlace : 'a t -> 'a -> start:int -> end_:int -> 'a t = "fill"
[@@mel.send]
(* ES2015 *)

external pop : 'a t -> 'a option = "pop"
[@@mel.send] [@@mel.return undefined_to_opt]
(** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/push *)

external push : 'a t -> 'a -> int = "push" [@@mel.send]
external pushMany : 'a t -> 'a array -> int = "push" [@@mel.send] [@@mel.splice]
external reverseInPlace : 'a t -> 'a t = "reverse" [@@mel.send]

external shift : 'a t -> 'a option = "shift"
[@@mel.send] [@@mel.return undefined_to_opt]

external sortInPlace : 'a t -> 'a t = "sort" [@@mel.send]

external sortInPlaceWith : 'a t -> (('a -> 'a -> int)[@mel.uncurry]) -> 'a t
  = "sort"
[@@mel.send]

external spliceInPlace : 'a t -> pos:int -> remove:int -> add:'a array -> 'a t
  = "splice"
[@@mel.send] [@@mel.splice]

external removeFromInPlace : 'a t -> pos:int -> 'a t = "splice" [@@mel.send]

external removeCountInPlace : 'a t -> pos:int -> count:int -> 'a t = "splice"
[@@mel.send]
(* screwy naming, but screwy function *)

external unshift : 'a t -> 'a -> int = "unshift" [@@mel.send]

external unshiftMany : 'a t -> 'a array -> int = "unshift"
[@@mel.send] [@@mel.splice]

(* Accessor functions
*)
external append : 'a t -> 'a -> 'a t = "concat"
[@@mel.send]
[@@deprecated "append is not type-safe. Use `concat` instead, and see #1884"]

external concat : 'a t -> 'a t -> 'a t = "concat" [@@mel.send]

external concatMany : 'a t -> 'a t array -> 'a t = "concat"
[@@mel.send] [@@mel.splice]

(* TODO: Not available in Node V4  *)
external includes : 'a t -> 'a -> bool = "includes" [@@mel.send]
(** ES2016 *)

external indexOf : 'a t -> 'a -> int = "indexOf" [@@mel.send]
external indexOfFrom : 'a t -> 'a -> from:int -> int = "indexOf" [@@mel.send]
external joinWith : 'a t -> string -> string = "join" [@@mel.send]
external lastIndexOf : 'a t -> 'a -> int = "lastIndexOf" [@@mel.send]

external lastIndexOfFrom : 'a t -> 'a -> from:int -> int = "lastIndexOf"
[@@mel.send]

external slice : 'a t -> start:int -> end_:int -> 'a t = "slice" [@@mel.send]
external copy : 'a t -> 'a t = "slice" [@@mel.send]
external sliceFrom : 'a t -> int -> 'a t = "slice" [@@mel.send]
external toString : 'a t -> string = "toString" [@@mel.send]
external toLocaleString : 'a t -> string = "toLocaleString" [@@mel.send]

(* Iteration functions
*)
(* commented out until bs has a plan for iterators
   external entries : 'a t -> (int * 'a) array_iter = "" [@@mel.send] (* ES2015 *)
*)

external every : 'a t -> (('a -> bool)[@mel.uncurry]) -> bool = "every"
[@@mel.send]

external everyi : 'a t -> (('a -> int -> bool)[@mel.uncurry]) -> bool = "every"
[@@mel.send]

external filter : 'a t -> (('a -> bool)[@mel.uncurry]) -> 'a t = "filter"
[@@mel.send]
(** should we use [bool] or [boolean] seems they are intechangeable here *)

external filteri : 'a t -> (('a -> int -> bool)[@mel.uncurry]) -> 'a t
  = "filter"
[@@mel.send]

external find : 'a t -> (('a -> bool)[@mel.uncurry]) -> 'a option = "find"
[@@mel.send] [@@mel.return { undefined_to_opt }]
(* ES2015 *)

external findi : 'a t -> (('a -> int -> bool)[@mel.uncurry]) -> 'a option
  = "find"
[@@mel.send] [@@mel.return { undefined_to_opt }]
(* ES2015 *)

external findIndex : 'a t -> (('a -> bool)[@mel.uncurry]) -> int = "findIndex"
[@@mel.send]
(* ES2015 *)

external findIndexi : 'a t -> (('a -> int -> bool)[@mel.uncurry]) -> int
  = "findIndex"
[@@mel.send]
(* ES2015 *)

external forEach : 'a t -> (('a -> unit)[@mel.uncurry]) -> unit = "forEach"
[@@mel.send]

external forEachi : 'a t -> (('a -> int -> unit)[@mel.uncurry]) -> unit
  = "forEach"
[@@mel.send]

(* commented out until bs has a plan for iterators
   external keys : 'a t -> int array_iter = "" [@@mel.send] (* ES2015 *)
*)

external map : 'a t -> (('a -> 'b)[@mel.uncurry]) -> 'b t = "map" [@@mel.send]

external mapi : 'a t -> (('a -> int -> 'b)[@mel.uncurry]) -> 'b t = "map"
[@@mel.send]

external reduce : 'a t -> (('b -> 'a -> 'b)[@mel.uncurry]) -> 'b -> 'b
  = "reduce"
[@@mel.send]

external reducei : 'a t -> (('b -> 'a -> int -> 'b)[@mel.uncurry]) -> 'b -> 'b
  = "reduce"
[@@mel.send]

external reduceRight : 'a t -> (('b -> 'a -> 'b)[@mel.uncurry]) -> 'b -> 'b
  = "reduceRight"
[@@mel.send]

external reduceRighti :
  'a t -> (('b -> 'a -> int -> 'b)[@mel.uncurry]) -> 'b -> 'b = "reduceRight"
[@@mel.send]

external some : 'a t -> (('a -> bool)[@mel.uncurry]) -> bool = "some"
[@@mel.send]

external somei : 'a t -> (('a -> int -> bool)[@mel.uncurry]) -> bool = "some"
[@@mel.send]

(* commented out until bs has a plan for iterators
   external values : 'a t -> 'a array_iter = "" [@@mel.send] (* ES2015 *)
*)
external unsafe_get : 'a array -> int -> 'a = "%array_unsafe_get"
external unsafe_set : 'a array -> int -> 'a -> unit = "%array_unsafe_set"
