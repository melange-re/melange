(* Copyright (C) 2015 - 2016 Bloomberg Finance L.P.
 * Copyright (C) 2017 - Hongbo Zhang, Authors of ReScript
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

(* The complexity comes from the fact that we allow custom rules which could
   conflict with our custom built-in rules
*)
type fn = ?target:string -> Out_channel.t -> unit

(******************************)
val cmj :
  global_config:Bsb_ninja_global_vars.t ->
  package_specs:Bsb_package_specs.t ->
  out_channel ->
  ?error_syntax_kind:Bsb_db.syntax_kind ->
  ?target:string ->
  string ->
  unit

val cmj_dev :
  global_config:Bsb_ninja_global_vars.t ->
  package_specs:Bsb_package_specs.t ->
  out_channel ->
  ?error_syntax_kind:Bsb_db.syntax_kind ->
  ?target:string ->
  string ->
  unit

val cmij :
  global_config:Bsb_ninja_global_vars.t ->
  package_specs:Bsb_package_specs.t ->
  out_channel ->
  ?error_syntax_kind:Bsb_db.syntax_kind ->
  ?target:string ->
  string ->
  unit

val cmij_dev :
  global_config:Bsb_ninja_global_vars.t ->
  package_specs:Bsb_package_specs.t ->
  out_channel ->
  ?error_syntax_kind:Bsb_db.syntax_kind ->
  ?target:string ->
  string ->
  unit

val cmi :
  global_config:Bsb_ninja_global_vars.t ->
  package_specs:Bsb_package_specs.t ->
  out_channel ->
  ?error_syntax_kind:Bsb_db.syntax_kind ->
  ?target:string ->
  string ->
  unit

val cmi_dev :
  global_config:Bsb_ninja_global_vars.t ->
  package_specs:Bsb_package_specs.t ->
  out_channel ->
  ?error_syntax_kind:Bsb_db.syntax_kind ->
  ?target:string ->
  string ->
  unit

val process_reason : out_channel -> unit
val ast : Bsb_ninja_global_vars.t -> out_channel -> string -> unit
val meldep : Bsb_ninja_global_vars.t -> out_channel -> string -> unit
val meldep_dev : Bsb_ninja_global_vars.t -> out_channel -> string -> unit
val namespace : Bsb_ninja_global_vars.t -> out_channel -> unit
val generators : string Map_string.t -> (out_channel -> unit) Map_string.t
