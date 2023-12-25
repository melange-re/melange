(* Copyright (C) 2023 Antonio Nuno Monteiro
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
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, US. *)

open Import
module Compiler_version = Ppxlib_ast.Compiler_version

module type OCaml_version = Ppxlib_ast.OCaml_version

module Intf_or_impl : sig
  type t = Intf of Parsetree.signature | Impl of Parsetree.structure
end

type input_version = (module OCaml_version)

val fall_back_input_version : (module OCaml_version)

type t = {
  input_name : string;
  input_version : input_version;
  ast : Intf_or_impl.t;
}

type read_error =
  | Not_a_binary_ast
  | Unknown_version of string * input_version
  | Source_parse_error of Ppxlib_ast.Location_error.t * input_version
  | System_error of Ppxlib_ast.Location_error.t * input_version

type input_source = Stdin | File of string
(* | Channel of in_channel *)

type input_kind =
  | Possibly_source of {
      filename : string;
      parse_fun : Lexing.lexbuf -> Intf_or_impl.t;
    }
  | Necessarily_binary

val read : input_source -> input_kind:input_kind -> (t, read_error) result
val read_exn : input_source -> input_kind:input_kind -> t
