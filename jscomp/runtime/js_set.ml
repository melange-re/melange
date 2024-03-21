(* Copyright (C) 2024- Authors of Melange
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

(** ES6 Set API *)

type 'a t

external make : unit -> 'a t = "Set" [@@mel.new]
external fromArray : 'a array -> 'a t = "Set" [@@mel.new]
external toArray : 'a t -> 'a array = "Array.from"
external size : 'a t -> int = "size" [@@mel.get]
external add : value:'a -> 'a t = "add" [@@mel.send.pipe: 'a t]
external clear : 'a t -> unit = "clear" [@@mel.send]
external delete : value:'a -> bool = "delete" [@@mel.send.pipe: 'a t]
external forEach : f:('a -> unit) -> unit = "forEach" [@@mel.send.pipe: 'a t]
external has : value:'a -> bool = "has" [@@mel.send.pipe: 'a t]
external values : 'a Js.iterator = "values" [@@mel.send.pipe: 'a t]
external entries : ('a * 'a) Js.iterator = "entries" [@@mel.send.pipe: 'a t]

(*
 external difference : other:'a t -> 'a t = "difference" [@@mel.send.pipe: 'a t]

 external intersection : other:'a t -> 'a t = "intersection"
   [@@mel.send.pipe: 'a t]

   external isDisjointFrom : other:'a t -> bool = "isDisjointFrom"
   [@@mel.send.pipe: 'a t]

   external isSubsetOf : other:'a t -> bool = "isSubsetOf" [@@mel.send.pipe: 'a t]

   external isSupersetOf : other:'a t -> bool = "isSupersetOf"
   [@@mel.send.pipe: 'a t]

   external symmetricDifference : other:'a t -> 'a t = "symmetricDifference"
   [@@mel.send.pipe: 'a t]

   external union : other:'a t -> 'a t = "union" [@@mel.send.pipe: 'a t] *)
