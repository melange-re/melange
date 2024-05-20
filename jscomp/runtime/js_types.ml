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

(** *)

type symbol
(**Js symbol type only available in ES6 *)

type bigint_val = Js.bigint
(** Js bigint type only available in ES2020 *)

type obj_val

type undefined_val
(** This type has only one value [undefined] *)

type null_val
(** This type has only one value [null] *)

type function_val

type _ t =
  | Undefined : undefined_val t
  | Null : null_val t
  | Boolean : bool t
  | Number : float t
  | String : string t
  | Function : function_val t
  | Object : obj_val t
  | Symbol : symbol t
  | BigInt : bigint_val t

type tagged_t =
  | JSFalse
  | JSTrue
  | JSNull
  | JSUndefined
  | JSNumber of float
  | JSString of string
  | JSFunction of function_val
  | JSObject of obj_val
  | JSSymbol of symbol
  | JSBigInt of bigint_val

external js_null : 'a t = "#null"

let classify (x : 'a) : tagged_t =
  let ty = Js.typeof x in
  if ty = "undefined" then JSUndefined
  else if x == Obj.magic js_null then JSNull
  else if ty = "number" then JSNumber (Obj.magic x)
  else if ty = "bigint" then JSBigInt (Obj.magic x)
  else if ty = "string" then JSString (Obj.magic x)
  else if ty = "boolean" then if Obj.magic x = true then JSTrue else JSFalse
  else if ty = "symbol" then JSSymbol (Obj.magic x)
  else if ty = "function" then JSFunction (Obj.magic x)
  else JSObject (Obj.magic x)

let test (type a) (x : 'a) (v : a t) : bool =
  match v with
  | Number -> Js.typeof x = "number"
  | Boolean -> Js.typeof x = "boolean"
  | Undefined -> Js.typeof x = "undefined"
  | Null -> x == Obj.magic js_null
  | String -> Js.typeof x = "string"
  | Function -> Js.typeof x = "function"
  | Object -> Js.typeof x = "object"
  | Symbol -> Js.typeof x = "symbol"
  | BigInt -> Js.typeof x = "bigint"
