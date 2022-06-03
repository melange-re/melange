(* Copyright (C) 2017 Hongbo Zhang, Authors of ReScript
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

val rel_dependencies_alias :
  proj_dir:string -> cur_dir:string -> string list -> string list

val handle_files_per_dir :
  Buffer.t ->
  global_config:Bsb_ninja_global_vars.t ->
  root_dir:string ->
  rules:Bsb_ninja_rule.builtin ->
  package_specs:Bsb_package_specs.t ->
  js_post_build_cmd:string option ->
  files_to_install:Bsb_db.module_info Queue.t ->
  bs_dependencies:string list ->
  bs_dev_dependencies:string list ->
  Bsb_file_groups.file_group ->
  unit
