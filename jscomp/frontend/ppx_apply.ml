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

let apply_lazy ~source ~target
    (impl : Parsetree.structure -> Parsetree.structure)
    (iface : Parsetree.signature -> Parsetree.signature) =
  let { Ast_io.ast; _ } =
    Ast_io.read_exn (File source) ~input_kind:Necessarily_binary
  in
  let oc = open_out_bin target in
  match ast with
  | Intf ast ->
      let ast =
        iface ast |> Melange_ppxlib_ast.To_ppxlib.copy_signature
        |> Ppxlib_ast.Selected_ast.To_ocaml.copy_signature
      in
      output_string oc
        Ppxlib_ast.Compiler_version.Ast.Config.ast_intf_magic_number;
      output_value oc !Location.input_name;
      output_value oc ast
  | Impl ast ->
      let ast =
        impl ast |> Melange_ppxlib_ast.To_ppxlib.copy_structure
        |> Ppxlib_ast.Selected_ast.To_ocaml.copy_structure
      in
      output_string oc
        Ppxlib_ast.Compiler_version.Ast.Config.ast_impl_magic_number;
      output_value oc !Location.input_name;
      output_value oc ast;
      close_out oc
