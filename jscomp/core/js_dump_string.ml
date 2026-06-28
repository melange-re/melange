(* Copyright (C) 2017 Hongbo Zhang, Authors of ReScript
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
module P = Js_pp

(* https://mathiasbynens.be/notes/javascript-escapes *)
let escape_to_buffer =
  let ( +> ) = Buffer.add_string in
  let array_conv =
    [|
      "0";
      "1";
      "2";
      "3";
      "4";
      "5";
      "6";
      "7";
      "8";
      "9";
      "a";
      "b";
      "c";
      "d";
      "e";
      "f";
    |]
  in
  let add_hex f c =
    let c = Char.code c in
    f +> "\\x";
    f +> Array.unsafe_get array_conv (c lsr 4);
    f +> Array.unsafe_get array_conv (c land 0xf)
  in
  let pp_raw_string f (* ?(utf=false)*) s =
    let l = String.length s in
    let raw_start = ref 0 in
    let flush_raw i =
      if i > !raw_start then Buffer.add_substring f s !raw_start (i - !raw_start)
    in
    for i = 0 to l - 1 do
      let c = String.unsafe_get s i in
      match c with
      | '\b' ->
          flush_raw i;
          f +> "\\b";
          raw_start := i + 1
      | '\012' ->
          flush_raw i;
          f +> "\\f";
          raw_start := i + 1
      | '\n' ->
          flush_raw i;
          f +> "\\n";
          raw_start := i + 1
      | '\r' ->
          flush_raw i;
          f +> "\\r";
          raw_start := i + 1
      | '\t' ->
          flush_raw i;
          f +> "\\t";
          raw_start := i + 1
      (* This escape sequence is not supported by IE < 9
               | '\011' -> "\\v"
         IE < 9 treats '\v' as 'v' instead of a vertical tab ('\x0B').
         If cross-browser compatibility is a concern, use \x0B instead of \v.

         Another thing to note is that the \v and \0 escapes are not allowed in JSON strings.
      *)
      | '\000'
        when i = l - 1
             ||
             let next = String.unsafe_get s (i + 1) in
             next < '0' || next > '9' ->
          flush_raw i;
          f +> "\\0";
          raw_start := i + 1
      | '\\' (* when not utf*) ->
          flush_raw i;
          f +> "\\\\";
          raw_start := i + 1
      | '\000' .. '\031' | '\127' ->
          flush_raw i;
          add_hex f c;
          raw_start := i + 1
      | '\128' .. '\255' (* when not utf*) ->
          flush_raw i;
          add_hex f c;
          raw_start := i + 1
      | '\"' ->
          flush_raw i;
          f +> "\\\"";
          raw_start := i + 1 (* quote*)
      | _ -> ()
    done;
    flush_raw l
  in
  fun f (* ?(utf=false)*) s ->
    f +> "\"";
    pp_raw_string f (*~utf*) s;
    f +> "\""

let needs_escape s =
  let rec loop i len =
    if i = len then false
    else
      match String.unsafe_get s i with
      | '\000' .. '\031' | '\127' .. '\255' | '"' | '\\' -> true
      | _ -> loop (i + 1) len
  in
  loop 0 (String.length s)

let quote_without_escape s =
  let len = String.length s in
  let bytes = Bytes.create (len + 2) in
  Bytes.unsafe_set bytes 0 '"';
  Bytes.blit_string ~src:s ~src_pos:0 ~dst:bytes ~dst_pos:1 ~len;
  Bytes.unsafe_set bytes (len + 1) '"';
  Bytes.unsafe_to_string bytes

let escape_to_string s =
  if needs_escape s then (
    let buf = Buffer.create (String.length s * 2) in
    escape_to_buffer buf s;
    Buffer.contents buf)
  else quote_without_escape s

let pp_string f s =
  if needs_escape s then (
    let buf = Buffer.create (String.length s * 2) in
    escape_to_buffer buf s;
    P.string f (Buffer.contents buf))
  else (
    P.string_no_newline f "\"";
    P.string_no_newline f s;
    P.string_no_newline f "\"")

(* let _best_string_quote s =
   let simple = ref 0 in
   let double = ref 0 in
   for i = 0 to String.length s - 1 do
     match s.[i] with
     | '\'' -> incr simple
     | '"' -> incr double
     | _ -> ()
   done;
   if !simple < !double
   then '\''
   else '"' *)
