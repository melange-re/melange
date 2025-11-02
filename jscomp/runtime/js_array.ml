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
type 'a array_like = 'a Js.array_like

external from : 'a array_like -> 'a array = "from" [@@mel.scope "Array"]
(* ES2015 *)

external fromMap : 'a array_like -> f:(('a -> 'b)[@mel.uncurry]) -> 'b array
  = "from"
[@@mel.scope "Array"]
(* ES2015 *)

external isArray : 'a -> bool = "isArray" [@@mel.scope "Array"]
(* ES2015 *)

(* Array.of: seems pointless unless you can bind *)
external length : 'a array -> int = "length" [@@mel.get]

(** Mutating functions *)

external copyWithin :
  to_:int -> ?start:int -> ?end_:int -> ('a t[@mel.this]) -> 'a t = "copyWithin"
[@@mel.send]
(* ES2015 *)

external fill : value:'a -> ?start:int -> ?end_:int -> ('a t[@mel.this]) -> 'a t
  = "fill"
[@@mel.send]
(* ES2015 *)

external flat : ('a t t[@mel.this]) -> 'a t = "flat" [@@mel.send]
(* ES2019 *)

external pop : 'a t -> 'a option = "pop"
[@@mel.send] [@@mel.return undefined_to_opt]
(** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/pop *)

external push : value:'a -> ('a t[@mel.this]) -> int = "push" [@@mel.send]

external pushMany : values:'a array -> ('a t[@mel.this]) -> int = "push"
[@@mel.send] [@@mel.variadic]

external toReversed : 'a t -> 'a t = "toReversed" [@@mel.send]
(** returns a new array with the elements in reversed order. (ES2023) *)

external reverseInPlace : 'a t -> 'a t = "reverse" [@@mel.send]

external shift : 'a t -> 'a option = "shift"
[@@mel.send] [@@mel.return undefined_to_opt]

external toSorted : 'a t -> 'a t = "toSorted" [@@mel.send]
(** returns a new array with the elements sorted in ascending order. (ES2023) *)

external toSortedWith :
  f:(('a -> 'a -> int)[@mel.uncurry]) -> ('a t[@mel.this]) -> 'a t = "toSorted"
[@@mel.send]
(** returns a new array with the elements sorted in ascending order. (ES2023) *)

external sortInPlace : 'a t -> 'a t = "sort" [@@mel.send]

external sortInPlaceWith :
  f:(('a -> 'a -> int)[@mel.uncurry]) -> ('a t[@mel.this]) -> 'a t = "sort"
[@@mel.send]

external spliceInPlace :
  start:int -> remove:int -> add:'a array -> ('a t[@mel.this]) -> 'a t
  = "splice"
[@@mel.send] [@@mel.variadic]
(** changes the contents of the given array by removing or replacing existing elements and/or adding new elements in place.
    returns a new array containing the removed elements.
*)

external toSpliced :
  start:int -> remove:int -> add:'a array -> ('a t[@mel.this]) -> 'a t
  = "toSpliced"
[@@mel.send] [@@mel.variadic]
(** returns a new array with some elements removed and/or replaced at a given index. (ES2023) *)

external removeFromInPlace : start:int -> ('a t[@mel.this]) -> 'a t = "splice"
[@@mel.send]
(** removes all elements from the given array starting at the [start] index and returns the removed elements. *)

external removeFrom : start:int -> ('a t[@mel.this]) -> 'a t = "toSpliced"
[@@mel.send]
(** returns a new array with elements removed starting at the [start] index. (ES2023) *)

external removeCountInPlace :
  start:int -> count:int -> ('a t[@mel.this]) -> 'a t = "splice"
[@@mel.send]
(** removes [count] elements from the given array starting at the [start] index and returns the removed elements. *)

external removeCount :
  start:int -> count:int -> ('a t[@mel.this]) -> 'a t = "toSpliced"
[@@mel.send]
(** returns a new array with [count] elements removed starting at the [start] index. (ES2023) *)

external unshift : value:'a -> ('a t[@mel.this]) -> int = "unshift" [@@mel.send]

external unshiftMany : values:'a array -> ('a t[@mel.this]) -> int = "unshift"
[@@mel.send] [@@mel.variadic]

external concat : other:'a t -> ('a t[@mel.this]) -> 'a t = "concat"
[@@mel.send]

external concatMany : arrays:'a t array -> ('a t[@mel.this]) -> 'a t = "concat"
[@@mel.send] [@@mel.variadic]

external includes : value:'a -> ('a t[@mel.this]) -> bool = "includes"
[@@mel.send]
(** ES2015 *)

external join : ?sep:string -> ('a t[@mel.this]) -> string = "join" [@@mel.send]

(** Accessor functions *)

external at : index:int -> ('a t[@mel.this]) -> 'a option
  = "at"
[@@mel.send] [@@mel.return { undefined_to_opt }]
(** ES2022 *)

external indexOf : value:'a -> ?start:int -> ('a t[@mel.this]) -> int
  = "indexOf"
[@@mel.send]

external lastIndexOf : value:'a -> ('a t[@mel.this]) -> int = "lastIndexOf"
[@@mel.send]

