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

type 'a t
(** Dictionary type (ie an '\{ \}' JS object). However it is restricted
    to hold a single type; therefore values must have the same type.

    This Dictionary type is mostly used with the [Js_json.t] type. *)

type key = string
(** Key type *)

val get : 'a t -> key -> 'a option
(** [get dict key] returns [None] if the [key] is not found in the
    dictionary, [Some value] otherwise *)

external unsafeGet : 'a t -> key -> 'a = ""
[@@mel.get_index]
(** [unsafeGet dict key] return the value if the [key] exists,
    otherwise an {b undefined} value is returned. Must be used only
    when the existence of a key is certain. (i.e. when having called [keys]
    function previously.

{[
Array.iter (fun key -> Js.log (Js_dict.unsafeGet dic key)) (Js_dict.keys dict)
]}
*)

external set : 'a t -> key -> 'a -> unit = ""
[@@mel.set_index]
(** [set dict key value] sets the [key]/[value] in [dict] *)

external keys : 'a t -> string array = "keys"
[@@mel.scope "Object"]
(** [keys dict] returns all the keys in the dictionary [dict]*)

external empty : unit -> 'a t = ""
[@@mel.obj]
(** [empty ()] returns an empty dictionary *)

module Js := Js_internal

val unsafeDeleteKey : (string t -> string -> unit[@u])
(** Experimental internal function *)

val entries : 'a t -> (key * 'a) array
(** [entries dict] returns the key value pairs in [dict] (ES2017) *)

val values : 'a t -> 'a array
(** [values dict] returns the values in [dict] (ES2017) *)

val fromList : (key * 'a) list -> 'a t
(** [fromList entries] creates a new dictionary containing each
[(key, value)] pair in [entries] *)

val fromArray : (key * 'a) array -> 'a t
(** [fromArray entries] creates a new dictionary containing each
[(key, value)] pair in [entries] *)

val map : f:(('a -> 'b)[@u]) -> 'a t -> 'b t
(** [map f dict] maps [dict] to a new dictionary with the same keys,
using [f] to map each value *)
