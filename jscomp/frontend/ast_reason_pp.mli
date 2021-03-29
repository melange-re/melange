(* Copyright (C) 2019- Authors of ReScript
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


exception Pp_error

module ML : sig
  val parse_implementation : string -> Parsetree.structure
  val parse_interface : string -> Parsetree.signature
  val parse_implementation_with_comments : string -> Parsetree.structure * Reason_comment.t list
  val parse_interface_with_comments : string -> Parsetree.signature * Reason_comment.t list
  val format_implementation_with_comments : Format.formatter -> comments:Reason_comment.t list -> Parsetree.structure -> unit
  val format_interface_with_comments : Format.formatter -> comments:Reason_comment.t list -> Parsetree.signature -> unit
  val format_implementation : string -> string
  val format_interface : string -> string
end

module RE : sig
  val parse_implementation : string -> Parsetree.structure
  val parse_interface : string -> Parsetree.signature
  val parse_implementation_with_comments : string -> Parsetree.structure * Reason_comment.t list
  val parse_interface_with_comments : string -> Parsetree.signature * Reason_comment.t list
  val format_implementation_with_comments : Format.formatter -> comments:Reason_comment.t list -> Parsetree.structure -> unit
  val format_interface_with_comments : Format.formatter -> comments:Reason_comment.t list -> Parsetree.signature -> unit
  val format_implementation : string -> string
  val format_interface : string -> string
end

val clean:
  string ->
  unit
