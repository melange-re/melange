(************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(************************************)
(* Adapted for Javascript backend : Hongbo Zhang,  *)

open Import

(* A naive dead code elimination *)
type used_info = {
  mutable times : int;
  mutable captured : bool;
      (* captured in functon or loop,
         inline in such cases should be careful
         1. can not inline mutable values
         2. avoid re-computation
      *)
}

type t = used_info Ident.Hashtbl.t
(* First pass: count the occurrences of all let-bound identifiers *)

type local_tbl = used_info Ident.Map.t

let dummy_info () = { times = 0; captured = false }
(* y is untouched *)

let absorb_info (x : used_info) (y : used_info) =
  match (x, y) with
  | { times = x0; _ }, { times = y0; captured } ->
      x.times <- x0 + y0;
      if captured then x.captured <- true

let pp_info (x : used_info) = Pp.textf "(<captured:%b>:%d)" x.captured x.times

let pp_occ_tbl =
  let to_list h f =
    Ident.Hashtbl.fold (fun k data acc -> f k data :: acc) h []
  in
  fun tbl ->
    to_list tbl (fun k v ->
        Pp.box
          (Pp.concat ~sep:Pp.space
             [ Pp.text (Format.asprintf "%a" Ident.print k); pp_info v ]))
    |> Pp.concat ~sep:Pp.newline

(* The global table [occ] associates to each let-bound identifier
   the number of its uses (as a reference):
   - 0 if never used
   - 1 if used exactly once in and not under a lambda or within a loop
       - when under a lambda,
       - it's probably a closure
       - within a loop
       - update reference,
       niether is good for inlining
   - > 1 if used several times or under a lambda or within a loop.
   The local table [bv] associates to each locally-let-bound variable
   its reference count, as above.  [bv] is enriched at let bindings
   but emptied when crossing lambdas and loops. *)
let collect_occurs lam : t =
  let occ : t = Ident.Hashtbl.create 83 in

  (* Current use count of a variable. *)
  let used v =
    match Ident.Hashtbl.find occ v with
    | exception Not_found -> false
    | { times; _ } -> times > 0
  in

  (* Entering a [let].  Returns updated [bv]. *)
  let bind_var bv ident =
    let r = dummy_info () in
    Ident.Hashtbl.add occ ident r;
    Ident.Map.add ident r bv
  in

  (* Record a use of a variable *)
  let add_one_use bv ident =
    match Ident.Map.find ident bv with
    | r -> r.times <- r.times + 1
    | exception Not_found -> (
        (* ident is not locally bound, therefore this is a use under a lambda
           or within a loop.  Increase use count by 2 -- enough so
           that single-use optimizations will not apply. *)
        match Ident.Hashtbl.find occ ident with
        | r -> absorb_info r { times = 1; captured = true }
        | exception Not_found ->
            (* Not a let-bound variable, ignore *)
            ())
  in

  let inherit_use bv ident bid =
    let n =
      match Ident.Hashtbl.find occ bid with
      | exception Not_found -> dummy_info ()
      | v -> v
    in
    match Ident.Map.find ident bv with
    | r -> absorb_info r n
    | exception Not_found -> (
        (* ident is not locally bound, therefore this is a use under a lambda
           or within a loop.  Increase use count by 2 -- enough so
           that single-use optimizations will not apply. *)
        match Ident.Hashtbl.find occ ident with
        | r -> absorb_info r { n with captured = true }
        | exception Not_found ->
            (* Not a let-bound variable, ignore *)
            ())
  in

  let rec count (bv : local_tbl) (lam : Lam.t) =
    match lam with
    | Lfunction { body = l; _ } -> count Ident.Map.empty l
    (* when entering a function local [bv]
        is cleaned up, so that all closure variables will not be
        carried over, since the parameters are never rebound,
        so it is fine to kep it empty
    *)
    | Lfor (_, l1, l2, _dir, l3) ->
        count bv l1;
        count bv l2;
        count Ident.Map.empty l3
    | Lwhile (l1, l2) ->
        count Ident.Map.empty l1;
        count Ident.Map.empty l2
    | Lvar v | Lmutvar v -> add_one_use bv v
    | Llet (_, v, Lvar w, l2) ->
        (* v will be replaced by w in l2, so each occurrence of v in l2
           increases w's refcount *)
        count (bind_var bv v) l2;
        inherit_use bv w v
    | Llet (kind, v, l1, l2) ->
        count (bind_var bv v) l2;
        (* count [l2] first,
           If v is unused, l1 will be removed, so don't count its variables *)
        if kind = Strict || used v then count bv l1
    | Lmutlet (_, l1, l2) ->
        count bv l1;
        count bv l2
    | Lassign (_, l) ->
        (* Lalias-bound variables are never assigned, so don't increase
           this ident's refcount *)
        count bv l
    | Lglobal_module _ -> ()
    | Lprim { args; _ } -> List.iter ~f:(count bv) args
    | Lletrec (bindings, body) ->
        List.iter ~f:(fun (_v, l) -> count bv l) bindings;
        count bv body
        (* Note there is a difference here when do beta reduction for *)
    | Lapply { ap_func = Lfunction { params; body; _ }; ap_args = args; _ }
      when List.same_length params args ->
        count bv (Lam_beta_reduce.no_names_beta_reduce params body args)
    (* | Lapply{fn = Lfunction{function_kind = Tupled; params; body}; *)
    (*          args = [Lprim {primitive = Pmakeblock _;  args; _}]; _} *)
    (*   when  List.same_length params  args -> *)
    (*   count bv (Lam_beta_reduce.beta_reduce   params body args) *)
    | Lapply { ap_func = l1; ap_args = ll; _ } ->
        count bv l1;
        List.iter ~f:(count bv) ll
    | Lconst _cst -> ()
    | Lswitch (l, sw) ->
        count_default bv sw;
        count bv l;
        List.iter ~f:(fun (_, l) -> count bv l) sw.sw_consts;
        List.iter ~f:(fun (_, l) -> count bv l) sw.sw_blocks
    | Lstringswitch (l, sw, d) -> (
        count bv l;
        List.iter ~f:(fun (_, l) -> count bv l) sw;
        match d with Some d -> count bv d | None -> ())
    (* x2 for native backend *)
    (* begin match sw with *)
    (* | []|[_] -> count bv d *)
    (* | _ -> count bv d ; count bv d *)
    (* end *)
    | Lstaticraise (_i, ls) -> List.iter ~f:(count bv) ls
    | Lstaticcatch (l1, (_i, _), l2) ->
        count bv l1;
        count bv l2
    | Ltrywith (l1, _v, l2) ->
        count bv l1;
        count bv l2
    | Lifthenelse (l1, l2, l3) ->
        count bv l1;
        count bv l2;
        count bv l3
    | Lsequence (l1, l2) ->
        count bv l1;
        count bv l2
    | Lsend (_, m, o, ll, _) ->
        count bv m;
        count bv o;
        List.iter ~f:(count bv) ll
    | Lifused (v, l) -> if used v then count bv l
  and count_default bv sw =
    match sw.sw_failaction with
    | None -> ()
    | Some al ->
        if (not sw.sw_consts_full) && not sw.sw_blocks_full then (
          (* default action will occur twice in native code *)
          count bv al;
          count bv al)
        else (
          (* default action will occur once *)
          assert ((not sw.sw_consts_full) || not sw.sw_blocks_full);
          count bv al)
  in
  count Ident.Map.empty lam;
  occ
