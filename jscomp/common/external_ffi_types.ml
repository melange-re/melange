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
open External_ffi_types0

module Literals = struct
  let setter_suffix = "#="
  (* let gentype_import = "genType.import" *)

  let infix_ops = [ "|."; setter_suffix; "##" ]
end

type module_bind_name =
  | Phint_name of string (* explicit hint name *)
  | Phint_nothing

type external_module_name = {
  bundle : string;
  module_bind_name : module_bind_name;
}

type arg_type = External_arg_spec.attr
(* TODO: information between [arg_type] and [arg_label] are duplicated,
   design a more compact representation so that it is also easy to seralize by
   hand *)

type arg_label = External_arg_spec.label

type external_spec =
  | Js_var of {
      name : string;
      external_module_name : external_module_name option;
      scopes : string list;
    }
  | Js_module_as_var of external_module_name
  | Js_module_as_fn of {
      external_module_name : external_module_name;
      variadic : bool;
    }
  | Js_module_as_class of external_module_name
  | Js_call of {
      name : string;
      external_module_name : external_module_name option;
      variadic : bool;
      scopes : string list;
    }
  | Js_send of {
      name : string;
      variadic : bool;
      pipe : bool;
      new_ : bool;
      js_send_scopes : string list;
    }
    (* we know it is a js send, but what will happen if you pass an ocaml object *)
  | Js_new of {
      name : string;
      external_module_name : external_module_name option;
      variadic : bool;
      scopes : string list;
    }
  | Js_set of { js_set_name : string; js_set_scopes : string list }
  | Js_get of { js_get_name : string; js_get_scopes : string list }
  | Js_get_index of { js_get_index_scopes : string list }
  | Js_set_index of { js_set_index_scopes : string list }

type return_wrapper =
  | Return_unset
  | Return_identity
  | Return_undefined_to_opt
  | Return_null_to_opt
  | Return_null_undefined_to_opt
  | Return_replaced_with_unit

type params = Params of External_arg_spec.params | Param_number of int

type t =
  | Ffi_mel of params * return_wrapper * external_spec
      (**  [Ffi_mel(args,return,attr) ]
       [return] means return value is unit or not,
        [true] means is [unit] *)
  | Ffi_obj_create of External_arg_spec.obj_params
  | Ffi_inline_const of Lam_constant.t
  | Ffi_normal
