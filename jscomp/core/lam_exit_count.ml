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

type exit = { mutable count : int; mutable max_depth : int }
type collection = (int, exit) Hashtbl.t

let get_exit exits i =
  match Hashtbl.find exits i with
  | v -> v
  | exception Not_found -> { count = 0; max_depth = 0 }

let incr_exit exits i nb d =
  match Hashtbl.find exits i with
  | r ->
      r.count <- r.count + nb;
      r.max_depth <- max r.max_depth d
  | exception Not_found ->
      let r = { count = nb; max_depth = d } in
      Hashtbl.add exits ~key:i ~data:r

(**
  This function counts how each [exit] is used, it will affect how the following optimizations performed.

  Some smart cases (this requires the following optimizations follow it):

  {[
    Lstaticcatch(l1, (i,_), l2)
  ]}
  If [l1] does not contain [(exit i)],
  [l2] will be removed, so don't count it.

  About Switch default branch handling, it maybe backend-specific
  See https://github.com/ocaml/ocaml/commit/fcf3571123e2c914768e34f1bd17e4cbaaa7d212#diff-704f66c0fa0fc9339230b39ce7d90919
  For Lstringswitch ^

  For Lswitch, if it is not exhuastive pattern match, default will be counted twice.
  Since for pattern match,  we will  test whether it is  an integer or block, both have default cases predicate: [sw_consts_full] vs nconsts
*)
let count_helper ~try_depth (lam : Lam.t) : collection =
  let exits : collection = Hashtbl.create 17 in
  let rec count (lam : Lam.t) =
    match lam with
    | Lstaticraise (i, ls) ->
        incr_exit exits i 1 !try_depth;
        List.iter ~f:count ls
    | Lstaticcatch (l1, (i, []), Lstaticraise (j, [])) ->
        count l1;
        let ic = get_exit exits i in
        incr_exit exits j ic.count (max !try_depth ic.max_depth)
    | Lstaticcatch (l1, (i, _), l2) ->
        count l1;
        if (get_exit exits i).count > 0 then count l2
    | Lstringswitch (l, sw, d) ->
        count l;
        List.iter ~f:(fun (_, x) -> count x) sw;
        Option.iter count d
    | Lglobal_module _ | Lvar _ | Lmutvar _ | Lconst _ -> ()
    | Lapply { ap_func; ap_args; _ } ->
        count ap_func;
        List.iter ~f:count ap_args
    | Lfunction { body; _ } -> count body
    | Llet (_, _, l1, l2) | Lmutlet (_, l1, l2) ->
        count l2;
        count l1
    | Lletrec (bindings, body) ->
        List.iter ~f:(fun (_, x) -> count x) bindings;
        count body
    | Lprim { args; _ } -> List.iter ~f:count args
    | Lswitch (l, sw) ->
        count_default sw;
        count l;
        List.iter ~f:(fun (_, x) -> count x) sw.sw_consts;
        List.iter ~f:(fun (_, x) -> count x) sw.sw_blocks
    | Ltrywith (l1, _v, l2) ->
        incr try_depth;
        count l1;
        decr try_depth;
        count l2
    | Lifthenelse (l1, l2, l3) ->
        count l1;
        count l2;
        count l3
    | Lsequence (l1, l2) ->
        count l1;
        count l2
    | Lwhile (l1, l2) ->
        count l1;
        count l2
    | Lfor (_, l1, l2, _dir, l3) ->
        count l1;
        count l2;
        count l3
    | Lassign (_, l) -> count l
    | Lsend (_, m, o, ll, _) ->
        count m;
        count o;
        List.iter ~f:count ll
    | Lifused (_v, e) -> count e
  and count_default sw =
    match sw.sw_failaction with
    | None -> ()
    | Some al ->
        if (not sw.sw_consts_full) && not sw.sw_blocks_full then (
          count al;
          count al)
        else count al
  in
  count lam;
  assert (!try_depth = 0);
  exits
