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

(** [classify chr] returns the {!byte} corresponding to [chr] *)
let classify chr =
  let c = int_of_char chr in
  (* Classify byte according to leftmost 0 bit *)
  if c land 0b1000_0000 = 0 then Single c
  else if
    (* c 0b0____*)
    c land 0b0100_0000 = 0
  then Cont (c land 0b0011_1111)
  else if
    (* c 0b10___*)
    c land 0b0010_0000 = 0
  then Leading (1, c land 0b0001_1111)
  else if
    (* c 0b110__*)
    c land 0b0001_0000 = 0
  then Leading (2, c land 0b0000_1111)
  else if
    (* c 0b1110_ *)
    c land 0b0000_1000 = 0
  then Leading (3, c land 0b0000_0111)
  else if
    (* c 0b1111_0___*)
    c land 0b0000_0100 = 0
  then Leading (4, c land 0b0000_0011)
  else if
    (* c 0b1111_10__*)
    c land 0b0000_0010 = 0
  then Leading (5, c land 0b0000_0001) (* c 0b1111_110__ *)
  else Invalid

let rec next s ~remaining offset =
  if remaining = 0 then offset
  else
    match classify s.[offset + 1] with
    | Cont _cc -> next s ~remaining:(remaining - 1) (offset + 1)
    | _ -> -1
    | exception _ ->
        (* it can happen when out of bound *)
        -1

let rec check_no_escapes_or_unicode s byte_offset s_len =
  if byte_offset = s_len then true
  else
    let current_char = s.[byte_offset] in
    match classify current_char with
    | Single 92 (* '\\' *) -> false
    | Single _ -> check_no_escapes_or_unicode s (byte_offset + 1) s_len
    | Invalid | Cont _ | Leading _ -> false

let simple_comparison s = check_no_escapes_or_unicode s 0 (String.length s)

(* Supported delimiters *)
let escaped_j_delimiter = "*j" (* not user level syntax allowed *)
let unescaped_j_delimiter = "j"
let unescaped_js_delimiter = "js"
let is_unicode_string opt = String.equal opt escaped_j_delimiter

let is_unescaped s =
  String.equal s unescaped_j_delimiter || String.equal s unescaped_js_delimiter

let valid_hex x =
  match x with '0' .. '9' | 'a' .. 'f' | 'A' .. 'F' -> true | _ -> false

type error =
  | Invalid_code_point
  | Unterminated_backslash
  | Invalid_hex_escape
  | Invalid_unicode_escape

let pp_error fmt err =
  let msg =
    match err with
    | Invalid_code_point -> "Invalid code point"
    | Unterminated_backslash -> "\\ ended unexpectedly"
    | Invalid_hex_escape -> "Invalid \\x escape"
    | Invalid_unicode_escape -> "Invalid \\u escape"
  in
  Format.pp_print_string fmt msg

type exn += Error of int (* offset *) * error

let error ~loc error = raise (Error (loc, error))

(* Note the [loc] really should be the utf8-offset, it has nothing to do with our
    escaping mechanism *)
(* we can not just print new line in ES5
   seems we don't need
   escape "\b" "\f"
   we need escape "\n" "\r" since
   ocaml multiple-line allows [\n]
   visual input while es5 string
   does not*)

