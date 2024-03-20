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

(* commented out until Melange has a plan for iterators
   type 'a array_iter = 'a array_like
*)

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

external copyWithin : to_:int -> ?start:int -> ?end_:int -> 'a t = "copyWithin"
[@@mel.send.pipe: 'a t]
(* ES2015 *)

external fill : value:'a -> ?start:int -> ?end_:int -> 'a t = "fill"
[@@mel.send.pipe: 'a t]
(* ES2015 *)

external pop : 'a t -> 'a option = "pop"
[@@mel.send] [@@mel.return undefined_to_opt]
(** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/push *)

external push : value:'a -> int = "push" [@@mel.send.pipe: 'a t]

external pushMany : values:'a array -> int = "push"
[@@mel.send.pipe: 'a t] [@@mel.variadic]

external reverseInPlace : 'a t -> 'a t = "reverse" [@@mel.send]

external shift : 'a t -> 'a option = "shift"
[@@mel.send] [@@mel.return undefined_to_opt]

external sortInPlace : 'a t -> 'a t = "sort" [@@mel.send]

external sortInPlaceWith : f:(('a -> 'a -> int)[@mel.uncurry]) -> 'a t = "sort"
[@@mel.send.pipe: 'a t]

external spliceInPlace : start:int -> remove:int -> add:'a array -> 'a t
  = "splice"
[@@mel.send.pipe: 'a t] [@@mel.variadic]

external removeFromInPlace : start:int -> 'a t = "splice"
[@@mel.send.pipe: 'a t]

external removeCountInPlace : start:int -> count:int -> 'a t = "splice"
[@@mel.send.pipe: 'a t]

external unshift : value:'a -> int = "unshift" [@@mel.send.pipe: 'a t]

external unshiftMany : values:'a array -> int = "unshift"
[@@mel.send.pipe: 'a t] [@@mel.variadic]

external concat : other:'a t -> 'a t = "concat" [@@mel.send.pipe: 'a t]

external concatMany : arrays:'a t array -> 'a t = "concat"
[@@mel.send.pipe: 'a t] [@@mel.variadic]

external includes : value:'a -> bool = "includes"
[@@mel.send.pipe: 'a t]
(** ES2015 *)

external join : ?sep:string -> string = "join" [@@mel.send.pipe: 'a t]

(** Accessor functions *)

external indexOf : value:'a -> ?start:int -> int = "indexOf"
[@@mel.send.pipe: 'a t]

external lastIndexOf : value:'a -> int = "lastIndexOf" [@@mel.send.pipe: 'a t]

external lastIndexOfFrom : value:'a -> start:int -> int = "lastIndexOf"
[@@mel.send.pipe: 'a t]

external copy : 'a t -> 'a t = "slice" [@@mel.send]

external slice : ?start:int -> ?end_:int -> 'a t = "slice"
[@@mel.send.pipe: 'a t]

external toString : 'a t -> string = "toString" [@@mel.send]
external toLocaleString : 'a t -> string = "toLocaleString" [@@mel.send]

(** Iteration functions *)

(* commented out until Melange has a plan for iterators
   external entries : 'a t -> (int * 'a) array_iter = "" [@@mel.send] (* ES2015 *)
*)

external every : f:(('a -> bool)[@mel.uncurry]) -> bool = "every"
[@@mel.send.pipe: 'a t]

external everyi : f:(('a -> int -> bool)[@mel.uncurry]) -> bool = "every"
[@@mel.send.pipe: 'a t]

external filter : f:(('a -> bool)[@mel.uncurry]) -> 'a t = "filter"
[@@mel.send.pipe: 'a t]

external filteri : f:(('a -> int -> bool)[@mel.uncurry]) -> 'a t = "filter"
[@@mel.send.pipe: 'a t]

external find : f:(('a -> bool)[@mel.uncurry]) -> 'a option = "find"
[@@mel.send.pipe: 'a t] [@@mel.return { undefined_to_opt }]
(* ES2015 *)

external findi : f:(('a -> int -> bool)[@mel.uncurry]) -> 'a option = "find"
[@@mel.send.pipe: 'a t] [@@mel.return { undefined_to_opt }]
(* ES2015 *)

external findIndex : f:(('a -> bool)[@mel.uncurry]) -> int = "findIndex"
[@@mel.send.pipe: 'a t]
(* ES2015 *)

external findIndexi : f:(('a -> int -> bool)[@mel.uncurry]) -> int = "findIndex"
[@@mel.send.pipe: 'a t]
(* ES2015 *)

external forEach : f:(('a -> unit)[@mel.uncurry]) -> unit = "forEach"
[@@mel.send.pipe: 'a t]

external forEachi : f:(('a -> int -> unit)[@mel.uncurry]) -> unit = "forEach"
[@@mel.send.pipe: 'a t]

(* commented out until Melange has a plan for iterators
   external keys : 'a t -> int array_iter = "" [@@mel.send] (* ES2015 *)
*)

external map : f:(('a -> 'b)[@mel.uncurry]) -> 'b t = "map"
[@@mel.send.pipe: 'a t]

external mapi : f:(('a -> int -> 'b)[@mel.uncurry]) -> 'b t = "map"
[@@mel.send.pipe: 'a t]

external reduce : f:(('b -> 'a -> 'b)[@mel.uncurry]) -> init:'b -> 'b = "reduce"
[@@mel.send.pipe: 'a t]

external reducei : f:(('b -> 'a -> int -> 'b)[@mel.uncurry]) -> init:'b -> 'b
  = "reduce"
[@@mel.send.pipe: 'a t]

external reduceRight : f:(('b -> 'a -> 'b)[@mel.uncurry]) -> init:'b -> 'b
  = "reduceRight"
[@@mel.send.pipe: 'a t]

external reduceRighti :
  f:(('b -> 'a -> int -> 'b)[@mel.uncurry]) -> init:'b -> 'b = "reduceRight"
[@@mel.send.pipe: 'a t]

external some : f:(('a -> bool)[@mel.uncurry]) -> bool = "some"
[@@mel.send.pipe: 'a t]

external somei : f:(('a -> int -> bool)[@mel.uncurry]) -> bool = "some"
[@@mel.send.pipe: 'a t]

(* commented out until Melange has a plan for iterators
   external values : 'a t -> 'a array_iter = "" [@@mel.send] (* ES2015 *) *)

external unsafe_get : 'a array -> int -> 'a = "%array_unsafe_get"
external unsafe_set : 'a array -> int -> 'a -> unit = "%array_unsafe_set"