(* When it's normal, it is handled as normal c functional ffi call *)

let valid_js_char =
  let a =
    Array.init 256 ~f:(fun i ->
        let c = Char.chr i in
        (c >= 'a' && c <= 'z')
        || (c >= 'A' && c <= 'Z')
        || (c >= '0' && c <= '9')
        || c = '_' || c = '$')
  in
  fun c -> Array.unsafe_get a (Char.code c)

let valid_first_js_char =
  let a =
    Array.init 256 ~f:(fun i ->
        let c = Char.chr i in
        (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c = '_' || c = '$')
  in
  fun c -> Array.unsafe_get a (Char.code c)

(** Approximation could be improved *)
let valid_ident (s : string) =
  let len = String.length s in
  len > 0
  && valid_js_char s.[0]
  && valid_first_js_char s.[0]
  &&
  let module E = struct
    exception E
  end in
  try
    for i = 1 to len - 1 do
      if not (valid_js_char (String.unsafe_get s i)) then raise E.E
    done;
    true
  with E.E -> false

let is_package_relative_path (x : string) =
  String.starts_with x ~prefix:"./" || String.starts_with x ~prefix:"../"

let valid_global_name ~loc txt =
  if not (valid_ident txt) then
    let v = String.split_by ~keep_empty:true (fun x -> x = '.') txt in
    List.iter
      ~f:(fun s ->
        if not (valid_ident s) then
          Location.raise_errorf ~loc "%S isn't a valid JavaScript identifier"
            txt)
      v

let check_external_module_name ~loc x =
  match x with
  | { bundle = ""; _ } | { module_bind_name = Phint_name ""; _ } ->
      Location.raise_errorf ~loc "`@mel.module' name cannot be empty"
  | _ -> ()

let check_ffi ~loc ffi : bool =
  let xrelative = ref false in
  let upgrade bool = if not !xrelative then xrelative := bool in
  (match ffi with
  | Js_var { name; external_module_name; _ } ->
      upgrade (is_package_relative_path name);
      Option.iter
        (fun name -> upgrade (is_package_relative_path name.bundle))
        external_module_name;
      valid_global_name ~loc name
  | Js_send _ | Js_set _ | Js_get _ ->
      (* see https://github.com/rescript-lang/rescript-compiler/issues/2583 *)
      ()
  | Js_get_index _ (* TODO: check scopes *) | Js_set_index _ -> ()
  | Js_module_as_var external_module_name
  | Js_module_as_fn { external_module_name; variadic = _ }
  | Js_module_as_class external_module_name ->
      upgrade (is_package_relative_path external_module_name.bundle);
      check_external_module_name ~loc external_module_name
  | Js_new { external_module_name; name; _ }
  | Js_call { external_module_name; name; variadic = _; scopes = _ } ->
      Option.iter
        (fun external_module_name ->
          upgrade (is_package_relative_path external_module_name.bundle))
        external_module_name;
      Option.iter
        (fun name -> check_external_module_name ~loc name)
        external_module_name;

      valid_global_name ~loc name);
  !xrelative

let to_string (t : t) = Marshal.to_string t []

let () =
  Oprint.map_primitive_name := Oprint_mel_primitive_name.map_primitive_name

external from_bytes_unsafe : bytes -> int -> 'a = "caml_input_value_from_bytes"

(* TODO: better error message when version mismatch *)
let from_string s : t =
  if is_mel_primitive s then from_bytes_unsafe (Bytes.unsafe_of_string s) 0
  else Ffi_normal

let inline_string_primitive (s : string) (op : string option) : string list =
  let lam : Lam_constant.t =
    let unicode =
      match op with
      | Some op -> Utf8_string.is_unicode_string op
      | None -> false
    in
    Const_string { s; unicode }
  in
  [ ""; to_string (Ffi_inline_const lam) ]

(* Let's only do it for string ATM
    for boolean, and ints, a good optimizer should
    do it by default?
    But it may not work after layers of indirection
    e.g, submodule
*)
let inline_bool_primitive b : string list =
  let lam : Lam_constant.t =
    if b then Lam_constant.Const_js_true else Lam_constant.Const_js_false
  in
  [ ""; to_string (Ffi_inline_const lam) ]

(* FIXME: check overflow ?*)
let inline_int_primitive (i : int32) : string list =
  [ ""; to_string (Ffi_inline_const (Const_int { i; comment = None })) ]

let inline_int64_primitive (i : int64) : string list =
  [ ""; to_string (Ffi_inline_const (Const_int64 i)) ]

let inline_float_primitive (i : string) : string list =
  [ ""; to_string (Ffi_inline_const (Const_float i)) ]

let ffi_mel =
  let rec ffi_mel_aux acc (params : External_arg_spec.params) =
    match params with
    | { arg_type = Nothing; arg_label = Arg_empty }
        (* same as External_arg_spec.dummy*)
      :: rest ->
        ffi_mel_aux (acc + 1) rest
    | _ :: _ -> -1
    | [] -> acc
  in
  fun (params : External_arg_spec.params) return attr ->
    let n = ffi_mel_aux 0 params in
    if n < 0 then Ffi_mel (Params params, return, attr)
    else Ffi_mel (Param_number n, return, attr)

let ffi_mel_as_prims params return attr =
  [ ""; to_string (ffi_mel params return attr) ]

let ffi_obj_create obj_params = Ffi_obj_create obj_params
let ffi_obj_as_prims obj_params = [ ""; to_string (Ffi_obj_create obj_params) ]
