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

let reverse_range a i len =
  if len = 0 then ()
  else
    for k = 0 to (len - 1) / 2 do
      let t = Array.unsafe_get a (i + k) in
      Array.unsafe_set a (i + k) (Array.unsafe_get a (i + len - 1 - k));
      Array.unsafe_set a (i + len - 1 - k) t
    done

let reverse_of_list = function
  | [] -> [||]
  | hd :: tl as l ->
      let len = List.length l in
      let a = Array.make len hd in
      let rec fill i = function
        | [] -> a
        | hd :: tl ->
            Array.unsafe_set a (len - i - 2) hd;
            fill (i + 1) tl
      in
      fill 0 tl

let rec tolist_f_aux a f i res =
  if i < 0 then res
  else
    let v = Array.unsafe_get a i in
    tolist_f_aux a f (i - 1) (f v :: res)

let to_list_f a f = tolist_f_aux a f (Array.length a - 1) []

let of_list_map a f =
  match a with
  | [] -> [||]
  | [ a0 ] ->
      let b0 = f a0 in
      [| b0 |]
  | [ a0; a1 ] ->
      let b0 = f a0 in
      let b1 = f a1 in
      [| b0; b1 |]
  | [ a0; a1; a2 ] ->
      let b0 = f a0 in
      let b1 = f a1 in
      let b2 = f a2 in
      [| b0; b1; b2 |]
  | [ a0; a1; a2; a3 ] ->
      let b0 = f a0 in
      let b1 = f a1 in
      let b2 = f a2 in
      let b3 = f a3 in
      [| b0; b1; b2; b3 |]
  | [ a0; a1; a2; a3; a4 ] ->
      let b0 = f a0 in
      let b1 = f a1 in
      let b2 = f a2 in
      let b3 = f a3 in
      let b4 = f a4 in
      [| b0; b1; b2; b3; b4 |]
  | a0 :: a1 :: a2 :: a3 :: a4 :: tl ->
      let b0 = f a0 in
      let b1 = f a1 in
      let b2 = f a2 in
      let b3 = f a3 in
      let b4 = f a4 in
      let len = List.length tl + 5 in
      let arr = Array.make len b0 in
      Array.unsafe_set arr 1 b1;
      Array.unsafe_set arr 2 b2;
      Array.unsafe_set arr 3 b3;
      Array.unsafe_set arr 4 b4;
      let rec fill i = function
        | [] -> arr
        | hd :: tl ->
            Array.unsafe_set arr i (f hd);
            fill (i + 1) tl
      in
      fill 5 tl

(**
   {[
     # rfind_with_index [|1;2;3|] (=) 2;;
     - : int = 1
               # rfind_with_index [|1;2;3|] (=) 1;;
     - : int = 0
               # rfind_with_index [|1;2;3|] (=) 3;;
     - : int = 2
               # rfind_with_index [|1;2;3|] (=) 4;;
     - : int = -1
   ]}
*)
let rfind_with_index arr cmp v =
  let len = Array.length arr in
  let rec aux i =
    if i < 0 then i
    else if cmp (Array.unsafe_get arr i) v then i
    else aux (i - 1)
  in
  aux (len - 1)

(** TODO: available since 4.03, use {!Array.exists} *)

let for_alli a p =
  let n = Array.length a in
  let rec loop i =
    if i = n then true
    else if p i (Array.unsafe_get a i) then loop (succ i)
    else false
  in
  loop 0

let map a f =
  let open Array in
  let l = length a in
  if l = 0 then [||]
  else
    let r = make l (f (unsafe_get a 0)) in
    for i = 1 to l - 1 do
      unsafe_set r i (f (unsafe_get a i))
    done;
    r

let iter a f =
  let open Array in
  for i = 0 to length a - 1 do
    f (unsafe_get a i)
  done

let fold_left a x f =
  let open Array in
  let r = ref x in
  for i = 0 to length a - 1 do
    r := f !r (unsafe_get a i)
  done;
  !r

let get_or arr i cb =
  if i >= 0 && i < Array.length arr then Array.unsafe_get arr i else cb ()
