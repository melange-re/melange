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








(** High level compilation module *) 

(** This module defines a function to compile the program directly into [js]
    given [filename] and [outputprefix], 
    it will be useful if we don't care about bytecode output(generating js only).
 *)
val interface : 
  parser:(string -> Parsetree.signature) ->
  Format.formatter -> 
  string -> 
  unit

val interface_mliast : 
  Format.formatter -> 
  string  -> 
  ([`ml | `rescript | `reason ] -> unit) ->
  unit
  


(* val after_parsing_impl : 
  Format.formatter -> 
  string ->
  Parsetree.structure ->
  unit *)
(** [after_parsing_impl ppf sourcefile outputprefix ast ]
    Make sure you need run {!Res_compmisc.init_path} for set up
    Used in eval
*)

val implementation : 
  parser:(string -> Parsetree.structure) ->
  Format.formatter -> 
  string -> 
  unit
(** [implementation ppf sourcefile outprefix] compiles to JS directly *) 

val implementation_mlast : 
  Format.formatter ->
  string -> 
  ([`ml | `rescript | `reason ]  -> unit) ->
  unit

val implementation_cmj : Format.formatter -> string -> unit
(** [implementation_cmj ppf cmj_file] compiles a cmj to JS *)

val implementation_map : 
  Format.formatter -> string ->  unit