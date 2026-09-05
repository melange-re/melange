(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
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

type _ kind = Ml : Parsetree.structure kind | Mli : Parsetree.signature kind

let magic_of_kind : type a. a kind -> string = function
  | Ml -> Config.ast_impl_magic_number
  | Mli -> Config.ast_intf_magic_number

let to_strings (type a) (kind : a kind) ~input_name (ast : a) =
  [
    magic_of_kind kind;
    Marshal.to_string (input_name : string) [];
    Marshal.to_string ast [];
  ]

let output kind channel ~input_name ast =
  List.iter ~f:(output_string channel) (to_strings kind ~input_name ast)
