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
module E = Js_exp_make

let constant_int_argument (args : J.expression list) =
  match args with
  | [ { expression_desc = Number (Int { i; _ }); _ } ] -> Some i
  | _ -> None

let runtime_module = function
  | Lam_ccall.Bytes -> Js_runtime_modules.bytes
  | Float -> Js_runtime_modules.float
  | Caml_primitive -> Js_runtime_modules.caml_primitive
  | String -> Js_runtime_modules.string
  | Exceptions -> Js_runtime_modules.exceptions
  | Oo -> Js_runtime_modules.oo
  | Sys -> Js_runtime_modules.sys
  | Lexer -> Js_runtime_modules.lexer
  | Parser -> Js_runtime_modules.parser
  | Array -> Js_runtime_modules.array
  | Io -> Js_runtime_modules.io
  | Format -> Js_runtime_modules.format
  | Obj -> Js_runtime_modules.obj_runtime
  | Md5 -> Js_runtime_modules.md5
  | Hash_primitive -> Js_runtime_modules.hash_primitive
  | Hash -> Js_runtime_modules.hash

let string_comparison comparison args =
  match args with
  | [ left; right ] -> (
      match comparison with
      | Lam_ccall.Eq -> E.string_equal left right
      | Ne ->
          (* TODO: convert to the OCaml operation. *)
          E.string_comp NotEqEq left right
      | Le -> E.string_comp Le left right
      | Lt -> E.string_comp Lt left right
      | Ge -> E.string_comp Ge left right
      | Gt -> E.string_comp Gt left right)
  | _ -> assert false

let bool_comparison comparison args =
  match args with
  | [ left; right ] ->
      E.bool_comp
        (match comparison with
        | Lam_ccall.Eq -> Ceq
        | Ne ->
            (* TODO: specialize using the OCaml operation. *)
            Cne
        | Le -> Cle
        | Lt -> Clt
        | Ge -> Cge
        | Gt -> Cgt)
        left right
  | _ -> assert false

let int64_operation operation args =
  match operation with
  | Lam_ccall.Int64_succ ->
      E.runtime_call ~module_name:Js_runtime_modules.int64 ~fn_name:"succ" args
  | Int64_to_string ->
      E.runtime_call ~module_name:Js_runtime_modules.int64 ~fn_name:"to_string"
        args
  | Int64_equal_null -> Js_long.equal_null args
  | Int64_equal_undefined -> Js_long.equal_undefined args
  | Int64_equal_nullable -> Js_long.equal_nullable args
  | Int64_to_float -> Js_long.to_float args
  | Int64_of_float -> Js_long.of_float args
  | Int64_compare -> Js_long.compare args
  | Int64_bits_of_float -> Js_long.bits_of_float args
  | Int64_float_of_bits -> Js_long.float_of_bits args
  | Int64_bswap -> Js_long.swap args
  | Int64_min -> Js_long.min args
  | Int64_max -> Js_long.max args

let nativeint_operation operation args =
  match (operation, args) with
  | Lam_ccall.Nativeint_add, [ left; right ] -> E.unchecked_int32_add left right
  | Nativeint_div, [ left; right ] -> E.int32_div left right ~checked:false
  | Nativeint_mod, [ left; right ] -> E.int32_mod left right ~checked:false
  | Nativeint_lsr, [ left; right ] -> E.int32_lsr left right
  | Nativeint_mul, [ left; right ] -> E.unchecked_int32_mul left right
  | _ -> assert false

let polymorphic_comparison loc prim_name operation args =
  match (operation, args) with
  | Lam_ccall.Polymorphic_not_equal, [ left; right ]
    when E.for_sure_js_null_undefined left || E.for_sure_js_null_undefined right
    ->
      (* FIXME: address_equal. *)
      E.neq_null_undefined_boolean left right
  | Polymorphic_equal, [ left; right ]
    when E.for_sure_js_null_undefined left || E.for_sure_js_null_undefined right
    ->
      (* FIXME: address_equal. *)
      E.eq_null_undefined_boolean left right
  | (Polymorphic_equal | Polymorphic_not_equal | Polymorphic_other), _ ->
      Location.prerr_warning loc Warnings.Mel_polymorphic_comparison;
      E.runtime_call ~module_name:Js_runtime_modules.obj_runtime
        ~fn_name:prim_name args

let min_max comparison prim_name args =
  match args with
  | [ left; right ] ->
      if
        Js_analyzer.is_okay_to_duplicate left
        && Js_analyzer.is_okay_to_duplicate right
      then E.econd (E.js_comp comparison left right) left right
      else
        E.runtime_call ~module_name:Js_runtime_modules.caml_primitive
          ~fn_name:prim_name args
  | _ -> assert false

