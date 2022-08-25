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

type mapper = Bs_ast_mapper.mapper

let default_mapper = Bs_ast_mapper.default_mapper

let expr_mapper (self : mapper) (expr : Parsetree.expression) =
  match expr.pexp_desc with
  | Pexp_send
      ( ({ pexp_desc = Pexp_apply _ | Pexp_ident _; _ } as expr),
        { txt = name; loc } ) ->
      (* ReScript removed the OCaml object system and abuses `Pexp_send` for
         `obj##property`. Here, we make that conversion. *)
      { expr with pexp_desc = Ast_util.js_property loc expr name }
  | _ -> default_mapper.expr self expr

let mapper : mapper = { default_mapper with expr = expr_mapper }
let structure ast = mapper.structure mapper ast
let signature ast = mapper.signature mapper ast
