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

include StdLabels.List

external ( .!() ) : 'a array -> int -> 'a = "%array_unsafe_get"

let rec map_combine l1 l2 f =
  match (l1, l2) with
  | [], [] -> []
  | a1 :: l1, a2 :: l2 -> (f a1, a2) :: map_combine l1 l2 f
  | _, _ -> invalid_arg "List.map_combine"

let rec arr_list_combine_unsafe arr l i j acc f =
  if i = j then acc
  else
    match l with
    | [] -> invalid_arg "List.combine"
    | h :: tl ->
        (f arr.!(i), h) :: arr_list_combine_unsafe arr tl (i + 1) j acc f

let map_combine_array_append arr l acc f =
  let len = Stdlib.Array.length arr in
  arr_list_combine_unsafe arr l 0 len acc f

let map_combine_array arr l f =
  let len = Stdlib.Array.length arr in
  arr_list_combine_unsafe arr l 0 len [] f

let rec map_snd l f =
  match l with
  | [] -> []
  | [ (v1, x1) ] ->
      let y1 = f x1 in
      [ (v1, y1) ]
  | [ (v1, x1); (v2, x2) ] ->
      let y1 = f x1 in
      let y2 = f x2 in
      [ (v1, y1); (v2, y2) ]
  | [ (v1, x1); (v2, x2); (v3, x3) ] ->
      let y1 = f x1 in
      let y2 = f x2 in
      let y3 = f x3 in
      [ (v1, y1); (v2, y2); (v3, y3) ]
  | [ (v1, x1); (v2, x2); (v3, x3); (v4, x4) ] ->
      let y1 = f x1 in
      let y2 = f x2 in
      let y3 = f x3 in
      let y4 = f x4 in
      [ (v1, y1); (v2, y2); (v3, y3); (v4, y4) ]
  | (v1, x1) :: (v2, x2) :: (v3, x3) :: (v4, x4) :: (v5, x5) :: tail ->
      let y1 = f x1 in
      let y2 = f x2 in
      let y3 = f x3 in
      let y4 = f x4 in
      let y5 = f x5 in
      (v1, y1) :: (v2, y2) :: (v3, y3) :: (v4, y4) :: (v5, y5) :: map_snd tail f

let rec map_last l f =
  match l with
  | [] -> []
  | [ x1 ] ->
      let y1 = f true x1 in
      [ y1 ]
  | [ x1; x2 ] ->
      let y1 = f false x1 in
      let y2 = f true x2 in
      [ y1; y2 ]
  | [ x1; x2; x3 ] ->
      let y1 = f false x1 in
      let y2 = f false x2 in
      let y3 = f true x3 in
      [ y1; y2; y3 ]
  | [ x1; x2; x3; x4 ] ->
      let y1 = f false x1 in
      let y2 = f false x2 in
      let y3 = f false x3 in
      let y4 = f true x4 in
      [ y1; y2; y3; y4 ]
  | x1 :: x2 :: x3 :: x4 :: tail ->
      (* make sure that tail is not empty *)
      let y1 = f false x1 in
      let y2 = f false x2 in
      let y3 = f false x3 in
      let y4 = f false x4 in
      y1 :: y2 :: y3 :: y4 :: map_last tail f

let rec fold_left_with_offset l accu i f =
  match l with
  | [] -> accu
  | a :: l -> fold_left_with_offset l (f a accu i) (i + 1) f

let rec same_length xs ys =
  match (xs, ys) with
  | [], [] -> true
  | _ :: xs, _ :: ys -> same_length xs ys
  | _, _ -> false

let rec small_split_at n acc l =
  if n <= 0 then (Stdlib.List.rev acc, l)
  else
    match l with
    | x :: xs -> small_split_at (n - 1) (x :: acc) xs
    | _ -> invalid_arg "List.split_at"

let split_at l n = small_split_at n [] l

let rec split_at_last_aux acc x =
  match x with
  | [] -> invalid_arg "List.split_at_last"
  | [ x ] -> (Stdlib.List.rev acc, x)
  | y0 :: ys -> split_at_last_aux (y0 :: acc) ys

