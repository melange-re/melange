(* Copyright (C) 2025- Authors of Melange
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

type 'a t = ( :: ) of 'a * 'a list

let hd (x :: _) = x
let tl (_ :: xs) = xs
let of_list = function [] -> None | x :: xs -> Some (x :: xs)
let of_list_exn = function [] -> assert false | x :: xs -> x :: xs
let to_list (x :: xs) = List.cons x xs

let map (x :: xs) ~f =
  let x = f x in
  x :: List.map xs ~f

let iter (x :: xs) ~f =
  f x;
  List.iter xs ~f

let to_list_rev_map (x :: xs) ~f =
  let x = f x in
  let init = List.cons x [] in
  List.fold_left xs ~init ~f:(fun acc x ->
      let x = f x in
      List.cons x acc)

let mapi (x :: xs) ~f =
  let x = f 0 x in
  x :: List.mapi xs ~f:(fun i x -> f (i + 1) x)

let map_last (x :: xs) ~f =
  match xs with
  | [] -> f true x :: []
  | _ ->
      let x = f false x in
      x :: List.map_last xs ~f

let stable_group =
  let rec group (equal : 'a -> 'a -> bool) = function
    | [] -> []
    | x :: xs -> aux equal x (group equal xs)
  and aux equal (x : 'a) (groups : 'a t list) : 'a t list =
    match groups with
    | [] ->
        let group = x :: [] in
        List.cons group []
    | (y0 :: yrest as group) :: groups ->
        if equal x y0 then
          let group = x :: List.cons y0 yrest in
          List.cons group groups
        else List.cons group (aux equal x groups)
  in
  fun xs ~equal -> List.rev (group equal xs)
