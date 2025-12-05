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

let rec map_combine l1 l2 ~f =
  match (l1, l2) with
  | [], [] -> []
  | a1 :: l1, a2 :: l2 -> (f a1, a2) :: map_combine l1 l2 ~f
  | _, _ -> invalid_arg "List.map_combine"

let rec map_snd l ~f =
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
  | [ (v1, x1); (v2, x2); (v3, x3); (v4, x4); (v5, x5) ] ->
      let y1 = f x1 in
      let y2 = f x2 in
      let y3 = f x3 in
      let y4 = f x4 in
      let y5 = f x5 in
      [ (v1, y1); (v2, y2); (v3, y3); (v4, y4); (v5, y5) ]
  | [ (v1, x1); (v2, x2); (v3, x3); (v4, x4); (v5, x5); (v6, x6) ] ->
      let y1 = f x1 in
      let y2 = f x2 in
      let y3 = f x3 in
      let y4 = f x4 in
      let y5 = f x5 in
      let y6 = f x6 in
      [ (v1, y1); (v2, y2); (v3, y3); (v4, y4); (v5, y5); (v6, y6) ]
  | [ (v1, x1); (v2, x2); (v3, x3); (v4, x4); (v5, x5); (v6, x6); (v7, x7) ] ->
      let y1 = f x1 in
      let y2 = f x2 in
      let y3 = f x3 in
      let y4 = f x4 in
      let y5 = f x5 in
      let y6 = f x6 in
      let y7 = f x7 in
      [ (v1, y1); (v2, y2); (v3, y3); (v4, y4); (v5, y5); (v6, y6); (v7, y7) ]
  | [
   (v1, x1); (v2, x2); (v3, x3); (v4, x4); (v5, x5); (v6, x6); (v7, x7); (v8, x8);
  ] ->
      let y1 = f x1 in
      let y2 = f x2 in
      let y3 = f x3 in
      let y4 = f x4 in
      let y5 = f x5 in
      let y6 = f x6 in
      let y7 = f x7 in
      let y8 = f x8 in
      [
        (v1, y1);
        (v2, y2);
        (v3, y3);
        (v4, y4);
        (v5, y5);
        (v6, y6);
        (v7, y7);
        (v8, y8);
      ]
  | [
   (v1, x1);
   (v2, x2);
   (v3, x3);
   (v4, x4);
   (v5, x5);
   (v6, x6);
   (v7, x7);
   (v8, x8);
   (v9, x9);
  ] ->
      let y1 = f x1 in
      let y2 = f x2 in
      let y3 = f x3 in
      let y4 = f x4 in
      let y5 = f x5 in
      let y6 = f x6 in
      let y7 = f x7 in
      let y8 = f x8 in
      let y9 = f x9 in
      [
        (v1, y1);
        (v2, y2);
        (v3, y3);
        (v4, y4);
        (v5, y5);
        (v6, y6);
        (v7, y7);
        (v8, y8);
        (v9, y9);
      ]
  | [
   (v1, x1);
   (v2, x2);
   (v3, x3);
   (v4, x4);
   (v5, x5);
   (v6, x6);
   (v7, x7);
   (v8, x8);
   (v9, x9);
   (v10, x10);
  ] ->
      let y1 = f x1 in
      let y2 = f x2 in
      let y3 = f x3 in
      let y4 = f x4 in
      let y5 = f x5 in
      let y6 = f x6 in
      let y7 = f x7 in
      let y8 = f x8 in
      let y9 = f x9 in
      let y10 = f x10 in
      [
        (v1, y1);
        (v2, y2);
        (v3, y3);
        (v4, y4);
        (v5, y5);
        (v6, y6);
        (v7, y7);
        (v8, y8);
        (v9, y9);
        (v10, y10);
      ]
  | (v1, x1)
    :: (v2, x2)
    :: (v3, x3)
    :: (v4, x4)
    :: (v5, x5)
    :: (v6, x6)
    :: (v7, x7)
    :: (v8, x8)
    :: (v9, x9)
    :: (v10, x10)
    :: tail ->
      let y1 = f x1 in
      let y2 = f x2 in
      let y3 = f x3 in
      let y4 = f x4 in
      let y5 = f x5 in
      let y6 = f x6 in
      let y7 = f x7 in
      let y8 = f x8 in
      let y9 = f x9 in
      let y10 = f x10 in
      (v1, y1) :: (v2, y2) :: (v3, y3) :: (v4, y4) :: (v5, y5) :: (v6, y6)
      :: (v7, y7) :: (v8, y8) :: (v9, y9) :: (v10, y10) :: map_snd tail ~f

