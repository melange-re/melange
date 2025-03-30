(* Copyright (C) 2020 Authors of ReScript
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

(* Note that currently there is no way to consume [Js.meth_callback]
    so it is fine to encode it with a freedom,
    but we need make it better for error message.
    - all are encoded as
    {[
      type fn =  (`Args_n of _ , 'result ) Js.fn
      type method = (`Args_n of _, 'result) Js.method
      type method_callback = (`Args_n of _, 'result) Js.method_callback
    ]}
    For [method_callback], the arity is never zero, so both [method]
    and  [fn] requires (unit -> 'a) to encode arity zero
*)

val to_uncurry_type :
  loc:Ast_helper.loc ->
  Ast_traverse.map ->
  Asttypes.arg_label ->
  (* label for error checking *)
  core_type ->
  (* First arg *)
  core_type ->
  (* Tail *)
  core_type
(** syntax : {[ int -> int -> int [@u]]} *)

val to_method_type :
  loc:Ast_helper.loc ->
  Ast_traverse.map ->
  Asttypes.arg_label ->
  (* label for error checking *)
  core_type ->
  (* First arg *)
  core_type ->
  (* Tail *)
  core_type
(** syntax {[ method : int -> int -> int ]} *)

val to_method_callback_type :
  loc:Ast_helper.loc ->
  Ast_traverse.map ->
  Asttypes.arg_label ->
  (* label for error checking *)
  core_type ->
  (* First arg *)
  core_type ->
  (* Tail *)
  core_type
(** syntax: {[ 'obj -> int -> int [@mel.this] ]} *)

val generate_method_type :
  Location.t ->
  Ast_traverse.map ->
  ?alias_type:core_type ->
  string ->
  function_param list ->
  expression ->
  core_type

val generate_arg_type :
  loc:Location.t ->
  Ast_traverse.map ->
  string ->
  function_param list ->
  expression ->
  core_type
