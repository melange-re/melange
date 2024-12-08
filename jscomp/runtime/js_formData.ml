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

(* Provides a way to easily construct a set of key/value pairs representing
   form fields and their values, which can then be sent using
   `XMLHttpRequest.send()`. It uses the same format a form would use if the
   encoding type were set to "multipart/form-data". *)

type t

type entryValue
(** The values returned by the `get{,All}` and iteration functions is either a
    string or a Blob. Melange uses an abstract type and defers to users of the
    API to handle it according to their application needs. *)

external make : unit -> t = "FormData"
[@@mel.new]
(** [make ()] creates a new [FormData] object, initially empty. *)

external append :
  name:string ->
  value:
    ([ `String of string | `Object of < .. > Js.t | `Dict of _ Js.dict ]
    [@mel.unwrap]) ->
  ?filename:string ->
  unit = "append"
[@@mel.send.pipe: t]
(** [append t ~name ~value] appends a new value onto an existing key inside a
    FormData object, or adds the key if it does not already exist. *)

external appendBlob :
  name:string ->
  value:([ `Blob of Js.blob | `File of Js.file ][@mel.unwrap]) ->
  ?filename:string ->
  unit = "append"
[@@mel.send.pipe: t]
(** [appendBlob t ~name ~value] appends a new value onto an existing key inside
    a FormData object, or adds the key if it does not already exist. This
    method differs from [append] in that instances in the Blob hierarchy can
    pass a third filename argument. *)

external delete : name:string -> unit = "delete"
[@@mel.send.pipe: t]
(** [delete t ~name] deletes a key and its value(s) from a FormData object. *)

external get : name:string -> entryValue option = "get"
[@@mel.send.pipe: t] [@@mel.return null_to_opt]
(** [get t ~name] returns the first value associated with a given key from
    within a FormData object. If you expect multiple values and want all of
    them, use {!getAll} instead. *)

external getAll : name:string -> entryValue array = "getAll"
[@@mel.send.pipe: t]
(** [getAll ~name] returns all the values associated with a given key from
    within a FormData object. *)

external set :
  name:string ->
  ([ `String of string | `Object of < .. > Js.t | `Dict of _ Js.dict ]
  [@mel.unwrap]) ->
  unit = "set"
[@@mel.send.pipe: t]
(** [set t ~name ~value] sets a new value for an existing key inside a FormData
    object, or adds the key/value if it does not already exist. *)

external setBlob :
  name:string ->
  ([ `Blob of Js.blob | `File of Js.file ][@mel.unwrap]) ->
  ?filename:string ->
  unit = "set"
[@@mel.send.pipe: t]
(** [setBlob t ~name ~value ?filename] sets a new value for an existing key
    inside a FormData object, or adds the key/value if it does not already
    exist. This method differs from [set] in that instances in the Blob
    hierarchy can pass a third filename argument. *)

external has : name:string -> bool = "has"
[@@mel.send.pipe: t]
(** [has ~name] returns whether a FormData object contains a certain key. *)

external keys : string Js.iterator = "keys"
[@@mel.send.pipe: t]
(** [keys t] returns an iterator which iterates through all keys contained in
    the FormData. The keys are strings. *)

external values : entryValue Js.iterator = "values"
[@@mel.send.pipe: t]
(** [values t] returns an iterator which iterates through all values contained
    in the FormData. The values are strings or Blob objects. *)

external entries : (string * entryValue) Js.iterator = "entries"
[@@mel.send.pipe: t]
(** [entries t] returns an iterator which iterates through all key/value pairs
    contained in the FormData. *)
