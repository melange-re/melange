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
(* Adapted for Javascript backend: Hongbo Zhang                        *)

open Import

(*
        [no_bounded_varaibles lambda]
        checks if [lambda] contains bounded variable, for
        example [Llet (str,id,arg,body) ] will fail such check.
        This is used to indicate such lambda expression if it is okay
        to inline directly since if it contains bounded variables it
        must be rebounded before inlining
*)

let no_bounded_variables =
  let rec no_list args = List.for_all ~f:no_bounded_variables args
  and no_list_snd : 'a. ('a * Lam.t) list -> bool =
   fun args -> List.for_all ~f:(fun (_, x) -> no_bounded_variables x) args
  and no_opt = function None -> true | Some a -> no_bounded_variables a
  and no_bounded_variables (l : Lam.t) =
    match l with
    | Lvar _ | Lmutvar _ -> true
    | Lconst _ -> true
    | Lassign (_id, e) -> no_bounded_variables e
    | Lapply { ap_func; ap_args; _ } ->
        no_bounded_variables ap_func && no_list ap_args
    | Lglobal_module _ -> true
    | Lprim { args; primitive = _; _ } -> no_list args
    | Lswitch (arg, sw) ->
        no_bounded_variables arg && no_list_snd sw.sw_consts
        && no_list_snd sw.sw_blocks && no_opt sw.sw_failaction
    | Lstringswitch (arg, cases, default) ->
        no_bounded_variables arg && no_list_snd cases && no_opt default
    | Lstaticraise (_, args) -> no_list args
    | Lifthenelse (e1, e2, e3) ->
        no_bounded_variables e1 && no_bounded_variables e2
        && no_bounded_variables e3
    | Lsequence (e1, e2) -> no_bounded_variables e1 && no_bounded_variables e2
    | Lwhile (e1, e2) -> no_bounded_variables e1 && no_bounded_variables e2
    | Lsend (_k, met, obj, args, _) ->
        no_bounded_variables met && no_bounded_variables obj && no_list args
    | Lifused (_v, e) -> no_bounded_variables e
    | Lstaticcatch (e1, (_, vars), e2) ->
        vars = [] && no_bounded_variables e1 && no_bounded_variables e2
    | Lfunction { body; params; _ } -> params = [] && no_bounded_variables body
    | Lfor _ -> false
    | Ltrywith _ -> false
    | Llet _ | Lmutlet _ -> false
    | Lletrec (decl, body) -> decl = [] && no_bounded_variables body
  in
  fun l -> no_bounded_variables l

(*
   TODO:
   we should have a pass called, always inlinable
   as long as its length is smaller than [exit=exit_id], for example

   {[
     switch(box_name)
       {case "":exit=178;break;
        case "b":exit=178;break;
        case "h":box_type=/* Pp_hbox */0;break;
        case "hov":box_type=/* Pp_hovbox */3;break;
        case "hv":box_type=/* Pp_hvbox */2;break;
        case "v":box_type=/* Pp_vbox */1;break;
        default:box_type=invalid_box(/* () */0);}

       switch(exit){case 178:box_type=/* Pp_box */4;break}
   ]}
*)

(* The third argument is its occurrence,
   when do the substitution, if its occurence is > 1,
   we should refresh
*)
type lam_subst = Id of Lam.t [@@unboxed]

(*
   Simplify  ``catch body with (i ...) handler''
      - if (exit i ...) does not occur in body, suppress catch
      - if (exit i ...) occurs exactly once in body,
        substitute it with handler
      - If handler is a single variable, replace (exit i ..) with it


  Note:
    In ``catch body with (i x1 .. xn) handler''
     Substituted expression is
      let y1 = x1 and ... yn = xn in
      handler[x1 <- y1 ; ... ; xn <- yn]
     For the sake of preserving the uniqueness  of bound variables.
   ASKS: This documentation seems outdated
     (No alpha conversion of ``handler'' is presently needed, since
     substitution of several ``(exit i ...)''
     occurs only when ``handler'' is a variable.)
  Note that
           for [query] result = 2,
           the non-inline cost is
           {[
             var exit ;

             exit = 11;
             exit = 11;

             switch(exit){
               case exit = 11 : body ; break
             }

           ]}
           the inline cost is

           {[
             body;
             body;
           ]}

           when [i] is negative, we can not inline in general,
           since the outer is a traditional [try .. catch] body,
           if it is guaranteed to be non throw, then we can inline
        *)

(* TODO: better heuristics, also if we can group same exit code [j]
       in a very early stage -- maybe we can define our enhanced [Lambda]
       representation and counter can be more precise, for example [apply]
       does not need patch from the compiler

       FIXME:   when inlining, need refresh local bound identifiers
       #1438 when the action containes bounded variable
         to keep the invariant, everytime, we do an inlining,
         we need refresh, just refreshing once is not enough
    We need to decide whether inline or not based on post-simplification
       code, since when we do the substitution
       we use the post-simplified expression, it is more consistent
       TODO: when we do the case merging on the js side,
       the j is not very indicative
*)

