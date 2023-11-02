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

include StdLabels.Array

let reverse_range a i len =
  if len = 0 then ()
  else
    for k = 0 to (len - 1) / 2 do
      let t = unsafe_get a (i + k) in
      unsafe_set a (i + k) (unsafe_get a (i + len - 1 - k));
      unsafe_set a (i + len - 1 - k) t
    done

let reverse_of_list = function
  | [] -> [||]
  | hd :: tl as l ->
      let len = Stdlib.List.length l in
      let a = make len hd in
      let rec fill i = function
        | [] -> a
        | hd :: tl ->
            unsafe_set a (len - i - 2) hd;
            fill (i + 1) tl
      in
      fill 0 tl

let rec tolist_f_aux a f i res =
  if i < 0 then res
  else
    let v = unsafe_get a i in
    tolist_f_aux a f (i - 1) (f v :: res)

let to_list_f a f = tolist_f_aux a f (length a - 1) []

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
      let len = Stdlib.List.length tl + 5 in
      let arr = make len b0 in
      unsafe_set arr 1 b1;
      unsafe_set arr 2 b2;
      unsafe_set arr 3 b3;
      unsafe_set arr 4 b4;
      let rec fill i = function
        | [] -> arr
        | hd :: tl ->
            unsafe_set arr i (f hd);
            fill (i + 1) tl
      in
      fill 5 tl
