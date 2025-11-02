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
module Flow_ast = Js_parser.Flow_ast

let classify_exp =
  let rec is_obj_literal = function
    | Flow_ast.Expression.Identifier (_, { name = "undefined"; _ })
    | StringLiteral _ | BooleanLiteral _ | NullLiteral _ | NumberLiteral _
    | BigIntLiteral _ | RegExpLiteral _ | ModuleRefLiteral _ ->
        true
    | Unary { operator = Minus; argument = _, argument; _ } ->
        is_obj_literal argument
    | Object { properties; _ } -> List.for_all ~f:is_literal_kv properties
    | Array { elements; _ } ->
        List.for_all
          ~f:(function
            | Flow_ast.Expression.Array.Expression (_, x) -> is_obj_literal x
            | _ -> false)
          elements
    | _ -> false
  and is_literal_kv = function
    | Flow_ast.Expression.Object.Property (_, Init { value = _, value; _ }) ->
        is_obj_literal value
    | _ -> false
  in
  function
  | Flow_ast.Expression.Function
      {
        id = _;
        params = _, { params; _ };
        async = false;
        generator = false;
        predicate = None;
        _;
      } ->
      Js_raw_info.Js_function { arity = List.length params; arrow = false }
  | ArrowFunction
      {
        id = None;
        params = _, { params; _ };
        async = false;
        generator = false;
        predicate = None;
        _;
      } ->
      Js_function { arity = List.length params; arrow = true }
  | StringLiteral { comments; _ }
  | BooleanLiteral { comments; _ }
  | NullLiteral comments
  | NumberLiteral { comments; _ }
  | BigIntLiteral { comments; _ }
  | RegExpLiteral { comments; _ }
  | ModuleRefLiteral { comments; _ } ->
      let comment =
        match comments with
        | None -> None
        | Some { leading = [ (_, { kind = Block; text = comment; _ }) ]; _ } ->
            Some ("/*" ^ comment ^ "*/")
        | Some { leading = [ (_, { kind = Line; text = comment; _ }) ]; _ } ->
            Some ("//" ^ comment)
        | Some _ -> None
      in
      Js_literal { comment }
  | Identifier (_, { name = "undefined"; _ }) -> Js_literal { comment = None }
  | prog -> (
      match is_obj_literal prog with
      | true -> Js_literal { comment = None }
      | false -> Js_exp_unknown)

(* It seems we do the parse twice
   - in parsing
   - in code generation *)
let classify ?(check_errors = Flow_ast_utils.Dont_check) ~loc str =
  match Flow_ast_utils.parse_expression ~loc ~check_errors str with
  | Error _ -> Js_raw_info.Js_exp_unknown
  | Ok prog -> classify_exp prog

let classify_stmt ~loc (prog : string) : Js_raw_info.stmt =
  match Flow_ast_utils.parse_program ~loc ~check_errors:Dont_check prog with
  | Ok { statements = []; _ } -> Js_stmt_comment
  | Ok _ | Error _ -> Js_stmt_unknown
(* we can also analyze throw
   x.x pure access *)
