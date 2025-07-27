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

(** Hash algorithm only hash stamp, this makes sense when all identifiers are
    local (no global) *)

type 'value t

val create : int -> 'value t
val clear : 'value t -> unit
val reset : 'value t -> unit
val add : 'value t -> Ident.t -> 'value -> unit
val mem : 'value t -> Ident.t -> bool
val rank : 'value t -> Ident.t -> int (* -1 if not found*)
val find_value : 'value t -> Ident.t -> 'value (* raise if not found*)
val iter : 'value t -> (Ident.t -> 'value -> int -> unit) -> unit
val fold : 'value t -> 'b -> (Ident.t -> 'value -> int -> 'b -> 'b) -> 'b
val length : 'value t -> int
val elements : 'value t -> Ident.t list
val choose : 'value t -> Ident.t
val to_sorted_array : 'value t -> Ident.t array
