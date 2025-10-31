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

module Literals = struct
  let setter_suffix = "#="
  (* let gentype_import = "genType.import" *)

  let infix_ops = [ "|."; setter_suffix; "##" ]
end

module Module_bind_name = struct
  type t =
    | Phint_name of string
    (* explicit hint name *)
    | Phint_nothing

  let equal t1 t2 =
    match (t1, t2) with
    | Phint_name n1, Phint_name n2 -> String.equal n1 n2
    | Phint_nothing, Phint_nothing -> true
    | Phint_name _, Phint_nothing | Phint_nothing, Phint_name _ -> false
end

module External_module_name = struct
  type t = { bundle : string; module_bind_name : Module_bind_name.t }

  let equal t1 t2 =
    String.equal t1.bundle t2.bundle
    && Module_bind_name.equal t1.module_bind_name t2.module_bind_name
end

type arg_type = External_arg_spec.t
(* TODO: information between [arg_type] and [arg_label] are duplicated,
   design a more compact representation so that it is also easy to seralize by
   hand *)

module External_spec = struct
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
      (* we know it is a js send, but what will happen if you pass an ocaml object *)
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

  let equal t1 t2 =
    match t1 with
    | Js_var { name = n1; external_module_name = mn1; scopes = ss1 } -> (
        match t2 with
        | Js_var { name = n2; external_module_name = mn2; scopes = ss2 } ->
            String.equal n1 n2
            && Option.equal ~eq:External_module_name.equal mn1 mn2
            && List.equal ~eq:String.equal ss1 ss2
        | _ -> false)
    | Js_module_as_var mn1 -> (
        match t2 with
        | Js_module_as_var mn2 -> External_module_name.equal mn1 mn2
        | _ -> false)
    | Js_module_as_fn { external_module_name = mn1; variadic = v1 } -> (
        match t2 with
        | Js_module_as_fn { external_module_name = mn2; variadic = v2 } ->
            External_module_name.equal mn1 mn2 && Bool.equal v1 v2
        | _ -> false)
    | Js_module_as_class mn1 -> (
        match t2 with
        | Js_module_as_class mn2 -> External_module_name.equal mn1 mn2
        | _ -> false)
    | Js_call
        { name = n1; external_module_name = mn1; variadic = v1; scopes = ss1 }
      -> (
        match t2 with
        | Js_call
            {
              name = n2;
              external_module_name = mn2;
              variadic = v2;
              scopes = ss2;
            } ->
            String.equal n1 n2
            && Option.equal ~eq:External_module_name.equal mn1 mn2
            && Bool.equal v1 v2
            && List.equal ~eq:String.equal ss1 ss2
        | _ -> false)
    | Js_send
        { name = n1; variadic = v1; self_idx = i1; new_ = new1; scopes = ss1 }
      -> (
        match t2 with
        | Js_send
            {
              name = n2;
              variadic = v2;
              self_idx = i2;
              new_ = new2;
              scopes = ss2;
            } ->
            String.equal n1 n2 && Bool.equal v1 v2 && Int.equal i1 i2
            && Bool.equal new1 new2
            && List.equal ~eq:String.equal ss1 ss2
        | _ ->
            false
            (* we know it is a js send, but what will happen if you pass an ocaml object *)
        )
    | Js_new
        { name = n1; external_module_name = mn1; variadic = v1; scopes = ss1 }
      -> (
        match t2 with
        | Js_new
            {
              name = n2;
              external_module_name = mn2;
              variadic = v2;
              scopes = ss2;
            } ->
            String.equal n1 n2
            && Option.equal ~eq:External_module_name.equal mn1 mn2
            && Bool.equal v1 v2
            && List.equal ~eq:String.equal ss1 ss2
        | _ -> false)
    | Js_set { name = n1; scopes = ss1 } -> (
        match t2 with
        | Js_set { name = n2; scopes = ss2 } ->
            String.equal n1 n2 && List.equal ~eq:String.equal ss1 ss2
        | _ -> false)
    | Js_get { name = n1; scopes = ss1 } -> (
        match t2 with
        | Js_get { name = n2; scopes = ss2 } ->
            String.equal n1 n2 && List.equal ~eq:String.equal ss1 ss2
        | _ -> false)
    | Js_get_index { scopes = ss1 } -> (
        match t2 with
        | Js_get_index { scopes = ss2 } -> List.equal ~eq:String.equal ss1 ss2
        | _ -> false)
    | Js_set_index { scopes = ss1 } -> (
        match t2 with
        | Js_set_index { scopes = ss2 } -> List.equal ~eq:String.equal ss1 ss2
        | _ -> false)
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

type t =
  | Ffi_mel of params * return_wrapper * External_spec.t
      (**  [Ffi_mel(args,return,attr) ]
       [return] means return value is unit or not,
        [true] means is [unit] *)
  | Ffi_obj_create of
      External_arg_spec.Obj_label.t External_arg_spec.Param.t list
  | Ffi_inline_const of Lam_constant.t
  | Ffi_normal
(* When it's normal, it is handled as normal c functional ffi call *)

let to_string (t : t) = Marshal.to_string t []

external from_bytes_unsafe : bytes -> int -> 'a = "caml_input_value_from_bytes"

(* TODO: better error message when version mismatch *)
let from_string =
  (* \132\149\166\190
   0x84 95 A6 BE Intext_magic_small intext.h
   https://github.com/ocaml/merlin/commit/b094c937c3a360eb61054f7652081b88e4f3612f
*)
  let is_mel_primitive s =
    (* TODO(anmonteiro): check this, header_size changed to 16 in 5.1 *)
    String.length s >= 20
    (* Marshal.header_size*) && String.unsafe_get s 0 = '\132'
    && String.unsafe_get s 1 = '\149'
  in
  fun s : t ->
    match is_mel_primitive s with
    | true -> from_bytes_unsafe (Bytes.unsafe_of_string s) 0
    | false -> Ffi_normal

let inline_string_primitive ?op s =
  let lam : Lam_constant.t =
    let unicode =
      match op with
      | Some op -> Utf8_string.is_unicode_string op
      | None -> false
    in
    Const_string { s; unicode }
  in
  Ffi_inline_const lam

(* Let's only do it for string ATM
    for boolean, and ints, a good optimizer should
    do it by default?
    But it may not work after layers of indirection
    e.g, submodule
*)
let inline_bool_primitive b =
  Ffi_inline_const
    (match b with
    | true -> Lam_constant.Const_js_true
    | false -> Lam_constant.Const_js_false)

let inline_int_primitive i =
  (* FIXME: check overflow? *)
  Ffi_inline_const (Const_int { i; comment = None })

let inline_int64_primitive i = Ffi_inline_const (Const_int64 i)
let inline_float_primitive i = Ffi_inline_const (Const_float i)

let ffi_mel =
  let rec ffi_mel_aux acc
      (params : External_arg_spec.Arg_label.t External_arg_spec.Param.t list) =
    match params with
    | { arg_type = Nothing; arg_label = Arg_empty }
        (* same as External_arg_spec.dummy*)
      :: rest ->
        ffi_mel_aux (acc + 1) rest
    | _ :: _ -> -1
    | [] -> acc
  in
  fun (params : External_arg_spec.Arg_label.t External_arg_spec.Param.t list)
    return
    attr
  ->
    let n = ffi_mel_aux 0 params in
    if n < 0 then Ffi_mel (Params params, return, attr)
    else Ffi_mel (Param_number n, return, attr)

let ffi_obj_create obj_params = Ffi_obj_create obj_params
