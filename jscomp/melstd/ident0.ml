(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
 * 2017 - Hongbo Zhang, Authors of ReScript
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

let js_flag = 100000008
let js_object_flag = 100000032
let is_js (i : Ident.t) = Ident.scope i = js_flag
let is_js_or_global (i : Ident.t) = Ident.global i || is_js i

type t =
  | Local of { name : string; stamp : int }
  | Scoped of { name : string; stamp : int; scope : int }
  | Global of string
  | Predef of { name : string; stamp : int }
[@@ocaml.warning "-unused-constructor"]

let stamp (id : Ident.t) =
  let stamp =
    match (Obj.magic id : t) with
    | Local { stamp; _ } | Scoped { stamp; _ } -> stamp
    | _ -> 0
  in
  stamp

(* XXX(anmonteiro): This is an artifact of the 4.12 upgrade that we need to fix
   at some point. This project (as well as the OCaml compiler, previously)
   abuses the `Ident.t` type in order to know whether some identifier comes
   from the JS side or not, with the objective of dealing with shadowing
   accordingly (semantics of OCaml and JS are different, e.g. with regards to
   recursion).

   An interesting read: https://github.com/ocaml/ocaml/pull/1980 *)
let create_unsafe_dont_use_or_bad_things_will_happen ~scope ~stamp name :
    Ident.t =
  Obj.magic (Scoped { name; stamp; scope })

let make_js_object (i : Ident.t) =
  create_unsafe_dont_use_or_bad_things_will_happen ~stamp:(stamp i)
    ~scope:(Ident.scope i lor js_object_flag)
    (Ident.name i)

(* `create_js` creates an ident that has been described to us by the JS FFI. In
   OCaml 4.06 and below, the `Ident.t` type abused `flags` and `stamp` to mark
   it as such ("global" values had a stamp of 0). After PR#1980 to OCaml, not
   only has the `Ident.t` type been made abstract, but also the `Global of
   string` constructor stopped taking "flags" (which we need to mark the value
   as coming from the JS FFI). *)
let create_js (name : string) : Ident.t =
  create_unsafe_dont_use_or_bad_things_will_happen ~stamp:0 ~scope:js_flag name

let create = Ident.create_local

(* FIXME: no need for `$' operator *)
let create_tmp =
  let tmp = "tmp" in
  fun ?(name = tmp) () -> create name

let[@inline] convert ?(op = false) (c : char) : string =
  match c with
  | '*' -> "$star"
  | '\'' -> "$p"
  | '!' -> "$bang"
  | '>' -> "$great"
  | '<' -> "$less"
  | '=' -> "$eq"
  | '+' -> "$plus"
  | '-' -> if op then "$neg" else "$"
  | '@' -> "$at"
  | '^' -> "$caret"
  | '/' -> "$slash"
  | '|' -> "$pipe"
  | '.' -> "$dot"
  | '%' -> "$percent"
  | '~' -> "$tilde"
  | '#' -> "$hash"
  | ':' -> "$colon"
  | '?' -> "$question"
  | '&' -> "$amp"
  | '(' -> "$lpar"
  | ')' -> "$rpar"
  | '{' -> "$lbrace"
  | '}' -> "$lbrace"
  | '[' -> "$lbrack"
  | ']' -> "$rbrack"
  | _ -> "$unknown"

let[@inline] no_escape (c : char) =
  match c with
  | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '$' -> true
  | _ -> false

exception Not_normal_letter of int

let name_mangle name =
  let len = Stdlib.String.length name in
  try
    for i = 0 to len - 1 do
      if not (no_escape (Stdlib.String.unsafe_get name i)) then
        raise_notrace (Not_normal_letter i)
    done;
    name (* Normal letter *)
  with Not_normal_letter i ->
    let buffer = Buffer.create len in
    for j = 0 to len - 1 do
      let c = Stdlib.String.unsafe_get name j in
      if no_escape c then Buffer.add_char buffer c
      else Buffer.add_string buffer (convert ~op:(i = 0) c)
    done;
    Buffer.contents buffer

(* TODO:
    check name conflicts with javascript conventions
   {[
     Ident.convert "^";;
     - : string = "$caret"
   ]}
   [convert name] if [name] is a js keyword,add "$$"
   otherwise do the name mangling to make sure ocaml identifier it is
   a valid js identifier
*)
let convert (name : string) =
  if Js_reserved_map.is_reserved name then (
    let len = String.length name in
    let b = Bytes.create (2 + len) in
    Bytes.set b 0 '$';
    Bytes.set b 1 '$';
    Bytes.blit_string ~src:name ~src_pos:0 ~dst:b ~dst_pos:2 ~len;
    Bytes.unsafe_to_string b)
  else name_mangle name

(** keyword could be used in property *)

(* It is currently made a persistent ident to avoid fresh ids
    which would result in different signature files
    - other solution: use lazy values
*)
let make_unused () = create "_"

(* Has to be total order, [x < y]
   and [x > y] should be consistent
   flags are not relevant here
*)
let compare (x : Ident.t) (y : Ident.t) =
  let u = stamp x - stamp y in
  if u = 0 then Stdlib.String.compare (Ident.name x) (Ident.name y) else u

let equal (x : Ident.t) (y : Ident.t) =
  if stamp x <> 0 then stamp x = stamp y
  else stamp y = 0 && Ident.name x = Ident.name y

module Mangled = struct
  type t = Reserved of string | Mangled of string

  let of_ident (id : Ident.t) : t =
    if is_js id then (* reserved by compiler *)
      Reserved (Ident.name id)
    else
      let id_name = Ident.name id in
      Mangled (convert id_name)

  let to_string = function Reserved name | Mangled name -> name
end