(*
   There are two things we need consider:
   1.  For some primitives we can replace caml-primitive with js primitives directly
   2.  For some standard library functions, we prefer to replace with javascript primitives
    For example [Pervasives["^"] -> ^]
    We can collect all mli files in OCaml and replace it with an efficient javascript runtime

   TODO: return type to be expression is ugly,
   we should allow return block
*)
let translate loc (ccall : Lam_ccall.t) (args : J.expression list) :
    J.expression =
  let prim_name = Lam_ccall.name ccall in
  let call runtime =
    E.runtime_call ~module_name:(runtime_module runtime) ~fn_name:prim_name args
  in
  let fallback () =
    Location.prerr_warning loc (Mel_unimplemented_primitive prim_name);
    E.resolve_and_apply prim_name args
  in
  match Lam_ccall.behavior ccall with
  | Builtin (builtin, _) -> (
      match builtin with
      | Float_add -> (
          match args with
          | [ left; right ] -> E.float_add left right (* TODO: float plus. *)
          | _ -> assert false)
      | Float_div -> (
          match args with
          | [ left; right ] -> E.float_div left right
          | _ -> assert false)
      | Float_sub -> (
          match args with
          | [ left; right ] -> E.float_minus left right
          | _ -> assert false)
      | Float_equal -> (
          match args with
          | [ left; right ] -> E.float_equal left right
          | _ -> assert false)
      | Float_greater_equal -> (
          match args with
          | [ left; right ] -> E.float_comp CFge left right
          | _ -> assert false)
      | Float_greater -> (
          match args with
          | [ left; right ] -> E.float_comp CFgt left right
          | _ -> assert false)
      | Identity -> ( match args with [ arg ] -> arg | _ -> assert false)
      | To_int32 -> (
          (* TODO: do more checking when converting to int32. *)
          match args with
          | [ arg ] -> E.to_int32 arg
          | _ -> assert false)
      | Runtime_call (runtime, runtime_name) ->
          let fn_name =
            match runtime_name with
            | Primitive_name -> prim_name
            | Runtime_name name -> name
          in
          E.runtime_call ~module_name:(runtime_module runtime) ~fn_name args
      | Int64 operation -> int64_operation operation args
      | Float_mod -> (
          match args with
          | [ left; right ] -> E.float_mod left right
          | _ -> assert false)
      | Float_fma -> (
          match args with
          | [ first; second; third ] ->
              E.float_add (E.float_mul first second) third
          | _ -> assert false)
      | String_repeat -> (
          match args with
          | [ count; { expression_desc = Number (Int { i; _ }); _ } ] -> (
              let string = String.make 1 (Char.chr (Int32.to_int i)) in
              match count.expression_desc with
              | Number (Int { i = 1l; _ }) -> E.str string
              | _ ->
                  E.call
                    (E.dot (E.str string) "repeat")
                    [ count ] ~info:Js_call_info.builtin_runtime_call)
          | _ ->
              E.runtime_call ~module_name:Js_runtime_modules.string
                ~fn_name:"make" args)
      | String_comparison comparison -> string_comparison comparison args
      | Bool_comparison comparison -> bool_comparison comparison args
      | Int_equal -> (
          match args with
          | [ left; right ] -> E.int_comp Ceq left right
          | _ -> assert false)
      | Float_nullable_equal -> (
          match args with
          | [ left; right ] -> E.float_comp CFeq left right
          | _ -> assert false)
      | String_nullable_equal -> (
          match args with
          | [ left; right ] -> E.string_comp EqEqEq left right
          | _ -> assert false)
      | Create_bytes -> (
          (* [Bytes.create]. For an invalid range, JavaScript raises a
             [RangeError], while OCaml raises [Invalid_argument]; preserve the
             existing semantics. Bytes are represented as JavaScript arrays. *)
          match args with
          | [ { expression_desc = Number (Int { i; _ }); _ } ] when i < 8l ->
              (* Invariant: bytes are [int array]. *)
              E.array NA
                (if i = 0l then []
                 else
                   List.init ~len:(Int32.to_int i) ~f:(fun _ ->
                       E.zero_int_literal))
          | _ ->
              E.runtime_call ~module_name:Js_runtime_modules.bytes
                ~fn_name:"caml_create_bytes" args)
      | Bool_compare -> (
          match args with
          | [
           { expression_desc = Bool left; _ };
           { expression_desc = Bool right; _ };
          ] ->
              let comparison = compare (left : bool) right in
              E.int
                (if comparison = 0 then 0l
                 else if comparison > 0 then 1l
                 else -1l)
          | _ -> call Caml_primitive)
      | Min -> min_max Clt prim_name args
      | Max -> min_max Cgt prim_name args
      | Unit -> List.fold_right args ~init:E.unit ~f:E.seq
      | Array_dup -> (
          match args with
          | [ arg ] -> (
              match arg.expression_desc with
              | Array _ | Caml_block _ -> arg
              (* We created a temporary block, copied it, and immediately
                 discarded it, so the copy can be canceled. *)
              | _ ->
                  E.runtime_call ~module_name:Js_runtime_modules.array
                    ~fn_name:"dup" args)
          | _ -> assert false)
      | Polymorphic_comparison operation ->
          polymorphic_comparison loc prim_name operation args
      | Obj_tag -> (
          (* In OCaml, [int] has tag 1000 and [string] has tag 252. We also
             need to check nullary values. *)
          match args with
          | [ arg ] -> E.tag arg
          | _ -> assert false)
      (* TODO: primitive not implemented yet. *)
      | Install_signal_handler -> (
          match args with
          | [ number; behavior ] -> E.seq number behavior (* TODO *)
          | _ -> assert false)
      | Nativeint operation -> nativeint_operation operation args)
  | Conditional conditional -> (
      match constant_int_argument args with
      | Some argument -> (
          match Lam_ccall.resolve_conditional conditional argument with
          | Some (runtime, name) -> E.runtime_ref (runtime_module runtime) name
          | None -> fallback ())
      | None -> fallback ())
  | External _ -> fallback ()
(*we dont use [throw] here, since [throw] is an statement
  so we wrap in IIFE
  TODO: we might provoide a hook for user to provide polyfill.
  For example `Mel_global.xxx`
*)
