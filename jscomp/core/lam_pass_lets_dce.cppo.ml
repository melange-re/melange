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

module Count = struct
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
      Ident.Hashtbl.fold h ~init:[] ~f:(fun ~key ~data acc -> f key data :: acc)
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
      Ident.Hashtbl.add occ ~key:ident ~data:r;
      Ident.Map.add ~key:ident ~data:r bv
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
end

let find_string string_table lam =
  match lam with
  | Lam.Lconst (Const_string { s = ls; unicode = false }) -> ls
  | Lvar i -> Ident.Hashtbl.find string_table i
  | _ -> raise_notrace Not_found

let lets_helper (count_var : Ident.t -> Count.used_info) lam : Lam.t =
  let subst : Lam.t Ident.Hashtbl.t = Ident.Hashtbl.create 32 in
  let string_table : string Ident.Hashtbl.t = Ident.Hashtbl.create 32 in
  let used v = (count_var v).times > 0 in
  let rec simplif (lam : Lam.t) =
    match lam with
    | Lvar v -> Ident.Hashtbl.find_default subst v ~default:lam
    | Lmutvar _ -> lam
    | Llet ((Strict | Alias | StrictOpt), v, Lvar w, l2) ->
        Ident.Hashtbl.add subst ~key:v ~data:(simplif (Lam.var w));
        simplif l2
    | Llet
        ( (Strict as kind),
          v,
          Lprim
            {
              primitive = Pmakeblock (0, _, Mutable) as primitive;
              args = [ linit ];
              loc;
            },
          lbody ) -> (
        let slinit = simplif linit in
        let slbody = simplif lbody in
        try
          (* TODO: record all references variables *)
          Lam_util.refine_let ~kind:Variable v slinit
            (Lam_pass_eliminate_ref.eliminate_ref v slbody)
        with Lam_pass_eliminate_ref.Real_reference ->
          Lam_util.refine_let
            ~kind:(Lam_group.of_lam_kind kind)
            v
            (Lam.prim ~primitive ~args:[ slinit ] ~loc)
            slbody)
    | Llet (Alias, v, l1, l2) -> (
        (* For alias, [l1] is pure, we can always inline,
            when captured, we should avoid recomputation
        *)
        match (count_var v, l1) with
        | { times = 0; _ }, _ -> simplif l2
        | { times = 1; captured = false }, _
        | { times = 1; captured = true }, (Lconst _ | Lvar _)
        | ( _,
            ( Lconst
                ( Const_int _ | Const_char _ | Const_float _ | Const_pointer _
                | Const_js_true | Const_js_false | Const_js_undefined _ )
            (* could be poly-variant [`A] -> [65a]*)
            | Lprim { primitive = Pfield _; args = [ Lglobal_module _ ]; _ } ) )
        (* Const_int64 is no longer primitive
           Note for some constant which is not
           inlined, we can still record it and
           do constant folding independently
        *) ->
            Ident.Hashtbl.add subst ~key:v ~data:(simplif l1);
            simplif l2
        | _, Lconst (Const_string { s; unicode = false }) ->
            (* only "" added for later inlining *)
            Ident.Hashtbl.add string_table ~key:v ~data:s;
            Lam.let_ Alias v l1 (simplif l2)
            (* we need move [simplif l2] later, since adding Hash does have side effect *)
        | _ ->
            Lam.let_ Alias v (simplif l1) (simplif l2)
            (* for Alias, in most cases [l1] is already simplified *))
    | Llet ((StrictOpt as kind), v, l1, lbody) -> (
        if
          (* can not be inlined since [l1] depend on the store
              {[
                let v = [|1;2;3|]
              ]}
              get [StrictOpt] here,  we can not inline v,
              since the value of [v] can be changed

              GPR #1476
              Note to pass the sanitizer, we do need remove dead code (not just best effort)
              This logic is tied to {!Lam_pass_count.count}
              {[
                if kind = Strict || used v then count bv l1
              ]}
              If the code which should be removed is not removed, it will hold references
              to other variables which is already removed.
          *)
          not (used v)
        then simplif lbody (* GPR #1476 *)
        else
          match l1 with
          | Lprim
              {
                primitive = Pmakeblock (0, _, Mutable) as primitive;
                args = [ linit ];
                loc;
              } -> (
              let slinit = simplif linit in
              let slbody = simplif lbody in
              try
                (* TODO: record all references variables *)
                Lam_util.refine_let ~kind:Variable v slinit
                  (Lam_pass_eliminate_ref.eliminate_ref v slbody)
              with Lam_pass_eliminate_ref.Real_reference ->
                Lam_util.refine_let
                  ~kind:(Lam_group.of_lam_kind kind)
                  v
                  (Lam.prim ~primitive ~args:[ slinit ] ~loc)
                  slbody)
          | _ -> (
              let l1 = simplif l1 in
              match l1 with
              | Lconst (Const_string { s; unicode = false }) ->
                  Ident.Hashtbl.add string_table ~key:v ~data:s;
                  (* we need move [simplif lbody] later, since adding Hash does have side effect *)
                  Lam.let_ Alias v l1 (simplif lbody)
              | _ ->
                  Lam_util.refine_let
                    ~kind:(Lam_group.of_lam_kind kind)
                    v l1 (simplif lbody))
          (* TODO: check if it is correct rollback to [StrictOpt]? *))
    | Llet ((Strict as kind), v, l1, l2) -> (
        if not (used v) then
          let l1 = simplif l1 in
          let l2 = simplif l2 in
          if Lam_analysis.no_side_effects l1 then l2 else Lam.seq l1 l2
        else
          let l1 = simplif l1 in

          match (kind, l1) with
          | Strict, Lconst (Const_string { s; unicode = false }) ->
              Ident.Hashtbl.add string_table ~key:v ~data:s;
              Lam.let_ Alias v l1 (simplif l2)
          | _ ->
              Lam_util.refine_let
                ~kind:(Lam_group.of_lam_kind kind)
                v l1 (simplif l2))
    | Lmutlet (v, l1, l2) ->
        if not (used v) then
          let l1 = simplif l1 in
          let l2 = simplif l2 in
          if Lam_analysis.no_side_effects l1 then l2 else Lam.seq l1 l2
        else
          let l1 = simplif l1 in
          Lam_util.refine_let ~kind:Variable v l1 (simplif l2)
    | Lifused (v, l) -> if used v then simplif l else Lam.unit
    | Lsequence (Lifused (v, l1), l2) ->
        if used v then Lam.seq (simplif l1) (simplif l2) else simplif l2
    | Lsequence (l1, l2) -> Lam.seq (simplif l1) (simplif l2)
    | Lapply { ap_func = Lfunction { params; body; _ }; ap_args = args; _ }
      when List.same_length params args ->
        simplif (Lam_beta_reduce.no_names_beta_reduce params body args)
        (* | Lapply{ fn = Lfunction{function_kind = Tupled; params; body}; *)
        (*           args = [Lprim {primitive = Pmakeblock _;  args; _}]; _} *)
        (*   (\* TODO: keep track of this parameter in ocaml trunk, *)
        (*       can we switch to the tupled backend? *)
        (*   *\) *)
        (*   when  List.same_length params  args -> *)
        (*   simplif (Lam_beta_reduce.beta_reduce params body args) *)
    | Lapply { ap_func = l1; ap_args = ll; ap_info } ->
        Lam.apply (simplif l1) (List.map ~f:simplif ll) ap_info
    | Lfunction { arity; params; body; attr; loc } ->
        Lam.function_ ~arity ~params ~body:(simplif body) ~attr ~loc
    | Lconst _ -> lam
    | Lletrec (bindings, body) ->
        Lam.letrec (List.map_snd bindings ~f:simplif) (simplif body)
    | Lprim { primitive = Pstringadd; args = [ l; r ]; loc } -> (
        let l' = simplif l in
        let r' = simplif r in
        match find_string string_table l' with
        | exception Not_found-> Lam.prim ~primitive:Pstringadd ~args:[ l'; r' ] ~loc
        | l_s -> (
            match find_string string_table r' with
            | exception Not_found-> Lam.prim ~primitive:Pstringadd ~args:[ l'; r' ] ~loc
            | r_s ->
                Lam.const (Const_string { s = l_s ^ r_s; unicode = false })))
    | Lprim
        {
          primitive = (Pstringrefu | Pstringrefs) as primitive;
          args = [ l; r ];
          loc;
        } -> (
        (* TODO: introudce new constant *)
        let l' = simplif l in
        let r' = simplif r in
        match find_string string_table l' with
        | exception Not_found-> Lam.prim ~primitive ~args:[ l'; r' ] ~loc
        | l_s -> (
            match r with
            | Lconst (Const_int { i; _ }) ->
                let i = Int32.to_int i in
                if i < String.length l_s && i >= 0 then
                  Lam.const (Const_char l_s.[i])
                else Lam.prim ~primitive ~args:[ l'; r' ] ~loc
            | _ -> Lam.prim ~primitive ~args:[ l'; r' ] ~loc))
    | Lglobal_module _ -> lam
    | Lprim { primitive; args; loc } ->
        Lam.prim ~primitive ~args:(List.map ~f:simplif args) ~loc
    | Lswitch (l, sw) ->
        let new_l = simplif l
        and new_consts = List.map_snd sw.sw_consts ~f:simplif
        and new_blocks = List.map_snd sw.sw_blocks ~f:simplif
        and new_fail = Option.map ~f:simplif sw.sw_failaction in
        Lam.switch new_l
          {
            sw with
            sw_consts = new_consts;
            sw_blocks = new_blocks;
            sw_failaction = new_fail;
          }
    | Lstringswitch (l, sw, d) ->
        Lam.stringswitch (simplif l) (List.map_snd sw ~f:simplif)
          (Option.map ~f:simplif d)
    | Lstaticraise (i, ls) -> Lam.staticraise i (List.map ~f:simplif ls)
    | Lstaticcatch (l1, (i, args), l2) ->
        Lam.staticcatch (simplif l1) (i, args) (simplif l2)
    | Ltrywith (l1, v, l2) -> Lam.try_ (simplif l1) v (simplif l2)
    | Lifthenelse (l1, l2, l3) -> Lam.if_ (simplif l1) (simplif l2) (simplif l3)
    | Lwhile (l1, l2) -> Lam.while_ (simplif l1) (simplif l2)
    | Lfor (v, l1, l2, dir, l3) ->
        Lam.for_ v (simplif l1) (simplif l2) dir (simplif l3)
    | Lassign (v, l) -> Lam.assign v (simplif l)
    | Lsend (k, m, o, ll, loc) ->
        Lam.send k (simplif m) (simplif o) (List.map ~f:simplif ll) ~loc
  in
  simplif lam

(* To transform let-bound references into variables *)
let simplify_lets =
  let count_var occ v =
    match Ident.Hashtbl.find occ v with
    | exception Not_found -> Count.dummy_info ()
    | v -> v
  in
  fun (lam : Lam.t) : Lam.t ->
    let occ = Count.collect_occurs lam in
#ifndef MELANGE_RELEASE_BUILD
    Log.warn ~loc:(Loc.of_pos __POS__) (Count.pp_occ_tbl occ);
#endif
    lets_helper (count_var occ) lam
