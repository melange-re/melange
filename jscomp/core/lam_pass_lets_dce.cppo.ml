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

let lets_helper (count_var : Ident.t -> Lam_pass_count.used_info) lam : Lam.t =
  let subst : Lam.t Ident.Hash.t = Ident.Hash.create 32 in
  let string_table : string Ident.Hash.t = Ident.Hash.create 32 in
  let used v = (count_var v).times > 0 in
  let rec simplif (lam : Lam.t) =
    match lam with
    | Lvar v -> Ident.Hash.find_default subst v lam
    | Lmutvar _ -> lam
    | Llet ((Strict | Alias | StrictOpt), v, Lvar w, l2) ->
        Ident.Hash.add subst v (simplif (Lam.var w));
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
            (Lam.prim ~primitive ~args:[ slinit ] loc)
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
                | Const_js_true | Const_js_false | Const_js_undefined )
            (* could be poly-variant [`A] -> [65a]*)
            | Lprim { primitive = Pfield _; args = [ Lglobal_module _ ]; _ } ) )
        (* Const_int64 is no longer primitive
           Note for some constant which is not
           inlined, we can still record it and
           do constant folding independently
        *) ->
            Ident.Hash.add subst v (simplif l1);
            simplif l2
        | _, Lconst (Const_string { s; unicode = false; comment = _ }) ->
            (* only "" added for later inlining *)
            Ident.Hash.add string_table v s;
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
                  (Lam.prim ~primitive ~args:[ slinit ] loc)
                  slbody)
          | _ -> (
              let l1 = simplif l1 in
              match l1 with
              | Lconst (Const_string { s; unicode = false; comment = _ }) ->
                  Ident.Hash.add string_table v s;
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
          | Strict, Lconst (Const_string { s; unicode = false; comment = _ }) ->
              Ident.Hash.add string_table v s;
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
    | Lfunction { arity; params; body; attr } ->
        Lam.function_ ~arity ~params ~body:(simplif body) ~attr
    | Lconst _ -> lam
    | Lletrec (bindings, body) ->
        Lam.letrec (List.map_snd bindings simplif) (simplif body)
    | Lprim { primitive = Pstringadd; args = [ l; r ]; loc } -> (
        let l' = simplif l in
        let r' = simplif r in
        let opt_l =
          match l' with
          | Lconst (Const_string { s = ls; unicode = false; comment = _ }) -> Some ls
          | Lvar i -> Ident.Hash.find_opt string_table i
          | _ -> None
        in
        match opt_l with
        | None -> Lam.prim ~primitive:Pstringadd ~args:[ l'; r' ] loc
        | Some l_s -> (
            let opt_r =
              match r' with
              | Lconst (Const_string { s = rs; unicode = false; comment = _ }) -> Some rs
              | Lvar i -> Ident.Hash.find_opt string_table i
              | _ -> None
            in
            match opt_r with
            | None -> Lam.prim ~primitive:Pstringadd ~args:[ l'; r' ] loc
            | Some r_s ->
                Lam.const (Const_string { s = l_s ^ r_s; unicode = false; comment = None })))
    | Lprim
        {
          primitive = (Pstringrefu | Pstringrefs) as primitive;
          args = [ l; r ];
          loc;
        } -> (
        (* TODO: introudce new constant *)
        let l' = simplif l in
        let r' = simplif r in
        let opt_l =
          match l' with
          | Lconst (Const_string { s = ls; unicode = false; comment = _ }) -> Some ls
          | Lvar i -> Ident.Hash.find_opt string_table i
          | _ -> None
        in
        match opt_l with
        | None -> Lam.prim ~primitive ~args:[ l'; r' ] loc
        | Some l_s -> (
            match r with
            | Lconst (Const_int { i; _ }) ->
                let i = Int32.to_int i in
                if i < String.length l_s && i >= 0 then
                  Lam.const (Const_char l_s.[i])
                else Lam.prim ~primitive ~args:[ l'; r' ] loc
            | _ -> Lam.prim ~primitive ~args:[ l'; r' ] loc))
    | Lglobal_module _ -> lam
    | Lprim { primitive; args; loc } ->
        Lam.prim ~primitive ~args:(List.map ~f:simplif args) loc
    | Lswitch (l, sw) ->
        let new_l = simplif l
        and new_consts = List.map_snd sw.sw_consts simplif
        and new_blocks = List.map_snd sw.sw_blocks simplif
        and new_fail = Option.map simplif sw.sw_failaction in
        Lam.switch new_l
          {
            sw with
            sw_consts = new_consts;
            sw_blocks = new_blocks;
            sw_failaction = new_fail;
          }
    | Lstringswitch (l, sw, d) ->
        Lam.stringswitch (simplif l) (List.map_snd sw simplif)
          (Option.map simplif d)
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
        Lam.send k (simplif m) (simplif o) (List.map ~f:simplif ll) loc
  in
  simplif lam

(* To transform let-bound references into variables *)
let apply_lets occ lambda =
  let count_var v =
    match Ident.Hash.find_opt occ v with
    | None -> Lam_pass_count.dummy_info ()
    | Some v -> v
  in
  lets_helper count_var lambda

let simplify_lets (lam : Lam.t) : Lam.t =
  let occ = Lam_pass_count.collect_occurs lam in
#ifndef BS_RELEASE_BUILD
  Log.warn ~loc:(Loc.of_pos __POS__) (Lam_pass_count.pp_occ_tbl occ);
#endif
  apply_lets occ lam
