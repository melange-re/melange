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

include Stdlib.Filename

let is_dir_sep =
  let is_dir_sep_unix c = c = '/' in
  let is_dir_sep_win_cygwin c = c = '/' || c = '\\' || c = ':' in
  if Sys.unix then is_dir_sep_unix else is_dir_sep_win_cygwin

let get_extension_maybe name =
  let name_len = String.length name in
  let rec search_dot name i name_len =
    if i < 0 || is_dir_sep (String.unsafe_get name i) then ""
    else if String.unsafe_get name i = '.' then
      String.sub name ~pos:i ~len:(name_len - i)
    else search_dot name (i - 1) name_len
  in
  search_dot name (name_len - 1) name_len

let get_all_extensions_maybe name =
  let rec search_dot name i current name_len =
    if i < 0 || is_dir_sep (String.unsafe_get name i) then current
    else if String.unsafe_get name i = '.' then
      search_dot name (i - 1) i name_len
    else search_dot name (i - 1) current name_len
  in
  let name_len = String.length name in
  let first_dot = search_dot name (name_len - 1) (name_len - 1) name_len in
  if first_dot = name_len - 1 then None
  else Some (String.sub name ~pos:first_dot ~len:(name_len - first_dot))

let chop_all_extensions_maybe name =
  let rec search_dot i last =
    if i < 0 || is_dir_sep (String.unsafe_get name i) then
      match last with None -> name | Some i -> String.sub name ~pos:0 ~len:i
    else if String.unsafe_get name i = '.' then search_dot (i - 1) (Some i)
    else search_dot (i - 1) last
  in
  search_dot (String.length name - 1) None

let new_extension name ~ext =
  let rec search_dot name i ext =
    if i < 0 || is_dir_sep (String.unsafe_get name i) then name ^ ext
    else if String.unsafe_get name i = '.' then (
      let ext_len = String.length ext in
      let buf = Bytes.create (i + ext_len) in
      Bytes.blit_string ~src:name ~src_pos:0 ~dst:buf ~dst_pos:0 ~len:i;
      Bytes.blit_string ~src:ext ~src_pos:0 ~dst:buf ~dst_pos:i ~len:ext_len;
      Bytes.unsafe_to_string buf)
    else search_dot name (i - 1) ext
  in
  search_dot name (String.length name - 1) ext
