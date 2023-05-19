(* Copyright (C) 2022- Authors of Melange
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

(*
 * This PPX runs during the compilation of ReScript files. It's meant to
 * contain a translation layer, where possible, from ReScript features to
 * Melange features. Currently, we perform the following transforms:
 *
 *  - `obj["prop"]` -> `obj##prop`
 *)

open Melange_compiler_libs

type mapper = Ast_mapper.mapper

let default_mapper = Ast_mapper.default_mapper

module Uncurry = struct
  open Ast_helper

  type exp = Parsetree.expression

  let js_property loc obj (name : string) =
    Parsetree.Pexp_send
      ( Ast_compatible.app1 ~loc
          (Exp.ident ~loc
             {
               loc;
               txt = Ldot (Ast_literal.Lid.js_oo, Literals.unsafe_downgrade);
             })
          obj,
        { loc; txt = name } )

  let ignored_extra_argument : Parsetree.attribute =
    {
      attr_name = { txt = "ocaml.warning"; loc = Location.none };
      attr_payload =
        PStr
          [
            Str.eval
              (Exp.constant
                 (Pconst_string ("-ignored-extra-argument", Location.none, None)));
          ];
      attr_loc = Location.none;
    }

  let opaque_full_apply ~loc (e : exp) : Parsetree.expression_desc =
    Pexp_constraint
      ( Exp.apply ~loc
          ~attrs:
            [
              (* Ignore warning 20 (`ignored-extra-argument`) on expressions such
               * as:
               *
               *   external x : < .. > Js.t = ""
               *   let () = x##fn "hello"
               *
               * OCaml thinks the extra argument is unused because we're
               * producing * an uncurried call to a JS function whose arity isn't
               * known at compile time. *)
              ignored_extra_argument;
            ]
          (Exp.ident { txt = Ast_literal.Lid.js_internal_full_apply; loc })
          [ (Nolabel, e) ],
        Typ.any ~loc () )

  let generic_apply loc (self : mapper) (obj : Parsetree.expression)
      (args : Ast_compatible.args) (cb : loc -> exp -> exp) =
    let obj = self.expr self obj in
    let args =
      Ext_list.map args (fun (lbl, e) ->
          Bs_syntaxerr.optional_err loc lbl;
          (lbl, self.expr self e))
    in
    let fn = cb loc obj in
    let args =
      match args with
      | [
       (Nolabel, { pexp_desc = Pexp_construct ({ txt = Lident "()" }, None) });
      ] ->
          []
      | _ -> args
    in
    let arity = List.length args in
    if arity = 0 then
      Parsetree.Pexp_apply
        ( Exp.ident { txt = Ldot (Ast_literal.Lid.js_internal, "run"); loc },
          [ (Nolabel, fn) ] )
    else
      let arity_s = string_of_int arity in
      opaque_full_apply ~loc
        (Exp.apply ~loc
           (Exp.apply ~loc
              (Exp.ident ~loc { txt = Ast_literal.Lid.opaque; loc })
              [
                ( Nolabel,
                  Exp.field ~loc
                    (Exp.constraint_ ~loc fn
                       (Typ.constr ~loc
                          {
                            txt = Ldot (Ast_literal.Lid.js_fn, "arity" ^ arity_s);
                            loc;
                          }
                          [ Typ.any ~loc () ]))
                    { txt = Ast_literal.Lid.hidden_field arity_s; loc } );
              ])
           args)

  let property_apply loc self obj name args =
    generic_apply loc self obj args (fun loc obj ->
        Exp.mk ~loc (js_property loc obj name))
end

let expr_mapper (self : mapper) (expr : Parsetree.expression) =
  match expr.pexp_desc with
  | Pexp_apply ({ pexp_desc = Pexp_send (obj, { txt = name; loc }); _ }, args)
    ->
      { expr with pexp_desc = Uncurry.property_apply loc self obj name args }
  | Pexp_send
      ( ({ pexp_desc = Pexp_apply _ | Pexp_ident _ | Pexp_send _; pexp_loc; _ }
        as subexpr),
        arg ) ->
      (* ReScript removed the OCaml object system and abuses `Pexp_send` for
         `obj##property`. Here, we make that conversion. *)
      let subexpr = self.expr self subexpr in
      {
        expr with
        pexp_desc =
          Pexp_apply
            ( {
                subexpr with
                pexp_desc = Pexp_ident { txt = Lident "##"; loc = pexp_loc };
              },
              [
                (Nolabel, subexpr);
                ( Nolabel,
                  {
                    subexpr with
                    pexp_desc = Pexp_ident { arg with txt = Lident arg.txt };
                  } );
              ] );
      }
  | Pexp_let
      ( Nonrecursive,
        [
          {
            pvb_pat =
              ( { ppat_desc = Ppat_record _; _ }
              | {
                  ppat_desc = Ppat_alias ({ ppat_desc = Ppat_record _; _ }, _);
                  _;
                } ) as p;
            pvb_expr;
            pvb_attributes;
            _;
          };
        ],
        body ) -> (
      match pvb_expr.pexp_desc with
      | Pexp_pack _ -> default_mapper.expr self expr
      | _ ->
          default_mapper.expr self
            {
              expr with
              pexp_desc =
                Pexp_match
                  (pvb_expr, [ { pc_lhs = p; pc_guard = None; pc_rhs = body } ]);
              pexp_attributes = expr.pexp_attributes @ pvb_attributes;
            }
          (* let [@warning "a"] {a;b} = c in body
             The attribute is attached to value binding,
             after the transformation value binding does not exist so we attach
             the attribute to the whole expression, in general, when shuffuling the ast
             it is very hard to place attributes correctly
          *))
  | _ -> default_mapper.expr self expr

let mapper : Ast_mapper.mapper =
  let open Ast_mapper in
  { default_mapper with expr = expr_mapper }

let structure (ast : Import.Ast_406.Parsetree.structure) :
    Import.Ast_406.Parsetree.structure =
  let ast =
    Import.To_ppxlib.copy_structure ast
    |> Melange_ppxlib_ast.Of_ppxlib.copy_structure
  in
  mapper.structure mapper ast
  |> Melange_ppxlib_ast.To_ppxlib.copy_structure
  |> Import.Of_ppxlib.copy_structure

let signature (ast : Import.Ast_406.Parsetree.signature) :
    Import.Ast_406.Parsetree.signature =
  let ast =
    Import.To_ppxlib.copy_signature ast
    |> Melange_ppxlib_ast.Of_ppxlib.copy_signature
  in
  mapper.signature mapper ast
  |> Melange_ppxlib_ast.To_ppxlib.copy_signature
  |> Import.Of_ppxlib.copy_signature
