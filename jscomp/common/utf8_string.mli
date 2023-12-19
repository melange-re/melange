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

type byte = Single of int | Cont of int | Leading of int * int | Invalid

val classify : char -> byte
val next : string -> remaining:int -> int -> int

(* Check if the string is only == to itself (no unicode or escape tricks) *)
val simple_comparison : string -> bool
val is_unicode_string : string -> bool
val is_unescaped : string -> bool

module Utf8_string : sig
  type error =
    | Invalid_code_point
    | Unterminated_backslash
    | Invalid_hex_escape
    | Invalid_unicode_escape

  type exn += Error of int (* offset *) * error

  module Private : sig
    val transform : string -> string
  end
end

module Interp : sig
  type error =
    | Invalid_code_point
    | Unterminated_backslash
    | Invalid_escape_code of char
    | Invalid_hex_escape
    | Invalid_unicode_escape
    | Unterminated_variable
    | Unmatched_paren
    | Invalid_syntax_of_var of string

  type kind = String | Var of int * int

  (* Note the position is about code point *)
  type pos = {
    lnum : int;
    offset : int;
    byte_bol : int;
        (* Note it actually needs to be in sync with OCaml's lexing semantics *)
  }

  type exn += Error of pos * pos * error

  val transform :
    loc:Location.t ->
    delim:string ->
    Parsetree.expression ->
    string ->
    Parsetree.expression

  module Private : sig
    type segment = { start : pos; finish : pos; kind : kind; content : string }

    val transform_test : string -> segment list
  end
end

val rewrite_structure : Parsetree.structure -> Parsetree.structure
