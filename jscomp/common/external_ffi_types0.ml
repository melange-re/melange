(* Copyright (C) 2023- Authors of Melange
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

(* \132\149\166\190
   0x84 95 A6 BE Intext_magic_small intext.h
   https://github.com/ocaml/merlin/commit/b094c937c3a360eb61054f7652081b88e4f3612f
*)
let is_mel_primitive s =
  (* TODO(anmonteiro): check this, header_size changed to 16 in 5.1 *)
  String.length s >= 20
  (* Marshal.header_size*) && String.unsafe_get s 0 = '\132'
  && String.unsafe_get s 1 = '\149'
