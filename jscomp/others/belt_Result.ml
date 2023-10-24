(* Copyright (C) 2017 Hongbo Zhang, Authors of ReScript
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

type ('a, 'b) t = ('a, 'b) Stdlib.result = Ok of 'a | Error of 'b

let getExn = function Ok x -> x | Error _ -> raise Not_found

let mapWithDefaultU opt default f =
  match opt with Ok x -> f x [@u] | Error _ -> default

let mapWithDefault opt default f =
  mapWithDefaultU opt default (fun [@u] x -> f x)

let mapU opt f = match opt with Ok x -> Ok (f x [@u]) | Error y -> Error y
let map opt f = mapU opt (fun [@u] x -> f x)
let flatMapU opt f = match opt with Ok x -> f x [@u] | Error y -> Error y
let flatMap opt f = flatMapU opt (fun [@u] x -> f x)
let getWithDefault opt default = match opt with Ok x -> x | Error _ -> default
let isOk = function Ok _ -> true | Error _ -> false
let isError = function Ok _ -> false | Error _ -> true

let eqU a b f =
  match (a, b) with
  | Ok a, Ok b -> f a b [@u]
  | Error _, Ok _ | Ok _, Error _ -> false
  | Error _, Error _ -> true

let eq a b f = eqU a b (fun [@u] x y -> f x y)

let cmpU a b f =
  match (a, b) with
  | Ok a, Ok b -> f a b [@u]
  | Error _, Ok _ -> -1
  | Ok _, Error _ -> 1
  | Error _, Error _ -> 0

let cmp a b f = cmpU a b (fun [@u] x y -> f x y)
