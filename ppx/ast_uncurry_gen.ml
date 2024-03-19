(* Copyright (C) 2020- Hongbo Zhang, Authors of ReScript
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
open Ast_helper

(* Handling `fun [@this]` used in `object [@u] end` *)
let to_method_callback loc (self : Ast_traverse.map) label pat body :
    expression_desc =
  Error.optional_err ~loc label;
  let rec aux acc (body : expression) =
    match Ast_attributes.process_attributes_rev body.pexp_attributes with
    | Nothing, _ -> (
        match body.pexp_desc with
        | Pexp_fun (arg_label, _, arg, body) ->
            Error.optional_err ~loc arg_label;
            aux ((arg_label, self#pattern arg) :: acc) body
        | _ -> (self#expression body, acc))
    | _, _ -> (self#expression body, acc)
  in
  let first_arg = self#pattern pat in
  if not (Ast_pat.is_single_variable_pattern_conservative first_arg) then
    Error.err ~loc:first_arg.ppat_loc Mel_this_simple_pattern;
  let result, rev_extra_args = aux [ (label, first_arg) ] body in
  let body =
    List.fold_left
      ~f:(fun e (label, p) -> Ast_helper.Exp.fun_ ~loc label None p e)
      ~init:result rev_extra_args
  in
  let arity = List.length rev_extra_args in
  let arity_s = string_of_int arity in
  Pexp_apply
    ( Exp.ident ~loc { loc; txt = Ast_literal.unsafe_to_method },
      [
        ( Nolabel,
          Exp.constraint_ ~loc
            (Exp.record ~loc
               [ ({ loc; txt = Ast_literal.hidden_field arity_s }, body) ]
               None)
            (Typ.constr ~loc
               {
                 loc;
                 txt = Ldot (Ast_literal.js_meth_callback, "arity" ^ arity_s);
               }
               [ Typ.any ~loc () ]) );
      ] )

let to_uncurry_fn loc (self : Ast_traverse.map) (label : Asttypes.arg_label) pat
    body : expression_desc =
  Error.optional_err ~loc label;
  let rec aux acc (body : expression) =
    match Ast_attributes.process_attributes_rev body.pexp_attributes with
    | Nothing, _ -> (
        match body.pexp_desc with
        | Pexp_fun (arg_label, _, arg, body) ->
            Error.optional_err ~loc arg_label;
            aux ((arg_label, self#pattern arg) :: acc) body
        | _ -> (self#expression body, acc))
    | _, _ -> (self#expression body, acc)
  in
  let first_arg = self#pattern pat in

  let result, rev_extra_args = aux [ (label, first_arg) ] body in
  let body =
    List.fold_left
      ~f:(fun e (label, p) -> Ast_helper.Exp.fun_ ~loc label None p e)
      ~init:result rev_extra_args
  in
  let len = List.length rev_extra_args in
  let arity =
    match rev_extra_args with
    | [ (_, p) ] -> Ast_pat.is_unit_cont ~yes:0 ~no:len p
    | _ -> len
  in
  Error.err_large_arity ~loc arity;
  let arity_s = string_of_int arity in
  Pexp_record
    ([ ({ txt = Ldot (Ast_literal.js_fn, "I" ^ arity_s); loc }, body) ], None)
