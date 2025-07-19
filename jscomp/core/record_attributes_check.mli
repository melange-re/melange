(* Copyright (C) 2019- Hongbo Zhang, Authors of ReScript
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

val find_mel_as_name : Parsetree.attribute list -> Lambda.as_modifier option

val check_mel_attributes_inclusion :
  Parsetree.attributes ->
  Parsetree.attributes ->
  string ->
  (string * string) option

val check_duplicated_labels :
  Parsetree.label_declaration list -> string Location.loc option

val fld_record : Data_types.label_description -> Lambda.field_dbg_info
val fld_record_set : Data_types.label_description -> Lambda.set_field_dbg_info
val fld_record_inline : Data_types.label_description -> Lambda.field_dbg_info

val fld_record_inline_set :
  Data_types.label_description -> Lambda.set_field_dbg_info

val fld_record_extension : Data_types.label_description -> Lambda.field_dbg_info

val fld_record_extension_set :
  Data_types.label_description -> Lambda.set_field_dbg_info

val blk_record : (Data_types.label_description * 'a) array -> Lambda.tag_info

val blk_record_ext :
  is_exn:bool -> (Data_types.label_description * 'a) array -> Lambda.tag_info

val blk_record_inlined :
  (Data_types.label_description * 'a) array ->
  string ->
  int ->
  Parsetree.attributes ->
  Lambda.tag_info