let rec check_and_transform loc buf s byte_offset s_len =
  if byte_offset = s_len then ()
  else
    let current_char = s.[byte_offset] in
    match classify current_char with
    | Single 92 (* '\\' *) ->
        escape_code (loc + 1) buf s (byte_offset + 1) s_len
    | Single 34 ->
        Buffer.add_string buf "\\\"";
        check_and_transform (loc + 1) buf s (byte_offset + 1) s_len
    | Single 10 ->
        Buffer.add_string buf "\\n";
        check_and_transform (loc + 1) buf s (byte_offset + 1) s_len
    | Single 13 ->
        Buffer.add_string buf "\\r";
        check_and_transform (loc + 1) buf s (byte_offset + 1) s_len
    | Single _ ->
        Buffer.add_char buf current_char;
        check_and_transform (loc + 1) buf s (byte_offset + 1) s_len
    | Invalid | Cont _ -> error ~loc Invalid_code_point
    | Leading (n, _) ->
        let i' = next s ~remaining:n byte_offset in
        if i' < 0 then error ~loc Invalid_code_point
        else (
          for k = byte_offset to i' do
            Buffer.add_char buf s.[k]
          done;
          check_and_transform (loc + 1) buf s (i' + 1) s_len)

(* we share the same escape sequence with js *)
and escape_code loc buf s offset s_len =
  if offset >= s_len then error ~loc Unterminated_backslash
  else Buffer.add_char buf '\\';
  let cur_char = s.[offset] in
  match cur_char with
  | '\\' | 'b' | 't' | 'n' | 'v' | 'f' | 'r' | '0' | '$' ->
      Buffer.add_char buf cur_char;
      check_and_transform (loc + 1) buf s (offset + 1) s_len
  | 'u' ->
      Buffer.add_char buf cur_char;
      unicode (loc + 1) buf s (offset + 1) s_len
  | 'x' ->
      Buffer.add_char buf cur_char;
      two_hex (loc + 1) buf s (offset + 1) s_len
  | _ ->
      (* Regular characters, like `a` in `\a`,
       * are valid escape sequences *)
      Buffer.add_char buf cur_char;
      check_and_transform (loc + 1) buf s (offset + 1) s_len

and two_hex loc buf s offset s_len =
  if offset + 1 >= s_len then error ~loc Invalid_hex_escape;
  let a, b = (s.[offset], s.[offset + 1]) in
  if valid_hex a && valid_hex b then (
    Buffer.add_char buf a;
    Buffer.add_char buf b;
    check_and_transform (loc + 2) buf s (offset + 2) s_len)
  else error ~loc Invalid_hex_escape

and unicode loc buf s offset s_len =
  if offset + 3 >= s_len then error ~loc Invalid_unicode_escape;
  let a0, a1, a2, a3 =
    (s.[offset], s.[offset + 1], s.[offset + 2], s.[offset + 3])
  in
  if valid_hex a0 && valid_hex a1 && valid_hex a2 && valid_hex a3 then (
    Buffer.add_char buf a0;
    Buffer.add_char buf a1;
    Buffer.add_char buf a2;
    Buffer.add_char buf a3;
    check_and_transform (loc + 4) buf s (offset + 4) s_len)
  else error ~loc Invalid_unicode_escape

(* http://www.2ality.com/2015/01/es6-strings.html
   console.log('\uD83D\uDE80'); (* ES6*)
   console.log('\u{1F680}');
*)
let transform s =
  let s_len = String.length s in
  let buf = Buffer.create (s_len * 2) in
  check_and_transform 0 buf s 0 s_len;
  Buffer.contents buf

module Private = struct
  let transform = transform
end

let transform ~loc s =
  try transform s
  with Error (offset, error) ->
    Location.raise_errorf ~loc "Offset: %d, %a" offset pp_error error

(* TODO: Allow identifers x.A.y *)

let escaped_j_delimiter =
  (* syntax not allowed at the user level *)
  Some escaped_j_delimiter

let transform =
  let transform (e : Parsetree.expression) s ~loc ~delim =
    match String.equal delim unescaped_js_delimiter with
    | true ->
        {
          e with
          pexp_desc =
            Pexp_constant
              (Pconst_string (transform ~loc s, loc, escaped_j_delimiter));
        }
    | false -> (
        match String.equal delim unescaped_j_delimiter with
        | true ->
            Location.prerr_warning e.pexp_loc
              (Mel_uninterpreted_delimiters unescaped_j_delimiter);
            {
              e with
              pexp_desc =
                Pexp_constant
                  (Pconst_string (transform ~loc s, loc, escaped_j_delimiter));
            }
        | false -> e)
  in
  fun ~loc ~delim expr s -> transform expr s ~loc ~delim

let rewrite_structure =
  let mapper =
    let super = Ast_mapper.default_mapper in
    {
      super with
      expr =
        (fun self e ->
          match e.pexp_desc with
          | Pexp_constant (Pconst_string (s, loc, Some delim)) ->
              transform e s ~loc ~delim
          | _ -> super.expr self e);
    }
  in
  fun stru -> mapper.structure mapper stru
