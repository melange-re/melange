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

(** Specialized bindings to Promise. Note: For simplicity,
    this binding does not track the error type, it treat it as an opaque type
*)

type +'a t
type error

open struct
  module Js = Js_internal
end

external make :
  ((resolve:(('a -> unit)[@u]) -> reject:((exn -> unit)[@u]) -> unit)
  [@mel.uncurry]) ->
  'a t = "Promise"
[@@mel.new]

(* [make (fun resolve reject -> .. )] *)
external resolve : 'a -> 'a t = "resolve" [@@mel.scope "Promise"]
external reject : exn -> 'a t = "reject" [@@mel.scope "Promise"]
external all : 'a t array -> 'a array t = "all" [@@mel.scope "Promise"]
external all2 : 'a0 t * 'a1 t -> ('a0 * 'a1) t = "all" [@@mel.scope "Promise"]

external all3 : 'a0 t * 'a1 t * 'a2 t -> ('a0 * 'a1 * 'a2) t = "all"
[@@mel.scope "Promise"]

external all4 : 'a0 t * 'a1 t * 'a2 t * 'a3 t -> ('a0 * 'a1 * 'a2 * 'a3) t
  = "all"
[@@mel.scope "Promise"]

external all5 :
  'a0 t * 'a1 t * 'a2 t * 'a3 t * 'a4 t -> ('a0 * 'a1 * 'a2 * 'a3 * 'a4) t
  = "all"
[@@mel.scope "Promise"]

external all6 :
  'a0 t * 'a1 t * 'a2 t * 'a3 t * 'a4 t * 'a5 t ->
  ('a0 * 'a1 * 'a2 * 'a3 * 'a4 * 'a5) t = "all"
[@@mel.scope "Promise"]

external race : 'a t array -> 'a t = "race" [@@mel.scope "Promise"]

external then_ : (('a -> 'b t)[@mel.uncurry]) -> 'b t = "then"
[@@mel.send.pipe: 'a t]

external catch : ((error -> 'a t)[@mel.uncurry]) -> 'a t = "catch"
[@@mel.send.pipe: 'a t]
(* [ p |> catch handler]
    Note in JS the returned promise type is actually runtime dependent,
    if promise is rejected, it will pick the [handler] otherwise the original promise,
    to make it strict we enforce reject handler
    https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/catch
*)

(*
let errorAsExn (x :  error) (e  : (exn ->'a option))=
  if Caml_exceptions.isCamlExceptionOrOpenVariant (Obj.magic x ) then
     e (Obj.magic x)
  else None
[%mel.error?  ]
*)
