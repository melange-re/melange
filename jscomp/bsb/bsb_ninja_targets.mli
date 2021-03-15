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




(** output should always be marked explicitly,
   otherwise the build system can not figure out clearly
   however, for the command we don't need pass `-o`
*)

val output_alias :
  ?action:string -> Buffer.t -> name:string -> deps:string list -> unit

val output_build :
  ?implicit_deps:string list ->
  ?rel_deps:string list ->
  ?bs_dependencies_deps:string list ->
  ?implicit_outputs: string list ->
  ?js_outputs: (string * bool) list ->
  outputs:string list ->
  inputs:string list ->
  rule:Bsb_ninja_rule.t ->
  string ->
  Buffer.t ->
  unit


val phony  :
  inputs:string list ->
  output:string ->
  out_channel ->
  unit

val revise_dune : string -> Buffer.t -> unit
val revise_x_dune : string -> Buffer.t -> unit

val output_finger : string ->  string -> out_channel -> unit
