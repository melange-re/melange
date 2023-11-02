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

(*
let add_required_modules ( x : Ident.t list) (meta : Lam_stats.t) =
  let meta_require_modules = meta.required_modules in
  List.iter (fun x -> add meta_require_modules (Lam_module_ident.of_ml x)) x
*)

(*
    It's impossible to have a case like below:
   {[
     (let export_f = ... in export_f)
   ]}
    Even so, it's still correct
*)
let refine_let ~kind param (arg : Lam.t) (l : Lam.t) : Lam.t =
  match ((kind : Lam_group.let_kind), arg, l) with
  | _, _, Lvar w
    when Ident.same w param
         (* let k = xx in k
            there is no [rec] so [k] would not appear in [xx]
         *) ->
      arg (* TODO: optimize here -- it's safe to do substitution here *)
  | _, _, Lprim { primitive; args = [ Lvar w ]; loc; _ }
    when Ident.same w param
         && (function Lam_primitive.Pmakeblock _ -> false | _ -> true)
              primitive
         (* don't inline inside a block *) ->
      Lam.prim ~primitive ~args:[ arg ] loc
  (* we can not do this substitution when capttured *)
  (* | _, Lvar _, _ -> (\* let u = h in xxx*\) *)
  (*     (\* assert false *\) *)
  (*     Ext_log.err "@[substitution >> @]@."; *)
  (*     let v= subst_lambda (Map_ident.singleton param arg ) l in *)
  (*     Ext_log.err "@[substitution << @]@."; *)
  (* v *)
  | _, _, Lapply { ap_func = fn; ap_args = [ Lvar w ]; ap_info }
    when Ident.same w param && not (Lam_hit.hit_variable param fn) ->
      (* does not work for multiple args since
          evaluation order unspecified, does not apply
          for [js] in general, since the scope of js ir is loosen

          here we remove the definition of [param]
          {[ let k = v in (body) k
          ]}
          #1667 make sure body does not hit k
      *)
      Lam.apply fn [ arg ] ap_info
  | ( (Strict | StrictOpt),
      ( Lvar _ | Lconst _
      | Lprim
          {
            primitive = Pfield (_, Fld_module _);
            args = [ (Lglobal_module _ | Lvar _) ];
            _;
          } ),
      _ ) ->
      (* (match arg with  *)
      (* | Lconst _ ->  *)
      (*     Ext_log.err "@[%a %s@]@."  *)
      (*       Ident.print param (string_of_lambda arg) *)
      (* | _ -> ()); *)
      (* No side effect and does not depend on store,
          since function evaluation is always delayed
      *)
      Lam.let_ Alias param arg l
  | (Strict | StrictOpt), Lfunction _, _ ->
      (*It can be promoted to [Alias], however,
          we don't want to do this, since we don't want the
          function to be inlined to a block, for example
        {[
          let f = fun _ -> 1 in
          [0, f]
        ]}
          TODO: punish inliner to inline functions
          into a block
      *)
      Lam.let_ StrictOpt param arg l
  (* Not the case, the block itself can have side effects
      we can apply [no_side_effects] pass
      | Some Strict, Lprim(Pmakeblock (_,_,Immutable),_) ->
        Llet(StrictOpt, param, arg, l)
  *)
  | Strict, _, _ when Lam_analysis.no_side_effects arg ->
      Lam.let_ StrictOpt param arg l
  | Variable, _, _ -> Lam.mutlet param arg l
  | kind, _, _ -> Lam.let_ (Lam_group.to_lam_kind kind) param arg l
(* | None , _, _ ->
   Lam.let_ Strict param arg  l *)

let alias_ident_or_global (meta : Lam_stats.t) (k : Ident.t) (v : Ident.t)
    (v_kind : Lam_id_kind.t) =
  (* treat rec as Strict, k is assigned to v
      {[ let k = v ]}
  *)
  match v_kind with
  | NA -> (
      match Ident.Hash.find_opt meta.ident_tbl v with
      | None -> ()
      | Some ident_info -> Ident.Hash.add meta.ident_tbl k ident_info)
  | ident_info -> Ident.Hash.add meta.ident_tbl k ident_info

(* share -- it is safe to share most properties,
    for arity, we might be careful, only [Alias] can share,
    since two values have same type, can have different arities
    TODO: check with reference pass, it might break
    since it will create new identifier, we can avoid such issue??

    actually arity is a dynamic property, for a reference, it can
    be changed across
    we should treat
    reference specially. or maybe we should track any
    mutable reference
*)

(* How we destruct the immutable block
   depend on the block name itself,
   good hints to do aggressive destructing
   1. the variable is not exported
      like [matched] -- these are blocks constructed temporary
   2. how the variable is used
      if it is guarateed to be
   - non export
   - and non escaped (there is no place it is used as a whole)
      then we can always destruct it
      if some fields are used in multiple places, we can create
      a temporary field

   3. It would be nice that when the block is mutable, its
       mutable fields are explicit, since wen can not inline an mutable block access
*)

let element_of_lambda (lam : Lam.t) : Lam_id_kind.element =
  match lam with
  | Lvar _ | Lconst _
  | Lprim
      {
        primitive = Pfield (_, Fld_module _);
        args = [ (Lglobal_module _ | Lvar _) ];
        _;
      } ->
      SimpleForm lam
  (* | Lfunction _  *)
  | _ -> NA

let kind_of_lambda_block (xs : Lam.t list) : Lam_id_kind.t =
  ImmutableBlock (Array.of_list_map xs (fun x -> element_of_lambda x))

let field_flatten_get lam v i info (tbl : Lam_id_kind.t Ident.Hash.t) : Lam.t =
  match Ident.Hash.find_opt tbl v with
  | Some (Module g) ->
      Lam.prim
        ~primitive:(Pfield (i, info))
        ~args:[ Lam.global_module g ]
        Location.none
  | Some (ImmutableBlock arr) -> (
      match arr.(i) with
      | NA -> lam ()
      | SimpleForm l -> l
      | exception _ -> lam ())
  | Some (Constant (Const_block (_, _, ls))) -> (
      match List.nth_opt ls i with None -> lam () | Some x -> Lam.const x)
  | Some _ | None -> lam ()

(* TODO: check that if label belongs to a different
    namesape
*)
let count = ref 0

let generate_label ?(name = "") () =
  incr count;
  Printf.sprintf "%s_tailcall_%04d" name !count

let is_function (lam : Lam.t) =
  match lam with Lfunction _ -> true | _ -> false

let not_function (lam : Lam.t) =
  match lam with Lfunction _ -> false | _ -> true
(*
let is_var (lam : Lam.t) id =
  match lam with
  | Lvar id0 -> Ident.same id0 id
  | _ -> false *)

(* TODO: we need create
   1. a smart [let] combinator, reusable beta-reduction
   2. [lapply fn args info]
   here [fn] should get the last tail
   for example
   {[
     lapply (let a = 3 in let b = 4 in fun x y -> x + y) 2 3
   ]}
*)