external lastIndexOfFrom : value:'a -> start:int -> ('a t[@mel.this]) -> int
  = "lastIndexOf"
[@@mel.send]

external copy : 'a t -> 'a t = "slice" [@@mel.send]

external slice : ?start:int -> ?end_:int -> ('a t[@mel.this]) -> 'a t = "slice"
[@@mel.send]

external toString : 'a t -> string = "toString" [@@mel.send]
external toLocaleString : 'a t -> string = "toLocaleString" [@@mel.send]

(** Iteration functions *)

external entries : 'a t -> (int * 'a) Js.iterator = "entries" [@@mel.send]

external every : f:(('a -> bool)[@mel.uncurry]) -> ('a t[@mel.this]) -> bool
  = "every"
[@@mel.send]

external everyi :
  f:(('a -> int -> bool)[@mel.uncurry]) -> ('a t[@mel.this]) -> bool = "every"
[@@mel.send]

external filter : f:(('a -> bool)[@mel.uncurry]) -> ('a t[@mel.this]) -> 'a t
  = "filter"
[@@mel.send]

external filteri :
  f:(('a -> int -> bool)[@mel.uncurry]) -> ('a t[@mel.this]) -> 'a t = "filter"
[@@mel.send]

external find : f:(('a -> bool)[@mel.uncurry]) -> ('a t[@mel.this]) -> 'a option
  = "find"
[@@mel.send] [@@mel.return { undefined_to_opt }]
(* ES2015 *)

external findi :
  f:(('a -> int -> bool)[@mel.uncurry]) -> ('a t[@mel.this]) -> 'a option
  = "find"
[@@mel.send] [@@mel.return { undefined_to_opt }]
(* ES2015 *)

external findLast : f:(('a -> bool)[@mel.uncurry]) -> ('a t[@mel.this]) -> 'a option
  = "findLast"
[@@mel.send] [@@mel.return { undefined_to_opt }]
(* ES2015 *)

external findLasti :
  f:(('a -> int -> bool)[@mel.uncurry]) -> ('a t[@mel.this]) -> 'a option
  = "findLast"
[@@mel.send] [@@mel.return { undefined_to_opt }]
(* ES2015 *)

external findIndex : f:(('a -> bool)[@mel.uncurry]) -> ('a t[@mel.this]) -> int
  = "findIndex"
[@@mel.send]
(* ES2015 *)

external findIndexi :
  f:(('a -> int -> bool)[@mel.uncurry]) -> ('a t[@mel.this]) -> int
  = "findIndex"
[@@mel.send]
(* ES2015 *)

external findLastIndex : f:(('a -> bool)[@mel.uncurry]) -> ('a t[@mel.this]) -> int
  = "findLastIndex"
[@@mel.send]
(* ES2015 *)

external findLastIndexi :
  f:(('a -> int -> bool)[@mel.uncurry]) -> ('a t[@mel.this]) -> int
  = "findLastIndex"
[@@mel.send]
(* ES2015 *)

external forEach : f:(('a -> unit)[@mel.uncurry]) -> ('a t[@mel.this]) -> unit
  = "forEach"
[@@mel.send]

external forEachi :
  f:(('a -> int -> unit)[@mel.uncurry]) -> ('a t[@mel.this]) -> unit = "forEach"
[@@mel.send]

external keys : 'a t -> int Js.iterator = "keys" [@@mel.send]

external map : f:(('a -> 'b)[@mel.uncurry]) -> ('a t[@mel.this]) -> 'b t = "map"
[@@mel.send]

external mapi : f:(('a -> int -> 'b)[@mel.uncurry]) -> ('a t[@mel.this]) -> 'b t
  = "map"
[@@mel.send]

external reduce :
  f:(('b -> 'a -> 'b)[@mel.uncurry]) -> init:'b -> ('a t[@mel.this]) -> 'b
  = "reduce"
[@@mel.send]

external reducei :
  f:(('b -> 'a -> int -> 'b)[@mel.uncurry]) ->
  init:'b ->
  ('a t[@mel.this]) ->
  'b = "reduce"
[@@mel.send]

external reduceRight :
  f:(('b -> 'a -> 'b)[@mel.uncurry]) -> init:'b -> ('a t[@mel.this]) -> 'b
  = "reduceRight"
[@@mel.send]

external reduceRighti :
  f:(('b -> 'a -> int -> 'b)[@mel.uncurry]) ->
  init:'b ->
  ('a t[@mel.this]) ->
  'b = "reduceRight"
[@@mel.send]

external some : f:(('a -> bool)[@mel.uncurry]) -> ('a t[@mel.this]) -> bool
  = "some"
[@@mel.send]

external somei :
  f:(('a -> int -> bool)[@mel.uncurry]) -> ('a t[@mel.this]) -> bool = "some"
[@@mel.send]

external values : 'a t -> 'a Js.iterator = "values" [@@mel.send]
external unsafe_get : 'a array -> int -> 'a = "%array_unsafe_get"
external unsafe_set : 'a array -> int -> 'a -> unit = "%array_unsafe_set"
