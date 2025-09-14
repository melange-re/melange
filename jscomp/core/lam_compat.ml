(* Copyright (C) 2018 Hongbo Zhang, Authors of ReScript
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

type let_kind = Lambda.let_kind = Strict | Alias | StrictOpt
type meth_kind = Lambda.meth_kind = Self | Public of string option | Cached

module Boxed_integer = struct
  type t = Lambda.boxed_integer = Pnativeint | Pint32 | Pint64

  let equal t1 t2 =
    match (t1, t2) with
    | Pnativeint, Pnativeint -> true
    | Pint32, Pint32 -> true
    | Pint64, Pint64 -> true
    | _, _ -> false
end

module Integer_comparison = struct
  type t = Lambda.integer_comparison = Ceq | Cne | Clt | Cgt | Cle | Cge

  let equal (p1 : t) (p2 : t) =
    match (p1, p2) with
    | Cge, Cge -> true
    | Cgt, Cgt -> true
    | Cle, Cle -> true
    | Clt, Clt -> true
    | Ceq, Ceq -> true
    | Cne, Cne -> true
    | _, _ -> false

  let cmp_int32 (cmp : t) (a : int32) b : bool =
    match cmp with
    | Ceq -> a = b
    | Cne -> a <> b
    | Cgt -> a > b
    | Cle -> a <= b
    | Clt -> a < b
    | Cge -> a >= b

  let cmp_int64 (cmp : t) (a : int64) b : bool =
    match cmp with
    | Ceq -> a = b
    | Cne -> a <> b
    | Cgt -> a > b
    | Cle -> a <= b
    | Clt -> a < b
    | Cge -> a >= b
end

module Float_comparison = struct
  type t = Lambda.float_comparison =
    | CFeq
    | CFneq
    | CFlt
    | CFnlt
    | CFgt
    | CFngt
    | CFle
    | CFnle
    | CFge
    | CFnge

  let equal (p1 : t) (p2 : t) =
    match (p1, p2) with
    | CFeq, CFeq -> true
    | CFneq, CFneq -> true
    | CFlt, CFlt -> true
    | CFnlt, CFnlt -> true
    | CFgt, CFgt -> true
    | CFngt, CFngt -> true
    | CFle, CFle -> true
    | CFnle, CFnle -> true
    | CFge, CFge -> true
    | CFnge, CFnge -> true
    | _, _ -> false

  let cmp_float (cmp : t) (a : float) b : bool =
    match cmp with
    | CFeq -> a = b
    | CFneq -> a <> b
    | CFlt -> a < b
    | CFnlt -> not (a < b)
    | CFgt -> a > b
    | CFngt -> not (a > b)
    | CFle -> a <= b
    | CFnle -> not (a <= b)
    | CFge -> a >= b
    | CFnge -> not (a >= b)
end

module Compile_time_constant = struct
  type t = Big_endian | Ostype_unix | Ostype_win32 | Ostype | Backend_type

  let equal p1 p2 =
    match (p1, p2) with
    | Big_endian, Big_endian -> true
    | Ostype_unix, Ostype_unix -> true
    | Ostype_win32, Ostype_win32 -> true
    | Ostype, Ostype -> true
    | Backend_type, Backend_type -> true
    | _, _ -> false
end

module Field_dbg_info = struct
  type t = Lambda.field_dbg_info =
    | Fld_na of string
    | Fld_record of { name : string; mutable_flag : Asttypes.mutable_flag }
    | Fld_module of { name : string }
    | Fld_record_inline of { name : string }
    | Fld_record_extension of { name : string }
    | Fld_tuple
    | Fld_poly_var_tag
    | Fld_poly_var_content
    | Fld_extension
    | Fld_variant
    | Fld_cons
    | Fld_array

  let equal (x : t) (y : t) =
    match x with
    | Fld_na s1 -> (
        match y with Fld_na s2 -> String.equal s1 s2 | _ -> false)
    | Fld_record { name = name1; mutable_flag = m1 } -> (
        match y with
        | Fld_record { name = name2; mutable_flag = m2 } ->
            String.equal name1 name2 && m1 = m2
        | _ -> false)
    | Fld_module { name = name1 } -> (
        match y with
        | Fld_module { name = name2 } -> String.equal name1 name2
        | _ -> false)
    | Fld_record_inline { name = name1 } -> (
        match y with
        | Fld_record_inline { name = name2 } -> String.equal name1 name2
        | _ -> false)
    | Fld_record_extension { name = name1 } -> (
        match y with
        | Fld_record_extension { name = name2 } -> String.equal name1 name2
        | _ -> false)
    | Fld_tuple -> ( match y with Fld_tuple -> true | _ -> false)
    | Fld_poly_var_tag -> (
        match y with Fld_poly_var_tag -> true | _ -> false)
    | Fld_poly_var_content -> (
        match y with Fld_poly_var_content -> true | _ -> false)
    | Fld_extension -> ( match y with Fld_extension -> true | _ -> false)
    | Fld_variant -> ( match y with Fld_variant -> true | _ -> false)
    | Fld_cons -> ( match y with Fld_cons -> true | _ -> false)
    | Fld_array -> ( match y with Fld_array -> true | _ -> false)

  let to_string (x : t) : string option =
    match x with
    | Fld_na "" -> None
    | Fld_na s -> Some s
    | Fld_array | Fld_extension | Fld_variant | Fld_cons | Fld_poly_var_tag
    | Fld_poly_var_content | Fld_tuple ->
        None
    | Fld_record { name; _ }
    | Fld_module { name; _ }
    | Fld_record_inline { name }
    | Fld_record_extension { name } ->
        Some name
end

module Set_field_dbg_info = struct
  type t = Lambda.set_field_dbg_info =
    | Fld_set_na
    | Fld_record_set of string
    | Fld_record_inline_set of string
    | Fld_record_extension_set of string

  let equal (x : t) (y : t) =
    match x with
    | Fld_set_na -> ( match y with Fld_set_na -> true | _ -> false)
    | Fld_record_set s1 -> (
        match y with Fld_record_set s2 -> String.equal s1 s2 | _ -> false)
    | Fld_record_inline_set s1 -> (
        match y with
        | Fld_record_inline_set s2 -> String.equal s1 s2
        | _ -> false)
    | Fld_record_extension_set s1 -> (
        match y with
        | Fld_record_extension_set s2 -> String.equal s1 s2
        | _ -> false)
end
