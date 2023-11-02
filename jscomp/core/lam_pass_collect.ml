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
  Ident.Hash.add meta.ident_tbl k
    (FunctionId { arity; lambda = Some (lambda, rec_flag) })

(* see #3609
   we have to update since bounded function lambda
   may contain staled unbounded varaibles
*)
(* match Ident.Hash.find_opt  meta.ident_tbl k  with
   | None -> (* FIXME: need do a sanity check of arity is NA or Determin(_,[],_) *)

   |  Some (FunctionId old)  ->
     Ident.Hash.add meta.ident_tbl k
       (FunctionId {arity; lambda = Some (lambda, rec_flag) })
     (* old.arity <- arity   *)
     (* due to we keep refining arity analysis after each round*)
   | _ -> assert false *)
(* TODO -- avoid exception *)

(* it only make senses recording arities for
    function definition,
    alias propgation - and toplevel identifiers, this needs to be exported
*)
let collect_info (meta : Lam_stats.t) (lam : Lam.t) =
  let rec collect_bind rec_flag (ident : Ident.t) (lam : Lam.t) =
    match lam with
    | Lconst v -> Ident.Hash.replace meta.ident_tbl ident (Constant v)
    (* *)
    | Lprim { primitive = Pmakeblock (_, _, Immutable); args = ls; _ } ->
        Ident.Hash.replace meta.ident_tbl ident
          (Lam_util.kind_of_lambda_block ls);
        List.iter ~f:collect ls
    | Lprim { primitive = Psome | Psome_not_nest; args = [ v ]; _ } ->
        Ident.Hash.replace meta.ident_tbl ident (Normal_optional v);
        collect v
    | Lprim
        {
          primitive =
            Praw_js_code { code_info = Exp (Js_function { arity; _ }); _ };
          args = _;
          _;
        } ->
        Ident.Hash.replace meta.ident_tbl ident
          (FunctionId { arity = Lam_arity.info [ arity ] false; lambda = None })
    | Lprim { primitive = Pnull_to_opt; args = [ (Lvar _ as l) ]; _ } ->
        Ident.Hash.replace meta.ident_tbl ident (OptionalBlock (l, Null))
    | Lprim { primitive = Pundefined_to_opt; args = [ (Lvar _ as l) ]; _ } ->
        Ident.Hash.replace meta.ident_tbl ident (OptionalBlock (l, Undefined))
    | Lprim { primitive = Pnull_undefined_to_opt; args = [ (Lvar _ as l) ]; _ }
      ->
        Ident.Hash.replace meta.ident_tbl ident
          (OptionalBlock (l, Null_undefined))
    | Lglobal_module v -> Lam_util.alias_ident_or_global meta ident v (Module v)
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
        List.iter ~f:(fun p -> Ident.Hash.add meta.ident_tbl p Parameter) params;
        let arity = Lam_arity_analysis.get_arity meta lam in
        annotate meta rec_flag ident arity lam;
        collect body
    | x ->
        collect x;
        if Ident.Set.mem meta.export_idents ident then
          annotate meta rec_flag ident (Lam_arity_analysis.get_arity meta x) lam
  and collect (lam : Lam.t) =
    match lam with
    | Lconst _ -> ()
    | Lvar _ | Lmutvar _ -> ()
    | Lapply { ap_func = l1; ap_args = ll; _ } ->
        collect l1;
        List.iter ~f:collect ll
    | Lfunction { params; body = l; _ } ->
        (* functor ? *)
        List.iter ~f:(fun p -> Ident.Hash.add meta.ident_tbl p Parameter) params;
        collect l
    | Llet (_, ident, arg, body) | Lmutlet (ident, arg, body) ->
        collect_bind Lam_non_rec ident arg;
        collect body
    | Lletrec (bindings, body) ->
        (match bindings with
        | [ (ident, arg) ] -> collect_bind Lam_self_rec ident arg
        | _ ->
            List.iter
              ~f:(fun (ident, arg) -> collect_bind Lam_rec ident arg)
              bindings);
        collect body
    | Lglobal_module _ -> ()
    | Lprim { args; _ } -> List.iter ~f:collect args
    | Lswitch (l, { sw_failaction; sw_consts; sw_blocks; _ }) ->
        collect l;
        List.iter ~f:(fun (_, x) -> collect x) sw_consts;
        List.iter ~f:(fun (_, x) -> collect x) sw_blocks;
        Option.iter collect sw_failaction
    | Lstringswitch (l, sw, d) ->
        collect l;
        List.iter ~f:(fun (_, x) -> collect x) sw;
        Option.iter collect d
    | Lstaticraise (_code, ls) -> List.iter ~f:collect ls
    | Lstaticcatch (l1, (_, _), l2) ->
        collect l1;
        collect l2
    | Ltrywith (l1, _, l2) ->
        collect l1;
        collect l2
    | Lifthenelse (l1, l2, l3) ->
        collect l1;
        collect l2;
        collect l3
    | Lsequence (l1, l2) ->
        collect l1;
        collect l2
    | Lwhile (l1, l2) ->
        collect l1;
        collect l2
    | Lfor (_, l1, l2, _dir, l3) ->
        collect l1;
        collect l2;
        collect l3
    | Lassign (_v, l) ->
        (* Lalias-bound variables are never assigned, so don't increase
           v's refcollect *)
        collect l
    | Lsend (_, m, o, ll, _) ->
        collect m;
        collect o;
        List.iter ~f:collect ll
    | Lifused (_v, e) -> collect e
  in
  collect lam
