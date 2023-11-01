(* Copyright (C) 2022- Authors of Melange
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

type t = NodeJS | Es6 | Es6_global

let default = NodeJS

(* ocamlopt could not optimize such simple case..*)
let compatible ~dep t =
  match t with
  | NodeJS -> dep = NodeJS
  | Es6 -> dep = Es6
  | Es6_global -> dep = Es6_global || dep = Es6
(* As a dependency Leaf Node, it is the same either [global] or [not] *)

(* in runtime lib, [es6] and [es6] are treated the same way *)
let runtime_dir = function NodeJS -> "js" | Es6 | Es6_global -> "es6"

let runtime_package_path =
  let ( // ) = Path.( // ) in
  let melange_js = "melange.js" in
  fun js_file -> melange_js // js_file

let to_string = function
  | NodeJS -> "commonjs"
  | Es6 -> "es6"
  | Es6_global -> "es6-global"

let of_string_exn = function
  | "commonjs" -> NodeJS
  | "es6" -> Es6
  | "es6-global" -> Es6_global
  | s -> raise (Arg.Bad ("invalid module system " ^ s))

let of_string s =
  match of_string_exn s with t -> Some t | exception Arg.Bad _ -> None
