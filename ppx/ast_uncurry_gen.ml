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

let process_args ~loc self args ~init =
  List.fold_left ~init args ~f:(fun acc param ->
      match param with
      | { pparam_desc = Pparam_newtype _; _ } -> acc
      | { pparam_desc = Pparam_val (arg_label, _, arg); _ } ->
          Error.optional_err ~loc arg_label;
          (arg_label, self#pattern arg) :: acc)

let rec aux ~loc self acc (body : expression) =
  match Ast_attributes.process_attributes_rev body.pexp_attributes with
  | Nothing, _ -> (
      match body.pexp_desc with
      | Pexp_function (args, _, Pfunction_body body) ->
          aux ~loc self (process_args ~loc self args ~init:acc) body
      | _ -> (self#expression body, acc))
  | _, _ -> (self#expression body, acc)

(* Handling `fun [@this]` used in `object [@u] end` *)
let to_method_callback =
  let first_arg args =
    match
      List.find
        ~f:(function
          | { pparam_desc = Pparam_val _; _ } -> true
          | { pparam_desc = Pparam_newtype _; _ } -> false)
        args
    with
    | { pparam_desc = Pparam_val (_, _, pat); _ } -> pat
    | { pparam_desc = Pparam_newtype _; _ } | (exception Not_found) ->
        assert false
  in
  let rec is_single_variable_pattern_conservative p =
    match p.ppat_desc with
    | Ppat_any | Ppat_var _ -> true
    | Ppat_alias (p, _) | Ppat_constraint (p, _) ->
        is_single_variable_pattern_conservative p
    | _ -> false
  in
  fun ~loc (self : Ast_traverse.map) args body ->
    let first_arg = self#pattern (first_arg args) in
    if not (is_single_variable_pattern_conservative first_arg) then
      Error.err ~loc:first_arg.ppat_loc Mel_this_simple_pattern;
    let body, rev_extra_args =
      let result, rev_extra_args =
        let rev_args = process_args ~loc self args ~init:[] in
        aux ~loc self rev_args body
      in
      let body =
        Ast_builder.Default.pexp_function ~loc
          (List.rev_map
             ~f:(fun (label, p) ->
               { pparam_desc = Pparam_val (label, None, p); pparam_loc = loc })
             rev_extra_args)
          None (Pfunction_body result)
      in
      (body, rev_extra_args)
    in
    let arity_s = string_of_int (List.length rev_extra_args) in
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
                   txt =
                     Ldot
                       ( Ast_literal.js_meth_callback,
                         Format.sprintf "arity%s" arity_s );
                 }
                 [ Typ.any ~loc () ]) );
        ] )

let to_uncurry_fn ~loc (self : Ast_traverse.map) args body : expression_desc =
  let result, rev_extra_args =
    let rev_args = process_args ~loc self args ~init:[] in
    aux ~loc self rev_args body
  in
  let arity =
    match rev_extra_args with
    | [
     (_, { ppat_desc = Ppat_construct ({ txt = Lident "()"; _ }, None); _ });
    ] ->
        0
    | _ -> List.length rev_extra_args
  in
  Error.err_large_arity ~loc arity;
  let body =
    Ast_builder.Default.pexp_function ~loc
      (List.rev_map
         ~f:(fun (label, p) ->
           { pparam_desc = Pparam_val (label, None, p); pparam_loc = loc })
         rev_extra_args)
      None (Pfunction_body result)
  in
  Pexp_record
    ( [
        ( { txt = Ldot (Ast_literal.js_fn, "I" ^ string_of_int arity); loc },
          body );
      ],
      None )
