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

val std_include_dirs : unit -> string list

val no_version_header : bool ref
(** set/get header *)

val cross_module_inline : bool ref
(** cross module inline option *)

val diagnose : bool ref
(** diagnose option *)

val check_div_by_zero : bool ref
(** check-div-by-zero option *)

val tool_name : string
val syntax_only : bool ref

val cmi_only : bool ref
(** stop after generating cmi *)

val cmj_only : bool ref
(** stop after generating cmj *)

val js_stdout : bool ref
val all_module_aliases : bool ref
val no_stdlib : bool ref
val no_export : bool ref
val as_ppx : bool ref
val as_pp : bool ref
val modules : bool ref
val preamble : string option ref
val source_map : bool ref
val source_map_include_sources : bool ref
