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

let js_property loc obj (name : string) =
  let helper_loc = Ast_location.ghost loc in
  Pexp_send
    ( Exp.apply ~loc:helper_loc
        (Exp.ident ~loc:helper_loc
           { txt = Ast_literal.unsafe_downgrade; loc = helper_loc })
        [ (Nolabel, obj) ],
      { loc = helper_loc; txt = name } )

let generic_apply =
  (* we use the trick
     [( opaque e : _) ] to avoid it being inspected, the type constraint is
     avoid some syntactic transformation, e.g ` e |. (f g [@bs])` `opaque` is
     to avoid it being inspected in the type level *)
  let opaque_full_apply ~loc e =
    let helper_loc = Ast_location.ghost loc in
    Pexp_constraint
      ( Exp.apply ~loc
          (Exp.ident ~loc:helper_loc
             { txt = Ast_literal.js_internal_full_apply; loc = helper_loc })
          [ (Nolabel, e) ],
        Typ.any ~loc () )
  in
  fun ~loc
    ~kind
    (self : Ast_traverse.map)
    obj
    args
    ~(f : loc:loc -> expression -> expression)
  ->
    let fn =
      let obj = self#expression obj in
      f ~loc obj
    in
    let args =
      List.map
        ~f:(fun (lbl, e) ->
          Error.optional_err ~loc:e.pexp_loc lbl;
          (lbl, self#expression e))
        args
    in
    let unit_arg =
      match args with
      | [
       ( Nolabel,
         { pexp_desc = Pexp_construct ({ txt = Lident "()"; _ }, None); _ } );
      ] ->
          true
      | _ -> false
    in
    let args = if kind = `oo && unit_arg then [] else args in
    match args with
    | [] ->
        let helper_loc = Ast_location.ghost loc in
        Pexp_apply
          ( Exp.ident ~loc:helper_loc
              {
                txt =
                  (match kind with
                  | `oo -> Ldot (Ldot (Ast_literal.js_oo, "Internal"), "run")
                  | `generic -> Ldot (Ast_literal.js_internal, "run"));
                loc = helper_loc;
              },
            [ (Nolabel, fn) ] )
    | args ->
        let generated_loc = Ast_location.ghost loc in
        let arity = List.length args in
        let fn =
          if kind = `generic && unit_arg then
            (* The receiver's type selects arity0 or arity1. An unknown
               receiver defaults to the last [Js.Fn.Call] declaration. *)
            fn
          else
            Exp.constraint_ ~loc:generated_loc fn
              (Typ.constr ~loc:generated_loc
                 {
                   txt =
                     Ast_literal.arity_type
                       (match kind with
                       | `oo -> Ast_literal.Meth
                       | `generic -> Ast_literal.Fn)
                       ~arity;
                   loc = generated_loc;
                 }
                 [ Typ.any ~loc:generated_loc () ])
        in
        let shared_call = kind = `generic && arity = 1 in
        let apply fn =
          (* Keep warning 20 enabled in user callee and argument expressions. *)
          opaque_full_apply ~loc:generated_loc
            (Exp.apply ~loc:generated_loc
               (Exp.apply ~loc:generated_loc
                  ~attrs:[ Ast_attributes.internal_uncurried ]
                  (Exp.ident ~loc:generated_loc
                     { txt = Ast_literal.opaque; loc = generated_loc })
                  [
                    ( Nolabel,
                      Exp.field ~loc:generated_loc
                        ~attrs:
                          (if shared_call then
                             [ Ast_attributes.internal_field_disambiguation ]
                           else [])
                        fn
                        {
                          txt =
                            (match kind with
                            | `oo -> Ast_literal.hidden_field ~arity
                            | `generic -> Ast_literal.fn_hidden_field ~arity);
                          loc = generated_loc;
                        } );
                  ])
               args)
        in
        if shared_call then
          (* Hide ambiguity warnings only on the generated field access.
             Evaluate user code outside that warning scope, exactly once. *)
          let name = "melange$fn" in
          Pexp_let
            ( Nonrecursive,
              [
                Vb.mk ~loc:generated_loc
                  (Pat.var ~loc:generated_loc
                     { txt = name; loc = generated_loc })
                  fn;
              ],
              Exp.mk ~loc:generated_loc
                (apply
                   (Exp.ident ~loc:generated_loc
                      { txt = Lident name; loc = generated_loc })) )
        else apply fn

let method_apply ~loc (self : Ast_traverse.map) obj name args =
  let f ~loc obj =
    Exp.mk ~loc:(Ast_location.ghost loc) (js_property loc obj name)
  in
  generic_apply ~loc ~kind:`oo self obj args ~f

let generic_apply ~loc (self : Ast_traverse.map) obj args
    ~(f : loc:loc -> expression -> expression) =
  generic_apply ~loc ~kind:`generic self obj args ~f

let uncurry_fn_apply ~loc self fn args =
  generic_apply ~loc self fn args ~f:(fun ~loc:_ obj -> obj)

let property_apply ~loc self obj name args =
  generic_apply ~loc self obj args ~f:(fun ~loc obj ->
      Exp.mk ~loc:(Ast_location.ghost loc) (js_property loc obj name))
