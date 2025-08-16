(* Copyright (C) 2018 Hongbo Zhang, Authors of ReScript
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

(**
    [hit_mask mask lambda] iters through the lambda
    set the bit of corresponding [id] if [id] is hit.
    As an optimization step if [mask_and_check_all_hit],
    there is no need to iter such lambda any more
*)
let hit_mask (mask : Hash_set_ident_mask.t) (l : Lam.t) : bool =
  let rec hit_opt (x : Lam.t option) =
    match x with None -> false | Some a -> hit a
  and hit_var (id : Ident.t) =
    Hash_set_ident_mask.mask_and_check_all_hit mask id
  and hit_list_snd : 'a. ('a * Lam.t) list -> bool =
   fun x -> List.exists ~f:(fun (_, x) -> hit x) x
  and hit_list xs = List.exists ~f:hit xs
  and hit (l : Lam.t) =
    match l with
    | Lvar id | Lmutvar id -> hit_var id
    | Lassign (id, e) -> hit_var id || hit e
    | Lstaticcatch (e1, (_, _), e2) -> hit e1 || hit e2
    | Ltrywith (e1, _exn, e2) -> hit e1 || hit e2
    | Lfunction { body; params = _; _ } -> hit body
    | Llet (_, _id, arg, body) | Lmutlet (_id, arg, body) -> hit arg || hit body
    | Lletrec (decl, body) -> hit body || hit_list_snd decl
    | Lfor (_v, e1, e2, _dir, e3) -> hit e1 || hit e2 || hit e3
    | Lconst _ -> false
    | Lapply { ap_func; ap_args; _ } -> hit ap_func || hit_list ap_args
    | Lglobal_module _ (* playsafe *) -> false
    | Lprim { args; _ } -> hit_list args
    | Lswitch (arg, sw) ->
        hit arg || hit_list_snd sw.sw_consts || hit_list_snd sw.sw_blocks
        || hit_opt sw.sw_failaction
    | Lstringswitch (arg, cases, default) ->
        hit arg || hit_list_snd cases || hit_opt default
    | Lstaticraise (_, args) -> hit_list args
    | Lifthenelse (e1, e2, e3) -> hit e1 || hit e2 || hit e3
    | Lsequence (e1, e2) -> hit e1 || hit e2
    | Lwhile (e1, e2) -> hit e1 || hit e2
    | Lsend (_k, met, obj, args, _) -> hit met || hit obj || hit_list args
    | Lifused (_v, e) -> hit e
  in
  hit l

type bindings = (Ident.t * Lam.t) Nonempty_list.t

let preprocess_deps groups : _ * Ident.t array * Vec_int.t array =
  let len = List.length groups in
  let domain : _ Ident.Ordered_hash_map.t = Ident.Ordered_hash_map.create len in
  let mask = Hash_set_ident_mask.create len in
  List.iter
    ~f:(fun (x, lam) ->
      Ident.Ordered_hash_map.add domain ~key:x ~data:lam;
      Hash_set_ident_mask.add_unmask mask x)
    groups;
  let int_mapping = Ident.Ordered_hash_map.to_sorted_array domain in
  let node_vec = Array.make (Array.length int_mapping) (Vec_int.empty ()) in
  Ident.Ordered_hash_map.iter domain ~f:(fun _id lam key_index ->
      let base_key = node_vec.(key_index) in
      ignore (hit_mask mask lam);
      Hash_set_ident_mask.iter_and_unmask mask ~f:(fun ident hit ->
          if hit then
            let key = Ident.Ordered_hash_map.rank domain ident in
            Vec_int.push base_key key));
  (domain, int_mapping, node_vec)

let is_function_bind (_, (x : Lam.t)) =
  match x with Lfunction _ -> true | _ -> false

let sort_single_binding_group group =
  if List.for_all ~f:is_function_bind group then group
  else
    List.sort
      ~cmp:(fun (_, lama) (_, lamb) ->
        match ((lama : Lam.t), (lamb : Lam.t)) with
        | Lfunction _, Lfunction _ -> 0
        | Lfunction _, _ -> -1
        | _, Lfunction _ -> 1
        | _, _ -> 0)
      group

(** TODO: even for a singleton recursive function, tell whehter it is recursive or not ? *)
let scc_bindings (groups : bindings) : bindings Nonempty_list.t =
  match groups with
  | [ _ ] ->
      [
        sort_single_binding_group (Nonempty_list.to_list groups)
        |> Nonempty_list.of_list_exn;
      ]
  | _ :: _ ->
      let domain, int_mapping, node_vec =
        preprocess_deps (Nonempty_list.to_list groups)
      in
      let clusters : Int_vec_vec.t = Scc.graph node_vec in
      if Int_vec_vec.length clusters <= 1 then
        [
          sort_single_binding_group (Nonempty_list.to_list groups)
          |> Nonempty_list.of_list_exn;
        ]
      else
        Int_vec_vec.fold_right clusters ~init:[] ~f:(fun (v : Vec_int.t) acc ->
            let bindings =
              Vec_int.map_into_list v ~f:(fun i ->
                  let id = int_mapping.(i) in
                  let lam = Ident.Ordered_hash_map.find_value domain id in
                  (id, lam))
            in
            (sort_single_binding_group bindings |> Nonempty_list.of_list_exn)
            :: acc)
        |> Nonempty_list.of_list_exn

(* single binding, it does not make sense to do scc,
   we can eliminate {[ let rec f x = x + x  ]}, but it happens rarely in real world
*)
let scc (groups : bindings) (lam : Lam.t) (body : Lam.t) =
  match groups with
  | [ (id, bind) ] ->
      if Lam_hit.hit_variable id bind then lam else Lam.let_ Strict id bind body
  | _ ->
      let domain, int_mapping, node_vec =
        preprocess_deps (Nonempty_list.to_list groups)
      in
      let clusters = Scc.graph node_vec in
      if Int_vec_vec.length clusters <= 1 then lam
      else
        Int_vec_vec.fold_right clusters ~init:body
          ~f:(fun (v : Vec_int.t) acc ->
            let bindings =
              Vec_int.map_into_list v ~f:(fun i ->
                  let id = int_mapping.(i) in
                  let lam = Ident.Ordered_hash_map.find_value domain id in
                  (id, lam))
            in
            match bindings with
            | [ (id, lam) ] ->
                let base_key = Ident.Ordered_hash_map.rank domain id in
                if Vec_int.mem base_key node_vec.(base_key) then
                  Lam.letrec bindings acc
                else Lam.let_ Strict id lam acc
            | _ -> Lam.letrec bindings acc)
