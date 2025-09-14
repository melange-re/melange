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

module Literals : sig
  val setter_suffix : string
  val infix_ops : string list
end

module Module_bind_name : sig
  type t =
    | Phint_name of string
    (* explicit hint name *)
    | Phint_nothing

  val equal : t -> t -> bool
end

module External_module_name : sig
  type t = { bundle : string; module_bind_name : Module_bind_name.t }

  val equal : t -> t -> bool
end

type arg_type = External_arg_spec.t

module External_spec : sig
  type t =
    | Js_var of {
        name : string;
        external_module_name : External_module_name.t option;
        scopes : string list;
      }
    | Js_module_as_var of External_module_name.t
    | Js_module_as_fn of {
        external_module_name : External_module_name.t;
        variadic : bool;
      }
    | Js_module_as_class of External_module_name.t
    | Js_call of {
        name : string;
        external_module_name : External_module_name.t option;
        variadic : bool;
        scopes : string list;
      }
    | Js_send of {
        name : string;
        variadic : bool;
        self_idx : int;
        new_ : bool;
        scopes : string list;
      }
      (* we know it is a js send, but what will happen if you pass an ocaml objct *)
    | Js_new of {
        name : string;
        external_module_name : External_module_name.t option;
        variadic : bool;
        scopes : string list;
      }
    | Js_set of { name : string; scopes : string list }
    | Js_get of { name : string; scopes : string list }
    | Js_get_index of { scopes : string list }
    | Js_set_index of { scopes : string list }

  val equal : t -> t -> bool
end

type return_wrapper =
  | Return_unset
  | Return_identity
  | Return_undefined_to_opt
  | Return_null_to_opt
  | Return_null_undefined_to_opt
  | Return_replaced_with_unit

type params =
  | Params of External_arg_spec.Arg_label.t External_arg_spec.Param.t list
  | Param_number of int

type t = private
  | Ffi_mel of params * return_wrapper * External_spec.t
  | Ffi_obj_create of
      External_arg_spec.Obj_label.t External_arg_spec.Param.t list
  | Ffi_inline_const of Lam_constant.t
  | Ffi_normal
(* Ffi_normal represents a C functional ffi call *)

val to_string : t -> string
val from_string : string -> t

(** Note *)

val inline_string_primitive : ?op:string -> string -> t
val inline_bool_primitive : bool -> t
val inline_int_primitive : int32 -> t
val inline_int64_primitive : int64 -> t
val inline_float_primitive : string -> t

val ffi_mel :
  External_arg_spec.Arg_label.t External_arg_spec.Param.t list ->
  return_wrapper ->
  External_spec.t ->
  t

val ffi_obj_create :
  External_arg_spec.Obj_label.t External_arg_spec.Param.t list -> t
