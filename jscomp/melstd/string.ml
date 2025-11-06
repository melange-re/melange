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

module T = struct
  let hash = Hashtbl.hash

  include StdLabels.String
end

include T
module Map = MoreLabels.Map.Make (T)
module Set = MoreLabels.Set.Make (T)
module Hashtbl = Hashtbl.Make (T)

(* {[ split " test_unsafe_obj_ffi_ppx.cmi" ~keep_empty:false ' ']} *)
let split_by ?(keep_empty = false) ~f:is_delim str =
  let len = length str in
  let rec loop acc last_pos pos =
    if pos = -1 then
      if last_pos = 0 && not keep_empty then acc
      else sub str ~pos:0 ~len:last_pos :: acc
    else if is_delim (get str pos) then
      let new_len = last_pos - pos - 1 in
      if new_len <> 0 || keep_empty then
        let v = sub str ~pos:(pos + 1) ~len:new_len in
        loop (v :: acc) pos (pos - 1)
      else loop acc pos (pos - 1)
    else loop acc last_pos (pos - 1)
  in
  loop [] len (len - 1)

let split ?keep_empty str ~sep:on =
  match str with "" -> [] | str -> split_by ?keep_empty ~f:(Char.equal on) str

let for_all_from =
  (* it is unsafe to expose such API as unsafe since
     user can provide bad input range *)
  let rec unsafe_for_all_range s ~start ~finish p =
    start > finish
    || p (unsafe_get s start)
       && unsafe_for_all_range s ~start:(start + 1) ~finish p
  in
  fun s ~from:start ~f:p ->
    let len = length s in
    if start < 0 then invalid_arg "String.for_all_from"
    else unsafe_for_all_range s ~start ~finish:(len - 1) p

let unsafe_is_sub ~sub i s j ~len =
  let rec check k =
    if k = len then true
    else unsafe_get sub (i + k) = unsafe_get s (j + k) && check (k + 1)
  in
  j + len <= length s && check 0

let rfind =
  let exception Local_exit in
  fun ~sub s ->
    let n = length sub in
    let i = ref (length s - n) in
    try
      while !i >= 0 do
        if unsafe_is_sub ~sub 0 s !i ~len:n then raise_notrace Local_exit;
        decr i
      done;
      -1
    with Local_exit -> !i

let tail_from s ~from:x =
  let len = length s in
  if x > len then invalid_arg ("String.tail_from " ^ s ^ " : " ^ string_of_int x)
  else sub s ~pos:x ~len:(len - x)

let rindex_neg =
  let rec rindex_rec s i c =
    if i < 0 then i
    else if unsafe_get s i = c then i
    else rindex_rec s (i - 1) c
  in
  fun s c -> rindex_rec s (length s - 1) c
