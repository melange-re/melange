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

module Arg_cst : sig
  type t = Int of int | Str of string | Js_literal of string

  val equal : t -> t -> bool
end

module Polyvar_descr : sig
  type t = {
    (* introduced by attributes `@mel.string`, `@mel.int`, `@mel.spread` *)
    descr : (string * Arg_cst.t) list;
    spread : bool;
  }

  val equal : t -> t -> bool
end

type t =
  | Poly_var of Polyvar_descr.t
  | Int of Polyvar_descr.t
  | Arg_cst of Arg_cst.t
  | Fn_uncurry_arity of int
      (** annotated with [@mel.uncurry ] or [@mel.uncurry 2]*)
  (* maybe we can improve it as a combination of {!Asttypes.constant} and tuple *)
  | Extern_unit
  | Nothing
  | Ignore
  | Unwrap of t

module Arg_label : sig
  type t = Arg_label | Arg_empty | Arg_optional

  val equal : t -> t -> bool
end

module Obj_label : sig
  type t = private
    | Obj_label of { name : string }
    | Obj_empty
    | Obj_optional of { name : string; for_sure_no_nested_option : bool }
        (** it will be ignored , side effect will be recorded *)

  val equal : t -> t -> bool
  val obj : string -> t
  val optional : for_sure_no_nested_option:bool -> string -> t
end

module Param : sig
  type nonrec 'a t = { arg_type : t; arg_label : 'a }

  val equal : eq:('a -> 'a -> bool) -> 'a t -> 'a t -> bool
end

val empty_kind : t -> Obj_label.t Param.t
val dummy : Arg_label.t Param.t