let split_at_last (x : 'a list) =
  match x with
  | [] -> invalid_arg "List.split_at_last"
  | [ a0 ] -> ([], a0)
  | [ a0; a1 ] -> ([ a0 ], a1)
  | [ a0; a1; a2 ] -> ([ a0; a1 ], a2)
  | [ a0; a1; a2; a3 ] -> ([ a0; a1; a2 ], a3)
  | [ a0; a1; a2; a3; a4 ] -> ([ a0; a1; a2; a3 ], a4)
  | a0 :: a1 :: a2 :: a3 :: a4 :: rest ->
      let rev, last = split_at_last_aux [] rest in
      (a0 :: a1 :: a2 :: a3 :: a4 :: rev, last)

let rec length_compare l n =
  if n < 0 then `Gt
  else
    match l with
    | _ :: xs -> length_compare xs (n - 1)
    | [] -> if n = 0 then `Eq else `Lt

let rec length_ge l n =
  if n > 0 then match l with _ :: tl -> length_ge tl (n - 1) | [] -> false
  else true

(**
   {[length xs = length ys + n ]}
*)
let rec length_larger_than_n xs ys n =
  match (xs, ys) with
  | _, [] -> length_compare xs n = `Eq
  | _ :: xs, _ :: ys -> length_larger_than_n xs ys n
  | [], _ -> false

let stable_group =
  let rec group (eq : 'a -> 'a -> bool) lst =
    match lst with [] -> [] | x :: xs -> aux eq x (group eq xs)
  and aux eq (x : 'a) (xss : 'a list list) : 'a list list =
    match xss with
    | [] -> [ [ x ] ]
    | (y0 :: _ as y) :: ys ->
        (* cannot be empty *)
        if eq x y0 then (x :: y) :: ys else y :: aux eq x ys
    | _ :: _ -> assert false
  in
  fun lst eq -> group eq lst |> Stdlib.List.rev

let rec rev_iter l f =
  match l with
  | [] -> ()
  | [ x1 ] -> f x1
  | [ x1; x2 ] ->
      f x2;
      f x1
  | [ x1; x2; x3 ] ->
      f x3;
      f x2;
      f x1
  | [ x1; x2; x3; x4 ] ->
      f x4;
      f x3;
      f x2;
      f x1
  | x1 :: x2 :: x3 :: x4 :: x5 :: tail ->
      rev_iter tail f;
      f x5;
      f x4;
      f x3;
      f x2;
      f x1

let rec for_all2_no_exn l1 l2 p =
  match (l1, l2) with
  | [], [] -> true
  | a1 :: l1, a2 :: l2 -> p a1 a2 && for_all2_no_exn l1 l2 p
  | _, _ -> false

let rec split_map l f =
  match l with
  | [] -> ([], [])
  | [ x1 ] ->
      let a0, b0 = f x1 in
      ([ a0 ], [ b0 ])
  | [ x1; x2 ] ->
      let a1, b1 = f x1 in
      let a2, b2 = f x2 in
      ([ a1; a2 ], [ b1; b2 ])
  | [ x1; x2; x3 ] ->
      let a1, b1 = f x1 in
      let a2, b2 = f x2 in
      let a3, b3 = f x3 in
      ([ a1; a2; a3 ], [ b1; b2; b3 ])
  | [ x1; x2; x3; x4 ] ->
      let a1, b1 = f x1 in
      let a2, b2 = f x2 in
      let a3, b3 = f x3 in
      let a4, b4 = f x4 in
      ([ a1; a2; a3; a4 ], [ b1; b2; b3; b4 ])
  | x1 :: x2 :: x3 :: x4 :: x5 :: tail ->
      let a1, b1 = f x1 in
      let a2, b2 = f x2 in
      let a3, b3 = f x3 in
      let a4, b4 = f x4 in
      let a5, b5 = f x5 in
      let ass, bss = split_map tail f in
      (a1 :: a2 :: a3 :: a4 :: a5 :: ass, b1 :: b2 :: b3 :: b4 :: b5 :: bss)
