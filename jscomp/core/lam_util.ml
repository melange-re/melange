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
         *)
    ->
      arg (* TODO: optimize here -- it's safe to do substitution here *)
  | _, _, Lprim { primitive; args = [ Lvar w ]; loc; _ }
    when Ident.same w param
         && (function Lam_primitive.Pmakeblock _ -> false | _ -> true)
              primitive
         (* don't inline inside a block *) ->
      Lam.prim ~primitive ~args:[ arg ] ~loc
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
          into a block *)
      Lam.let_ StrictOpt param arg l
  (* Not the case, the block itself can have side effects
      we can apply [no_side_effects] pass
      | Some Strict, Lprim(Pmakeblock (_,_,Immutable),_) ->
        Llet(StrictOpt, param, arg, l) *)
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
      match Ident.Hashtbl.find meta.ident_tbl v with
      | exception Not_found -> ()
      | ident_info -> Ident.Hashtbl.add meta.ident_tbl ~key:k ~data:ident_info)
  | ident_info -> Ident.Hashtbl.add meta.ident_tbl ~key:k ~data:ident_info

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
