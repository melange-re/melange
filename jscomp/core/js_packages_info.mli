(* Copyright (C) 2017 Authors of ReScript
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

open Import

type output_info = { module_system : Module_system.t; suffix : Js_suffix.t }
type t

val same_package_by_name : t -> t -> bool
val empty : t
val from_name : ?t:t -> string -> t
val dump_output_info : Format.formatter -> output_info -> unit
val dump_packages_info : Format.formatter -> t -> unit

val add_npm_package_path : t -> ?module_name:string -> string -> t
(** used by command line option e.g [-mel-package-output commonjs:xx/path] *)

type file_case = Uppercase | Lowercase

val module_case : t -> output_prefix:string -> file_case

type path_info = {
  rel_path : string;
  pkg_rel_path : string;
  module_name : string option;
}

type info_query =
  | Package_script
  | Package_not_found
  | Package_found of path_info

val get_output_dir : t -> package_dir:string -> Module_system.t -> string
val query_package_infos : t -> Module_system.t -> info_query

(* Note here we compare the package info by order
   in theory, we can compare it by set semantics *)

val default_output_info : output_info
val assemble_output_info : t -> output_info list
