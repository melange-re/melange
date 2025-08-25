(* Copyright (C) 2025- Authors of Melange
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
module S = Js_stmt_make

let wrap_module_value =
  let import_of_module module_ =
    E.call
      ~info:{ arity = Full; call_info = Call_na }
      (E.js_global "import")
      [ E.module_ module_ ]
  in
  let wrap_then import value =
    let arg = Ident.create "m" in
    E.call
      ~info:{ arity = Full; call_info = Call_na }
      (E.dot import "then")
      [
        E.ocaml_fun ~return_unit:false [ arg ]
          [
            {
              statement_desc = J.Return (E.dot (E.var arg) value);
              comment = None;
            };
          ];
      ]
  in
  fun module_id module_value ->
    let module_ = { module_id with J.dynamic_import = true } in
    let import = import_of_module module_ in
    match module_value with
    | Some value -> wrap_then import value
    | None -> import