let rec map_last l ~f =
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
  | [ x1; x2; x3; x4; x5 ] ->
      let y1 = f false x1 in
      let y2 = f false x2 in
      let y3 = f false x3 in
      let y4 = f false x4 in
      let y5 = f true x5 in
      [ y1; y2; y3; y4; y5 ]
  | [ x1; x2; x3; x4; x5; x6 ] ->
      let y1 = f false x1 in
      let y2 = f false x2 in
      let y3 = f false x3 in
      let y4 = f false x4 in
      let y5 = f false x5 in
      let y6 = f true x6 in
      [ y1; y2; y3; y4; y5; y6 ]
  | [ x1; x2; x3; x4; x5; x6; x7 ] ->
      let y1 = f false x1 in
      let y2 = f false x2 in
      let y3 = f false x3 in
      let y4 = f false x4 in
      let y5 = f false x5 in
      let y6 = f false x6 in
      let y7 = f true x7 in
      [ y1; y2; y3; y4; y5; y6; y7 ]
  | [ x1; x2; x3; x4; x5; x6; x7; x8 ] ->
      let y1 = f false x1 in
      let y2 = f false x2 in
      let y3 = f false x3 in
      let y4 = f false x4 in
      let y5 = f false x5 in
      let y6 = f false x6 in
      let y7 = f false x7 in
      let y8 = f true x8 in
      [ y1; y2; y3; y4; y5; y6; y7; y8 ]
  | [ x1; x2; x3; x4; x5; x6; x7; x8; x9 ] ->
      let y1 = f false x1 in
      let y2 = f false x2 in
      let y3 = f false x3 in
      let y4 = f false x4 in
      let y5 = f false x5 in
      let y6 = f false x6 in
      let y7 = f false x7 in
      let y8 = f false x8 in
      let y9 = f true x9 in
      [ y1; y2; y3; y4; y5; y6; y7; y8; y9 ]
  | [ x1; x2; x3; x4; x5; x6; x7; x8; x9; x10 ] ->
      let y1 = f false x1 in
      let y2 = f false x2 in
      let y3 = f false x3 in
      let y4 = f false x4 in
      let y5 = f false x5 in
      let y6 = f false x6 in
      let y7 = f false x7 in
      let y8 = f false x8 in
      let y9 = f false x9 in
      let y10 = f true x10 in
      [ y1; y2; y3; y4; y5; y6; y7; y8; y9; y10 ]
  | x1 :: x2 :: x3 :: x4 :: x5 :: x6 :: x7 :: x8 :: x9 :: x10 :: tail ->
      (* the case above makes sure that `tail` is not empty *)
      let y1 = f false x1 in
      let y2 = f false x2 in
      let y3 = f false x3 in
      let y4 = f false x4 in
      let y5 = f false x5 in
      let y6 = f false x6 in
      let y7 = f false x7 in
      let y8 = f false x8 in
      let y9 = f false x9 in
      let y10 = f false x10 in
      y1 :: y2 :: y3 :: y4 :: y5 :: y6 :: y7 :: y8 :: y9 :: y10
      :: map_last tail ~f

let rec fold_left_with_offset l ~init:accu ~off:i ~f =
  match l with
  | [] -> accu
  | a :: l -> fold_left_with_offset l ~init:(f a accu i) ~off:(i + 1) ~f

