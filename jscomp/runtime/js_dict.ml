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

open Melange_mini_stdlib
(** Provides a simple key-value dictionary abstraction over native JavaScript objects *)

type 'a t = 'a Js.dict
(** The dict type *)

type key = string
(** The key type, an alias of string *)

external unsafeGet : 'a t -> key -> 'a = ""
[@@mel.get_index]
(** [unsafeGet dict key] returns the value associated with [key] in [dict]

    This function will return an invalid value ([undefined]) if [key] does not
    exist in [dict]. It will not throw an error. *)

let ( .!() ) = unsafeGet

(** [get dict key] returns the value associated with [key] in [dict] *)
let get (type u) (dict : u t) (k : key) : u option =
  if [%raw {|k in dict|}] then Some dict.!(k) else None

external set : 'a t -> key -> 'a -> unit = ""
[@@mel.set_index]
(** [set dict key value] sets the value of [key] in [dict] to [value] *)

external keys : 'a t -> key array = "keys"
[@@mel.scope "Object"]
(** [keys dict] returns an array of all the keys in [dict] *)

external empty : unit -> 'a t = ""
[@@mel.obj]
(** [empty ()] creates an empty dictionary *)

let unsafeDeleteKey : (string t -> string -> unit[@u]) =
  [%raw {| function (dict,key){
      delete dict[key];
     }
  |}]

external unsafeCreateArray : int -> 'a array = "Array" [@@mel.new]

let entries dict =
  let keys = keys dict in
  let l = Js.Array.length keys in
  let values = unsafeCreateArray l in
  for i = 0 to l - 1 do
    let key = Js.Array.unsafe_get keys i in
    Js.Array.unsafe_set values i (key, dict.!(key))
  done;
  values

let values dict =
  let keys = keys dict in
  let l = Js.Array.length keys in
  let values = unsafeCreateArray l in
  for i = 0 to l - 1 do
    Js.Array.unsafe_set values i dict.!(Js.Array.unsafe_get keys i)
  done;
  values

let fromList entries =
  let dict = empty () in
  let rec loop = function
    | [] -> dict
    | (key, value) :: rest ->
        set dict key value;
        loop rest
  in
  loop entries

let fromArray entries =
  let dict = empty () in
  let l = Js.Array.length entries in
  for i = 0 to l - 1 do
    let key, value = Js.Array.unsafe_get entries i in
    set dict key value
  done;
  dict

let map ~f source =
  let target = empty () in
  let keys = keys source in
  let l = Js.Array.length keys in
  for i = 0 to l - 1 do
    let key = Js.Array.unsafe_get keys i in
    set target key (f (unsafeGet source key) [@u])
  done;
  target
