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

open Import

(* Check, it is shared across ident_tbl,
    Only [Lassign] will break such invariant,
    how about guarantee that [Lassign] only check the local ref
    and we track which ids are [Lassign]ed
*)
(*
   might not be the same due to refinement
   assert (old.arity = v)
*)
let annotate (meta : Lam_stats.t) rec_flag (k : Ident.t) (arity : Lam_arity.t)
    lambda =
  Ident.Hashtbl.add meta.ident_tbl ~key:k
    ~data:(FunctionId { arity; lambda = Some (lambda, rec_flag) })

(* see #3609
   we have to update since bounded function lambda
   may contain staled unbounded varaibles
*)
(* match Ident.Hashtbl.find  meta.ident_tbl k  with
   | exception Not_found -> (* FIXME: need do a sanity check of arity is NA or Determin(_,[],_) *)

   | (FunctionId old)  ->
     Ident.Hashtbl.add meta.ident_tbl k
       (FunctionId {arity; lambda = Some (lambda, rec_flag) })
     (* old.arity <- arity   *)
     (* due to we keep refining arity analysis after each round*)
   | _ -> assert false *)
(* TODO -- avoid exception *)

(* it only make senses recording arities for
    function definition,
    alias propgation - and toplevel identifiers, this needs to be exported
*)
let collect_info =
  let rec collect_bind (meta : Lam_stats.t) rec_flag (ident : Ident.t)
      (lam : Lam.t) =
    match lam with
    | Lconst v ->
        Ident.Hashtbl.replace meta.ident_tbl ~key:ident ~data:(Constant v)
    (* *)
    | Lprim { primitive = Pmakeblock (_, _, Immutable); args = ls; _ } ->
        Ident.Hashtbl.replace meta.ident_tbl ~key:ident
          ~data:(Lam_id_kind.of_lambda_block ls);
        List.iter ~f:(collect meta) ls
    | Lprim { primitive = Psome | Psome_not_nest; args = [ v ]; _ } ->
        Ident.Hashtbl.replace meta.ident_tbl ~key:ident
          ~data:(Normal_optional v);
        collect meta v
    | Lprim
        {
          primitive =
            Praw_js_code { code_info = Exp (Js_function { arity; _ }); _ };
          args = _;
          _;
        } ->
        Ident.Hashtbl.replace meta.ident_tbl ~key:ident
          ~data:
            (FunctionId
               { arity = Lam_arity.info [ arity ] false; lambda = None })
    | Lprim { primitive = Pnull_to_opt; args = [ (Lvar _ as l) ]; _ } ->
        Ident.Hashtbl.replace meta.ident_tbl ~key:ident
          ~data:(OptionalBlock (l, Null))
    | Lprim { primitive = Pundefined_to_opt; args = [ (Lvar _ as l) ]; _ } ->
        Ident.Hashtbl.replace meta.ident_tbl ~key:ident
          ~data:(OptionalBlock (l, Undefined))
    | Lprim { primitive = Pnull_undefined_to_opt; args = [ (Lvar _ as l) ]; _ }
      ->
        Ident.Hashtbl.replace meta.ident_tbl ~key:ident
          ~data:(OptionalBlock (l, Null_undefined))
    | Lglobal_module { id = v; _ } ->
        Lam_util.alias_ident_or_global meta ident v (Module v)
    | Lvar v ->
        (* if Ident.global v then  *)
        Lam_util.alias_ident_or_global meta ident v NA
        (* enven for not subsitution, it still propogate some properties *)
        (* else () *)
    | Lfunction { params; body; _ }
    (* TODO record parameters ident ?, but it will be broken after inlining *)
      ->
        (* TODO could be optimized in one pass?
            -- since collect would iter everywhere,
            so -- it would still iterate internally
        *)
        List.iter
          ~f:(fun p -> Ident.Hashtbl.add meta.ident_tbl ~key:p ~data:Parameter)
          params;
        let arity = Lam_arity_analysis.get_arity meta lam in
        annotate meta rec_flag ident arity lam;
        collect meta body
    | x ->
        collect meta x;
        if Ident.Set.mem ident meta.export_idents then
          annotate meta rec_flag ident (Lam_arity_analysis.get_arity meta x) lam
  and collect meta (lam : Lam.t) =
    match lam with
    | Lconst _ -> ()
    | Lvar _ | Lmutvar _ -> ()
    | Lapply { ap_func = l1; ap_args = ll; _ } ->
        collect meta l1;
        List.iter ~f:(collect meta) ll
    | Lfunction { params; body = l; _ } ->
        (* functor ? *)
        List.iter
          ~f:(fun p -> Ident.Hashtbl.add meta.ident_tbl ~key:p ~data:Parameter)
          params;
        collect meta l
    | Llet (_, ident, arg, body) | Lmutlet (ident, arg, body) ->
        collect_bind meta Lam_non_rec ident arg;
        collect meta body
    | Lletrec (bindings, body) ->
        (match bindings with
        | [ (ident, arg) ] -> collect_bind meta Lam_self_rec ident arg
        | _ ->
            List.iter
              ~f:(fun (ident, arg) -> collect_bind meta Lam_rec ident arg)
              bindings);
        collect meta body
    | Lglobal_module _ -> ()
    | Lprim { args; _ } -> List.iter ~f:(collect meta) args
    | Lswitch (l, { sw_failaction; sw_consts; sw_blocks; _ }) ->
        collect meta l;
        List.iter ~f:(fun (_, x) -> collect meta x) sw_consts;
        List.iter ~f:(fun (_, x) -> collect meta x) sw_blocks;
        Option.iter (collect meta) sw_failaction
    | Lstringswitch (l, sw, d) ->
        collect meta l;
        List.iter ~f:(fun (_, x) -> collect meta x) sw;
        Option.iter (collect meta) d
    | Lstaticraise (_code, ls) -> List.iter ~f:(collect meta) ls
    | Lstaticcatch (l1, (_, _), l2) ->
        collect meta l1;
        collect meta l2
    | Ltrywith (l1, _, l2) ->
        collect meta l1;
        collect meta l2
    | Lifthenelse (l1, l2, l3) ->
        collect meta l1;
        collect meta l2;
        collect meta l3
    | Lsequence (l1, l2) ->
        collect meta l1;
        collect meta l2
    | Lwhile (l1, l2) ->
        collect meta l1;
        collect meta l2
    | Lfor (_, l1, l2, _dir, l3) ->
        collect meta l1;
        collect meta l2;
        collect meta l3
    | Lassign (_v, l) ->
        (* Lalias-bound variables are never assigned, so don't increase
           v's refcollect meta *)
        collect meta l
    | Lsend (_, m, o, ll, _) ->
        collect meta m;
        collect meta o;
        List.iter ~f:(collect meta) ll
    | Lifused (_v, e) -> collect meta e
  in
  fun (meta : Lam_stats.t) (lam : Lam.t) -> collect meta lam
