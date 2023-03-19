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

type mapper = Ast_mapper.mapper

let default_mapper = Ast_mapper.default_mapper

let expr_mapper (self : mapper) (expr : Parsetree.expression) =
  match expr.pexp_desc with
  | Pexp_apply ({ pexp_desc = Pexp_send (obj, { txt = name; loc }); _ }, args)
    ->
      {
        expr with
        pexp_desc =
          Melange_ppx.Ast_uncurry_apply.property_apply loc self obj name args;
      }
  | Pexp_send
      ( ({ pexp_desc = Pexp_apply _ | Pexp_ident _; pexp_loc; _ } as subexpr),
        arg ) ->
      (* ReScript removed the OCaml object system and abuses `Pexp_send` for
         `obj##property`. Here, we make that conversion. *)
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

let structure ast = mapper.structure mapper ast
let signature ast = mapper.signature mapper ast
