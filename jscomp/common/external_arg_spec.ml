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

open Import

(** type definitions for external argument *)

module Arg_cst = struct
  type t = Int of int | Str of string | Js_literal of string

  let equal t1 t2 =
    match (t1, t2) with
    | Int i1, Int i2 -> Int.equal i1 i2
    | Str s1, Str s2 -> String.equal s1 s2
    | Js_literal s1, Js_literal s2 -> String.equal s1 s2
    | _, _ -> false
end

module Arg_label = struct
  type t = Arg_label | Arg_empty | Arg_optional

  let equal t1 t2 =
    match (t1, t2) with
    | Arg_label, Arg_label -> true
    | Arg_empty, Arg_empty -> true
    | Arg_optional, Arg_optional -> true
    | _, _ -> false
end

module Obj_label = struct
  type t =
    | Obj_label of { name : string }
    | Obj_empty
    | Obj_optional of { name : string; for_sure_no_nested_option : bool }

  let equal t1 t2 =
    match (t1, t2) with
    | Obj_label { name = n1 }, Obj_label { name = n2 } -> String.equal n1 n2
    | Obj_empty, Obj_empty -> true
    | ( Obj_optional { name = n1; for_sure_no_nested_option = b1 },
        Obj_optional { name = n2; for_sure_no_nested_option = b2 } ) ->
        String.equal n1 n2 && Bool.equal b1 b2
    | _, _ -> false

  let obj name = Obj_label { name }

  let optional ~for_sure_no_nested_option name =
    Obj_optional { name; for_sure_no_nested_option }
end

module Polyvar_descr = struct
  type t = {
    (* introduced by attributes `@mel.string`, `@mel.int`, `@mel.spread` *)
    descr : (string * Arg_cst.t) list;
    spread : bool;
  }

  let equal t1 t2 =
    List.equal
      ~eq:(fun (s1, cst1) (s2, cst2) ->
        String.equal s1 s2 && Arg_cst.equal cst1 cst2)
      t1.descr t2.descr
    && Bool.equal t1.spread t2.spread
end

(* it will be ignored , side effect will be recorded *)

(* This type is used to give some meta info on each argument *)
type t =
  | Poly_var of Polyvar_descr.t
  (* `a does not have any value*)
  | Int of Polyvar_descr.t (* ([`a | `b ] [@int])*)
  | Arg_cst of Arg_cst.t (* Constant argument *)
  | Fn_uncurry_arity of int (* annotated with [@uncurry ] or [@uncurry 2]*)
  (* maybe we can improve it as a combination of {!Asttypes.constant} and tuple *)
  | Extern_unit
  | Nothing
  | Ignore
  | Unwrap of t

let rec equal t1 t2 =
  match (t1, t2) with
  | Poly_var p1, Poly_var p2 -> Polyvar_descr.equal p1 p2
  | Int p1, Int p2 -> Polyvar_descr.equal p1 p2
  | Arg_cst cst1, Arg_cst cst2 -> Arg_cst.equal cst1 cst2
  | Fn_uncurry_arity i1, Fn_uncurry_arity i2 -> Int.equal i1 i2
  | Extern_unit, Extern_unit -> true
  | Nothing, Nothing -> true
  | Ignore, Ignore -> true
  | Unwrap t1, Unwrap t2 -> equal t1 t2
  | _, _ -> false

module Param = struct
  type nonrec 'a t = { arg_type : t; arg_label : 'a }

  let equal ~eq t1 t2 =
    equal t1.arg_type t2.arg_type && eq t1.arg_label t2.arg_label
end

let empty_kind obj_arg_type =
  { Param.arg_label = Obj_label.Obj_empty; arg_type = obj_arg_type }

let dummy = { Param.arg_type = Nothing; arg_label = Arg_label.Arg_empty }
