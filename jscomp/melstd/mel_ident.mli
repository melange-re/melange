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

(** A wrapper around [Ident] module in compiler-libs *)

type t = Ident.t

include Ident0_intf.S

val name : t -> string
val same : t -> t -> bool
val create_local : string -> t
val create_persistent : string -> t
val rename : t -> t
val print : Format.formatter -> t -> unit
val is_predef : t -> bool
val reinit : unit -> unit
val global : t -> bool
val hash : t -> int

module Map : sig
  include MoreLabels.Map.S with type key = t

  val find_default : default:'a -> key -> 'a t -> 'a
end

module Set : MoreLabels.Set.S with type elt = t

module Hashtbl : sig
  include MoreLabels.Hashtbl.S with type key = t

  val find_default : 'a t -> key -> default:'a -> 'a
end

module Ordered_hash_map = Ordered_hash_map_local_ident
