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

type 'a lit = ?loc:Location.t -> unit -> 'a

val predef_option : Longident.t
val predef_some : Longident.t
val predef_none : Longident.t

module Lid : sig
  type t = Longident.t

  val val_unit : t
  val type_unit : t
  val type_int : t
  val js_fn : t
  val js_internal_full_apply : t
  val opaque : t
  val js_oo : t
  val js_meth : t
  val js_meth_callback : t
  val js_obj : t
  val hidden_field : string -> t
  val ignore_id : t
  val js_null : t
  val js_undefined : t
  val js_null_undefined : t
  val js_re_id : t
  val js_internal : t
end

type expression_lit = Parsetree.expression lit
type core_type_lit = Parsetree.core_type lit
type pattern_lit = Parsetree.pattern lit

val val_unit : expression_lit
val type_unit : core_type_lit
val type_exn : core_type_lit
val type_string : core_type_lit
val type_bool : core_type_lit
val type_int : core_type_lit
val type_int64 : Parsetree.core_type
val type_float : Parsetree.core_type
val type_any : core_type_lit
val pat_unit : pattern_lit
