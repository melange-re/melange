(* Copyright (C) 2019- Hongbo Zhang, Authors of ReScript
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

let check_additional_id =
  let option_id = Some (Ident.create_persistent Js_runtime_modules.option)
  and curry_id = Some (Ident.create_persistent Js_runtime_modules.curry) in
  fun (x : J.expression) : Ident.t option ->
    match x.expression_desc with
    | Optional_block (_, false) -> option_id
    | Call (_, _, { arity = NA; _ }) -> curry_id
    | _ -> None

let check_additional_statement_id =
  let js_exceptions_id =
    Some (Ident.create_persistent Js_runtime_modules.caml_js_exceptions)
  in
  fun (x : J.statement) : Ident.t option ->
    match x.statement_desc with Throw _ -> js_exceptions_id | _ -> None