let rec same_length xs ys =
  match (xs, ys) with
  | [], []
  | [ _ ], [ _ ]
  | [ _; _ ], [ _; _ ]
  | [ _; _; _ ], [ _; _; _ ]
  | [ _; _; _; _ ], [ _; _; _; _ ]
  | [ _; _; _; _; _ ], [ _; _; _; _; _ ]
  | [ _; _; _; _; _; _ ], [ _; _; _; _; _; _ ]
  | [ _; _; _; _; _; _; _ ], [ _; _; _; _; _; _; _ ]
  | [ _; _; _; _; _; _; _; _ ], [ _; _; _; _; _; _; _; _ ]
  | [ _; _; _; _; _; _; _; _; _ ], [ _; _; _; _; _; _; _; _; _ ]
  | [ _; _; _; _; _; _; _; _; _; _ ], [ _; _; _; _; _; _; _; _; _; _ ] ->
      true
  | _ :: xs, _ :: ys -> same_length xs ys
  | _ :: _, [] | [], _ :: _ -> false

let rec small_split_at n acc l =
  if n <= 0 then (rev acc, l)
  else
    match l with
    | x :: xs -> small_split_at (n - 1) (x :: acc) xs
    | _ -> invalid_arg "List.split_at"

let split_at l n = small_split_at n [] l

