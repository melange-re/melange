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

(** ES6 Map API *)

open Melange_mini_stdlib

type ('k, 'v) t

external make : unit -> ('k, 'v) t = "Map" [@@mel.new]
external fromArray : ('k * 'v) array -> ('k, 'v) t = "Map" [@@mel.new]
external toArray : ('k, 'v) t -> ('k * 'v) array = "Array.from"
external size : ('k, 'v) t -> int = "size" [@@mel.get]
external has : key:'k -> bool = "has" [@@mel.send.pipe: ('k, 'v) t]
external unsafeGet : key:'k -> 'v = "get" [@@mel.send.pipe: ('k, 'v) t]

let get ~key map =
  if map |> has ~key then Some (unsafeGet ~key map) else None

external set : key:'k -> value:'v -> ('k, 'v) t = "set"
[@@mel.send.pipe: ('k, 'v) t]

external clear : ('k, 'v) t -> unit = "clear" [@@mel.send]
external delete : key:'k -> bool = "delete" [@@mel.send.pipe: ('k, 'v) t]

external forEach : f:(('v -> 'k -> ('k, 'v) t -> unit)[@u]) -> unit = "forEach"
[@@mel.send.pipe: ('k, 'v) t]

external keys : 'k Js.iterator = "keys" [@@mel.send.pipe: ('k, 'v) t]
external values : 'v Js.iterator = "values" [@@mel.send.pipe: ('k, 'v) t]

external entries : ('k * 'v) Js.iterator = "entries"
[@@mel.send.pipe: ('k, 'v) t]
