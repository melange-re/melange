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
  let { Flow_ast_utils.prog; error } =
    Flow_ast_utils.parse_expression ~loc ~check_errors str
  in
  match (check_errors, error) with
  | Check _, Some _ -> Js_raw_info.Js_exp_unknown
  | Check _, None | Dont_check, None -> classify_exp prog
  | Dont_check, Some _ -> Js_exp_unknown

let statement_bindings statements =
  let collector =
    object (self)
      inherit [Js_parser.Loc.t] Js_parser.Flow_ast_mapper.mapper as super
      val mutable bindings = String.Set.empty
      val mutable block_depth = 0
      method bindings = bindings

      method private bind (_, { Flow_ast.Identifier.name; _ }) =
        bindings <- String.Set.add name bindings

      method! expression expression = expression

      method! statement ((_, statement) as node) =
        match statement with
        | Flow_ast.Statement.Block _ | For _ | ForIn _ | ForOf _ | Switch _
        | Try _ ->
            block_depth <- block_depth + 1;
            let node = super#statement node in
            block_depth <- block_depth - 1;
            node
        | _ -> super#statement node

      method! function_declaration _loc function_ =
        let { Flow_ast.Function.id; _ } = function_ in
        if block_depth = 0 then Option.iter ~f:self#bind id;
        function_

      method! class_declaration _loc class_ =
        let { Flow_ast.Class.id; _ } = class_ in
        if block_depth = 0 then Option.iter ~f:self#bind id;
        class_

      method! pattern_identifier ?kind identifier =
        (match kind with
        | Some Flow_ast.Variable.Var -> self#bind identifier
        | Some (Let | Const) when block_depth = 0 -> self#bind identifier
        | Some (Let | Const) | None -> ());
        identifier

      method! pattern_object_property_identifier_key ?kind:_ key = key
    end
  in
  (* Only [var] escapes blocks; no declarations escape functions or classes. *)
  ignore (collector#toplevel_statement_list statements);
  collector#bindings

let classify_stmt ~loc (prog : string) =
  let { Flow_ast_utils.prog; error = _ } =
    Flow_ast_utils.parse_program ~loc ~check_errors:Dont_check prog
  in
  match prog with
  | { statements = []; _ } -> (Js_raw_info.Js_stmt_comment, String.Set.empty)
  | { statements; _ } -> (Js_stmt_unknown, statement_bindings statements)
(* we can also analyze throw
   x.x pure access *)
