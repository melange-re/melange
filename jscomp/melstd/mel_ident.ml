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

module T = struct
  include Ident0

  type t = Ident.t
end

include T

let name = Ident.name
let same = Ident.same
let create_local = Ident.create_local
let create_persistent = Ident.create_persistent
let rename = Ident.rename
let print = Ident.print
let is_predef = Ident.is_predef
let reinit = Ident.reinit
let global = Ident.global

module Map = struct
  include Map.Make (T)

  let find_default ~default k t =
    match find k t with v -> v | exception Not_found -> default
end

module Set = Set_ident
module Hash = Hash_ident
module Hash_set = Hash_set_ident
