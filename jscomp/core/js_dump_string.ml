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

(** Avoid to allocate single char string too many times*)
let array_str1 = Array.init 256 ~f:(fun i -> String.make 1 (Char.chr i))

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

(* https://mathiasbynens.be/notes/javascript-escapes *)
let ( +> ) = Buffer.add_string

let escape_to_buffer f (* ?(utf=false)*) s =
  let pp_raw_string f (* ?(utf=false)*) s =
    let l = String.length s in
    for i = 0 to l - 1 do
      let c = String.unsafe_get s i in
      match c with
      | '\b' -> f +> "\\b"
      | '\012' -> f +> "\\f"
      | '\n' -> f +> "\\n"
      | '\r' -> f +> "\\r"
      | '\t' -> f +> "\\t"
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
          f +> "\\0"
      | '\\' (* when not utf*) -> f +> "\\\\"
      | '\000' .. '\031' | '\127' ->
          let c = Char.code c in
          f +> "\\x";
          f +> Array.unsafe_get array_conv (c lsr 4);
          f +> Array.unsafe_get array_conv (c land 0xf)
      | '\128' .. '\255' (* when not utf*) ->
          let c = Char.code c in
          f +> "\\x";
          f +> Array.unsafe_get array_conv (c lsr 4);
          f +> Array.unsafe_get array_conv (c land 0xf)
      | '\"' -> f +> "\\\"" (* quote*)
      | _ -> f +> Array.unsafe_get array_str1 (Char.code c)
    done
  in
  f +> "\"";
  pp_raw_string f (*~utf*) s;
  f +> "\""

let escape_to_string s =
  let buf = Buffer.create (String.length s * 2) in
  escape_to_buffer buf s;
  Buffer.contents buf

let pp_string f s = P.string f (escape_to_string s)
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