let split_at_last =
  let rec split_at_last_aux acc x =
    match x with
    | [] -> invalid_arg "List.split_at_last"
    | [ x ] -> (rev acc, x)
    | y0 :: ys -> split_at_last_aux (y0 :: acc) ys
  in
  fun (x : 'a list) ->
    match x with
    | [] -> invalid_arg "List.split_at_last"
    | [ a0 ] -> ([], a0)
    | [ a0; a1 ] -> ([ a0 ], a1)
    | [ a0; a1; a2 ] -> ([ a0; a1 ], a2)
    | [ a0; a1; a2; a3 ] -> ([ a0; a1; a2 ], a3)
    | [ a0; a1; a2; a3; a4 ] -> ([ a0; a1; a2; a3 ], a4)
    | [ a0; a1; a2; a3; a4; a5 ] -> ([ a0; a1; a2; a3; a4 ], a5)
    | [ a0; a1; a2; a3; a4; a5; a6 ] -> ([ a0; a1; a2; a3; a4; a5 ], a6)
    | [ a0; a1; a2; a3; a4; a5; a6; a7 ] -> ([ a0; a1; a2; a3; a4; a5; a6 ], a7)
    | [ a0; a1; a2; a3; a4; a5; a6; a7; a8 ] ->
        ([ a0; a1; a2; a3; a4; a5; a6; a7 ], a8)
    | [ a0; a1; a2; a3; a4; a5; a6; a7; a8; a9 ] ->
        ([ a0; a1; a2; a3; a4; a5; a6; a7; a8 ], a9)
    | [ a0; a1; a2; a3; a4; a5; a6; a7; a8; a9; a10 ] ->
        ([ a0; a1; a2; a3; a4; a5; a6; a7; a8; a9 ], a10)
    | a0 :: a1 :: a2 :: a3 :: a4 :: a5 :: a6 :: a7 :: a8 :: a9 :: a10 :: rest ->
        let rev, last = split_at_last_aux [] rest in
        ( a0 :: a1 :: a2 :: a3 :: a4 :: a5 :: a6 :: a7 :: a8 :: a9 :: a10 :: rev,
          last )

let rec length_compare l n =
  if n < 0 then `Gt
  else
    match l with
    | _ :: xs -> length_compare xs (n - 1)
    | [] -> ( match n with 0 -> `Eq | _ -> `Lt)

let rec length_ge l n =
  if n > 0 then match l with _ :: tl -> length_ge tl (n - 1) | [] -> false
  else true

(* {[length xs = length ys + n ]} *)
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
  fun lst ~equal -> group equal lst |> rev

let rec rev_iter l ~f =
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
  | [ x1; x2; x3; x4; x5 ] ->
      f x5;
      f x4;
      f x3;
      f x2;
      f x1
  | [ x1; x2; x3; x4; x5; x6 ] ->
      f x6;
      f x5;
      f x4;
      f x3;
      f x2;
      f x1
  | [ x1; x2; x3; x4; x5; x6; x7 ] ->
      f x7;
      f x6;
      f x5;
      f x4;
      f x3;
      f x2;
      f x1
  | [ x1; x2; x3; x4; x5; x6; x7; x8 ] ->
      f x8;
      f x7;
      f x6;
      f x5;
      f x4;
      f x3;
      f x2;
      f x1
  | [ x1; x2; x3; x4; x5; x6; x7; x8; x9 ] ->
      f x9;
      f x8;
      f x7;
      f x6;
      f x5;
      f x4;
      f x3;
      f x2;
      f x1
  | [ x1; x2; x3; x4; x5; x6; x7; x8; x9; x10 ] ->
      f x10;
      f x9;
      f x8;
      f x7;
      f x6;
      f x5;
      f x4;
      f x3;
      f x2;
      f x1
  | x1 :: x2 :: x3 :: x4 :: x5 :: x6 :: x7 :: x8 :: x9 :: x10 :: tail ->
      rev_iter tail ~f;
      f x10;
      f x9;
      f x8;
      f x7;
      f x6;
      f x5;
      f x4;
      f x3;
      f x2;
      f x1

let rec for_all2_no_exn l1 l2 ~f =
  match (l1, l2) with
  | [], [] -> true
  | [ a1 ], [ a2 ] -> f a1 a2
  | [ a1; b1 ], [ a2; b2 ] -> f a1 a2 && f b1 b2
  | [ a1; b1; c1 ], [ a2; b2; c2 ] -> f a1 a2 && f b1 b2 && f c1 c2
  | [ a1; b1; c1; d1 ], [ a2; b2; c2; d2 ] ->
      f a1 a2 && f b1 b2 && f c1 c2 && f d1 d2
  | [ a1; b1; c1; d1; e1 ], [ a2; b2; c2; d2; e2 ] ->
      f a1 a2 && f b1 b2 && f c1 c2 && f d1 d2 && f e1 e2
  | [ a1; b1; c1; d1; e1; f1 ], [ a2; b2; c2; d2; e2; f2 ] ->
      f a1 a2 && f b1 b2 && f c1 c2 && f d1 d2 && f e1 e2 && f f1 f2
  | [ a1; b1; c1; d1; e1; f1; g1 ], [ a2; b2; c2; d2; e2; f2; g2 ] ->
      f a1 a2 && f b1 b2 && f c1 c2 && f d1 d2 && f e1 e2 && f f1 f2 && f g1 g2
  | [ a1; b1; c1; d1; e1; f1; g1; h1 ], [ a2; b2; c2; d2; e2; f2; g2; h2 ] ->
      f a1 a2 && f b1 b2 && f c1 c2 && f d1 d2 && f e1 e2 && f f1 f2 && f g1 g2
      && f h1 h2
  | ( [ a1; b1; c1; d1; e1; f1; g1; h1; i1 ],
      [ a2; b2; c2; d2; e2; f2; g2; h2; i2 ] ) ->
      f a1 a2 && f b1 b2 && f c1 c2 && f d1 d2 && f e1 e2 && f f1 f2 && f g1 g2
      && f h1 h2 && f i1 i2
  | ( [ a1; b1; c1; d1; e1; f1; g1; h1; i1; j1 ],
      [ a2; b2; c2; d2; e2; f2; g2; h2; i2; j2 ] ) ->
      f a1 a2 && f b1 b2 && f c1 c2 && f d1 d2 && f e1 e2 && f f1 f2 && f g1 g2
      && f h1 h2 && f i1 i2 && f j1 j2
  | ( a1 :: b1 :: c1 :: d1 :: e1 :: f1 :: g1 :: h1 :: i1 :: j1 :: l1,
      a2 :: b2 :: c2 :: d2 :: e2 :: f2 :: g2 :: h2 :: i2 :: j2 :: l2 ) ->
      f a1 a2 && f b1 b2 && f c1 c2 && f d1 d2 && f e1 e2 && f f1 f2 && f g1 g2
      && f h1 h2 && f i1 i2 && f j1 j2 && for_all2_no_exn l1 l2 ~f
  | a1 :: l1, a2 :: l2 -> f a1 a2 && for_all2_no_exn l1 l2 ~f
  | _, _ -> false

let rec split_map l ~f =
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
  | [ x1; x2; x3; x4; x5 ] ->
      let a1, b1 = f x1 in
      let a2, b2 = f x2 in
      let a3, b3 = f x3 in
      let a4, b4 = f x4 in
      let a5, b5 = f x5 in
      ([ a1; a2; a3; a4; a5 ], [ b1; b2; b3; b4; b5 ])
  | [ x1; x2; x3; x4; x5; x6 ] ->
      let a1, b1 = f x1 in
      let a2, b2 = f x2 in
      let a3, b3 = f x3 in
      let a4, b4 = f x4 in
      let a5, b5 = f x5 in
      let a6, b6 = f x6 in
      ([ a1; a2; a3; a4; a5; a6 ], [ b1; b2; b3; b4; b5; b6 ])
  | [ x1; x2; x3; x4; x5; x6; x7 ] ->
      let a1, b1 = f x1 in
      let a2, b2 = f x2 in
      let a3, b3 = f x3 in
      let a4, b4 = f x4 in
      let a5, b5 = f x5 in
      let a6, b6 = f x6 in
      let a7, b7 = f x7 in
      ([ a1; a2; a3; a4; a5; a6; a7 ], [ b1; b2; b3; b4; b5; b6; b7 ])
  | [ x1; x2; x3; x4; x5; x6; x7; x8 ] ->
      let a1, b1 = f x1 in
      let a2, b2 = f x2 in
      let a3, b3 = f x3 in
      let a4, b4 = f x4 in
      let a5, b5 = f x5 in
      let a6, b6 = f x6 in
      let a7, b7 = f x7 in
      let a8, b8 = f x8 in
      ([ a1; a2; a3; a4; a5; a6; a7; a8 ], [ b1; b2; b3; b4; b5; b6; b7; b8 ])
  | [ x1; x2; x3; x4; x5; x6; x7; x8; x9 ] ->
      let a1, b1 = f x1 in
      let a2, b2 = f x2 in
      let a3, b3 = f x3 in
      let a4, b4 = f x4 in
      let a5, b5 = f x5 in
      let a6, b6 = f x6 in
      let a7, b7 = f x7 in
      let a8, b8 = f x8 in
      let a9, b9 = f x9 in
      ( [ a1; a2; a3; a4; a5; a6; a7; a8; a9 ],
        [ b1; b2; b3; b4; b5; b6; b7; b8; b9 ] )
  | [ x1; x2; x3; x4; x5; x6; x7; x8; x9; x10 ] ->
      let a1, b1 = f x1 in
      let a2, b2 = f x2 in
      let a3, b3 = f x3 in
      let a4, b4 = f x4 in
      let a5, b5 = f x5 in
      let a6, b6 = f x6 in
      let a7, b7 = f x7 in
      let a8, b8 = f x8 in
      let a9, b9 = f x9 in
      let a10, b10 = f x10 in
      ( [ a1; a2; a3; a4; a5; a6; a7; a8; a9; a10 ],
        [ b1; b2; b3; b4; b5; b6; b7; b8; b9; b10 ] )
  | x1 :: x2 :: x3 :: x4 :: x5 :: x6 :: x7 :: x8 :: x9 :: x10 :: tail ->
      let a1, b1 = f x1 in
      let a2, b2 = f x2 in
      let a3, b3 = f x3 in
      let a4, b4 = f x4 in
      let a5, b5 = f x5 in
      let a6, b6 = f x6 in
      let a7, b7 = f x7 in
      let a8, b8 = f x8 in
      let a9, b9 = f x9 in
      let a10, b10 = f x10 in
      let ass, bss = split_map tail ~f in
      ( a1 :: a2 :: a3 :: a4 :: a5 :: a6 :: a7 :: a8 :: a9 :: a10 :: ass,
        b1 :: b2 :: b3 :: b4 :: b5 :: b6 :: b7 :: b8 :: b9 :: b10 :: bss )
