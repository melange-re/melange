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

(* The File interface provides information about files and allows JavaScript in
   a web page to access their content. *)

(* https://developer.mozilla.org/en-US/docs/Web/API/File *)

type t = Js.file

external make : string Js.iterator -> filename:string -> t = "File"
[@@mel.new]
(** [make contents_array ~filename] creates a new file from an iterable object
  such as an Array, having ArrayBuffers, TypedArrays, DataViews, Blobs,
  strings, or a mix of any of such elements, that will be put inside the File.
  Note that strings here are encoded as UTF-8, unlike the usual JavaScript
  UTF-16 strings. *)

external lastModified : t -> float = "lastModified"
[@@mel.get]
(** [lastModified t] accesses the read-only property of the File interface,
    which provides the last modified date of the file as the number of
    milliseconds since the Unix epoch (January 1, 1970 at midnight). Files
    without a known last modified date return the current date. *)

external name : t -> string = "name"
[@@mel.get]
(** The [name t] read-only property of the File interface returns the name of
    the file represented by a File object. For security reasons, the path is
    excluded from this property. *)

(* Since File is a subclass of Blob, it has all the properties and methods of Blob. *)
external size : t -> float = "size"
[@@mel.get]
(** [size t] returns the size of the Blob or File in bytes *)

external type_ : t -> string = "type"
[@@mel.get]
(** [type_ t] returns the MIME type of the file. *)

external arrayBuffer : t -> Js.Typed_array.ArrayBuffer.t Js.promise
  = "arrayBuffer"
[@@mel.send]
(** [arrayBuffer t] returns a Promise that resolves with the contents of the
    blob as binary data contained in a [Js.arrayBuffer]. *)

external bytes : t -> Js.Typed_array.Uint8Array.t Js.promise = "bytes"
[@@mel.send]
(** [bytes t] returns a Promise that resolves with a [Js.uint8Array] containing
    the contents of the blob as an array of bytes. *)

external slice : ?start:int -> ?end_:int -> ?contentType:string -> t = "slice"
[@@mel.send.pipe: t]
(** [slice ?start ?end_ ?contentType t] creates and returns a new Blob object
    which contains data from a subset of the blob on which it's called. *)

external text : t -> string Js.promise = "text"
[@@mel.send]
(** [text t] returns a Promise that resolves with a string containing the
    contents of the blob, interpreted as UTF-8. *)

(* XXX: stream can't be bound until we have some bindings to ReadableStream *)
(* https://developer.mozilla.org/en-US/docs/Web/API/ReadableStream *)
(* external stream : t -> ReadableStream.t = "stream" *)