let subst_helper ~try_depth (subst : (Ident.t list * lam_subst) Int.Hashtbl.t)
    (query : int -> Lam_exit_count.exit) (lam : Lam.t) : Lam.t =
  let to_lam x =
    let (Id x) = x in
    x
  in
  let rec simplif (lam : Lam.t) =
    match lam with
    | Lstaticcatch (l1, (i, xs), l2) -> (
        (* This section is a port of https://github.com/ocaml/ocaml/pull/1497 *)
        let { Lam_exit_count.count; max_depth } = query i in
        match (count, l2) with
        | 0, _ -> simplif l1
        | _, Lvar _ | _, Lconst _ (* when i >= 0  # 2316 *) ->
            Int.Hashtbl.add subst ~key:i ~data:(xs, Id (simplif l2));
            simplif l1 (* l1 will inline *)
        | 1, _ when max_depth <= !try_depth ->
            assert (max_depth = !try_depth);
            Int.Hashtbl.add subst ~key:i ~data:(xs, Id (simplif l2));
            simplif l1 (* l1 will inline *)
        | _ ->
            let l2 = simplif l2 in
            (* we only inline when [l2] does not contain bound variables
               no need to refresh
            *)
            let ok_to_inline =
              max_depth <= !try_depth && i >= 0 && no_bounded_variables l2
              &&
              let lam_size = Lam_analysis.size l2 in
              (count <= 2 && lam_size < Lam_analysis.exit_inline_size)
              || lam_size < 5
            in
            if ok_to_inline then (
              Int.Hashtbl.add subst ~key:i ~data:(xs, Id l2);
              simplif l1)
            else Lam.staticcatch (simplif l1) (i, xs) l2)
    | Lstaticraise (i, []) -> (
        match Int.Hashtbl.find subst i with
        | _, handler -> to_lam handler
        | exception Not_found -> lam)
    | Lstaticraise (i, ls) -> (
        let ls = List.map ~f:simplif ls in
        match Int.Hashtbl.find subst i with
        | xs, handler ->
            let handler = to_lam handler in
            let ys = List.map ~f:Ident.rename xs in
            let env =
              List.fold_right2
                ~f:(fun x y t -> Ident.Map.add ~key:x ~data:(Lam.var y) t)
                xs ys ~init:Ident.Map.empty
            in
            List.fold_right2
              ~f:(fun y l r -> Lam.let_ Strict y l r)
              ys ls
              ~init:(Lam_subst.subst env handler)
        | exception Not_found -> Lam.staticraise i ls)
    | Lvar _ | Lmutvar _ | Lconst _ -> lam
    | Lapply { ap_func; ap_args; ap_info } ->
        Lam.apply (simplif ap_func) (List.map ~f:simplif ap_args) ap_info
    | Lfunction { arity; params; body; attr } ->
        Lam.function_ ~arity ~params ~body:(simplif body) ~attr
    | Llet (kind, v, l1, l2) -> Lam.let_ kind v (simplif l1) (simplif l2)
    | Lmutlet (v, l1, l2) -> Lam.mutlet v (simplif l1) (simplif l2)
    | Lletrec (bindings, body) ->
        Lam.letrec (List.map_snd bindings ~f:simplif) (simplif body)
    | Lglobal_module _ -> lam
    | Lprim { primitive; args; loc } ->
        let args = List.map ~f:simplif args in
        Lam.prim ~primitive ~args ~loc
    | Lswitch (l, sw) ->
        let new_l = simplif l in
        let new_consts = List.map_snd sw.sw_consts ~f:simplif in
        let new_blocks = List.map_snd sw.sw_blocks ~f:simplif in
        let new_fail = Option.map simplif sw.sw_failaction in
        Lam.switch new_l
          {
            sw with
            sw_consts = new_consts;
            sw_blocks = new_blocks;
            sw_failaction = new_fail;
          }
    | Lstringswitch (l, sw, d) ->
        Lam.stringswitch (simplif l)
          (List.map_snd sw ~f:simplif)
          (Option.map simplif d)
    | Ltrywith (l1, v, l2) ->
        incr try_depth;
        let l1 = simplif l1 in
        decr try_depth;
        Lam.try_ l1 v (simplif l2)
    | Lifthenelse (l1, l2, l3) -> Lam.if_ (simplif l1) (simplif l2) (simplif l3)
    | Lsequence (l1, l2) -> Lam.seq (simplif l1) (simplif l2)
    | Lwhile (l1, l2) -> Lam.while_ (simplif l1) (simplif l2)
    | Lfor (v, l1, l2, dir, l3) ->
        Lam.for_ v (simplif l1) (simplif l2) dir (simplif l3)
    | Lassign (v, l) -> Lam.assign v (simplif l)
    | Lsend (k, m, o, ll, loc) ->
        Lam.send k (simplif m) (simplif o) (List.map ~f:simplif ll) ~loc
    | Lifused (v, l) -> Lam.ifused v (simplif l)
  in
  simplif lam

let simplify_exits (lam : Lam.t) =
  let try_depth = ref 0 in
  let exits = Lam_exit_count.count_helper ~try_depth lam in
  subst_helper ~try_depth (Int.Hashtbl.create 17)
    (Lam_exit_count.get_exit exits)
    lam

(* Compile-time beta-reduction of functions immediately applied:
      Lapply(Lfunction(Curried, params, body), args, loc) ->
        let paramN = argN in ... let param1 = arg1 in body
      Lapply(Lfunction(Tupled, params, body), [Lprim(Pmakeblock(args))], loc) ->
        let paramN = argN in ... let param1 = arg1 in body
   Assumes |args| = |params|.
*)
