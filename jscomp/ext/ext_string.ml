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

(*
   {[ split " test_unsafe_obj_ffi_ppx.cmi" ~keep_empty:false ' ']}
*)
let split_by ?(keep_empty = false) is_delim str =
  let len = String.length str in
  let rec loop acc last_pos pos =
    if pos = -1 then
      if last_pos = 0 && not keep_empty then acc
      else String.sub str 0 last_pos :: acc
    else if is_delim str.[pos] then
      let new_len = last_pos - pos - 1 in
      if new_len <> 0 || keep_empty then
        let v = String.sub str (pos + 1) new_len in
        loop (v :: acc) pos (pos - 1)
      else loop acc pos (pos - 1)
    else loop acc last_pos (pos - 1)
  in
  loop [] len (len - 1)

let split ?keep_empty str on =
  match str with
  | "" -> []
  | str -> split_by ?keep_empty (fun x -> (x : char) = on) str

let for_all_from =
  (* it is unsafe to expose such API as unsafe since
     user can provide bad input range *)
  let rec unsafe_for_all_range s ~start ~finish p =
    start > finish
    || p (String.unsafe_get s start)
       && unsafe_for_all_range s ~start:(start + 1) ~finish p
  in
  fun s start p ->
    let len = String.length s in
    if start < 0 then invalid_arg "Ext_string.for_all_from"
    else unsafe_for_all_range s ~start ~finish:(len - 1) p

let unsafe_is_sub ~sub i s j ~len =
  let rec check k =
    if k = len then true
    else
      String.unsafe_get sub (i + k) = String.unsafe_get s (j + k)
      && check (k + 1)
  in
  j + len <= String.length s && check 0

let rfind =
  let exception Local_exit in
  fun ~sub s ->
    let n = String.length sub in
    let i = ref (String.length s - n) in
    try
      while !i >= 0 do
        if unsafe_is_sub ~sub 0 s !i ~len:n then raise_notrace Local_exit;
        decr i
      done;
      -1
    with Local_exit -> !i

let tail_from s x =
  let len = String.length s in
  if x > len then
    invalid_arg ("Ext_string.tail_from " ^ s ^ " : " ^ string_of_int x)
  else String.sub s x (len - x)

let rec rindex_rec s i c =
  if i < 0 then i
  else if String.unsafe_get s i = c then i
  else rindex_rec s (i - 1) c

let rindex_neg s c = rindex_rec s (String.length s - 1) c
