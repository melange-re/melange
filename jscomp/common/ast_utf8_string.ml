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

let rec check_no_escapes_or_unicode (s : string) (byte_offset : int)
    (s_len : int) =
  if byte_offset = s_len then true
  else
    let current_char = s.[byte_offset] in
    match Ext_utf8.classify current_char with
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
