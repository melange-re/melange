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

type t = Any : 'a -> t [@@unboxed] [@@ocaml.warning "-37"]

exception Error of t [@@ocaml.warning "-38"]

(* external asJsExn : exn -> t option = "caml_as_js_exn" *)
let asJsExn exn = match exn with Error t -> Some t | _ -> None

external stack : t -> string option = "stack" [@@mel.get]
external message : t -> string option = "message" [@@mel.get]
external name : t -> string option = "name" [@@mel.get]
external fileName : t -> string option = "fileName" [@@mel.get]

type error

external makeError : string -> error = "Error" [@@mel.new]
external isCamlExceptionOrOpenVariant : 'a -> bool = "caml_is_extension"

let anyToExnInternal x =
  Caml_js_exceptions.internalToOCamlException (Obj.repr x)

let raiseError str = raise (Obj.magic (makeError str : error) : exn)

type eval_error

external makeEvalError : string -> eval_error = "EvalError" [@@mel.new]

let raiseEvalError str =
  raise (Obj.magic (makeEvalError str : eval_error) : exn)

type range_error

external makeRangeError : string -> range_error = "RangeError" [@@mel.new]

let raiseRangeError str =
  raise (Obj.magic (makeRangeError str : range_error) : exn)

type reference_error

external makeReferenceError : string -> reference_error = "ReferenceError"
[@@mel.new]

let raiseReferenceError str = raise (Obj.magic (makeReferenceError str))

type syntax_error

external makeSyntaxError : string -> syntax_error = "SyntaxError" [@@mel.new]

let raiseSyntaxError str = raise (Obj.magic (makeSyntaxError str))

type type_error

external makeTypeError : string -> type_error = "TypeError" [@@mel.new]

let raiseTypeError str = raise (Obj.magic (makeTypeError str))

type uri_error

external makeURIError : string -> uri_error = "URIError" [@@mel.new]

let raiseUriError str = raise (Obj.magic (makeURIError str))

(** TODO add predicate to tell which error is which *)
(*
exception EvalError of error
exception RangeError of error
exception ReferenceError of error
exception SyntaxError of error
exception TypeError of error

 The URIError object represents an error when a global URI handling function was used in a wrong way.
exception URIError of error
*)
