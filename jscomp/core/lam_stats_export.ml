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

(* we should exclude meaninglist names and do the convert as well *)

(* let meaningless_names  = ["*opt*"; "param";] *)

let values_of_export =
  let param_map = function
    | Lam.Lfunction { params; body; _ } ->
        let _is_closed, param_map =
          Lam_closure.is_closed_with_map Ident.Set.empty params body
        in
        param_map
    | _ -> Ident.Map.empty
  in
  fun (meta : Lam_stats.t)
    (export_map : Lam.t Ident.Map.t)
    :
    Js_cmj_format.cmj_value String.Map.t
  ->
    List.fold_left
      ~f:(fun acc x ->
        let arity : Js_cmj_format.arity =
          match Ident.Hashtbl.find_opt meta.ident_tbl x with
          | Some (FunctionId { arity; _ }) -> Single arity
          | Some (ImmutableBlock elems) ->
              (* FIXME: field name for dumping*)
              Submodule
                (Array.map
                   ~f:(fun (x : Lam_id_kind.element) ->
                     match x with
                     | NA -> Lam_arity.na
                     | SimpleForm lam -> Lam_arity_analysis.get_arity meta lam)
                   elems)
          | Some _ | None -> (
              match Ident.Map.find_opt x export_map with
              | Some
                  (Lprim { primitive = Pmakeblock (_, _, Immutable); args; _ })
                ->
                  Submodule
                    (Array.of_list_map args (fun lam ->
                         Lam_arity_analysis.get_arity meta lam))
              | Some _ | None -> Js_cmj_format.single_na)
        in
        let persistent_closed_lambda : (_ * _) option =
          match Ident.Map.find_opt x export_map with
          | Some
              (Lconst
                 ( Const_js_null | Const_js_undefined | Const_js_true
                 | Const_js_false ) as lambda) ->
              Some (lambda, Ident.Map.empty)
          | None -> None
          | Some _ when not !Js_config.cross_module_inline -> None
          | Some lambda -> (
              match
                Lam_analysis.safe_to_inline lambda
                (* when inlining a non function, we have to be very careful,
                 only truly immutable values can be inlined *)
              with
              | false -> None
              | true -> (
                  match lambda with
                  | Lfunction { attr = { inline = Always_inline; _ }; _ }
                  (* FIXME: is_closed lambda is too restrictive
                     It precludes use cases
                     - inline forEach but not forEachU *)
                  | Lfunction { attr = { is_a_functor = true; _ }; _ } ->
                      if Lam_closure.is_closed lambda (* TODO: seriealize more*)
                      then Some (lambda, param_map lambda)
                      else None
                  | _ ->
                      let lam_size = Lam_analysis.size lambda in
                      (* TODO:
                         1. global need re-assocate when do the beta reduction
                         2. [lambda_exports] is not precise *)
                      let free_variables =
                        Lam_closure.free_variables Ident.Set.empty
                          Ident.Map.empty lambda
                      in
                      if
                        lam_size < Lam_analysis.small_inline_size
                        && Ident.Map.is_empty free_variables
                      then (
                        Log.warn ~loc:(Loc.of_pos __POS__)
                          (Pp.textf "%s recorded for inlining @." (Ident.name x));
                        Some (lambda, param_map lambda))
                      else None))
        in
        match (arity, persistent_closed_lambda) with
        | Single Arity_na, (None | Some (Lconst Const_module_alias, _)) -> acc
        | Submodule [||], None -> acc
        | _ ->
            let cmj_value : Js_cmj_format.cmj_value =
              { arity; persistent_closed_lambda }
            in
            String.Map.add (Ident.name x) cmj_value acc)
      ~init:String.Map.empty meta.exports

(* ATTENTION: all runtime modules, if it is not hard required,
   it should be okay to not reference it *)
let get_dependent_module_effect (maybe_pure : string option)
    (external_ids : Lam_module_ident.t list) =
  match maybe_pure with
  | None ->
      let non_pure_module =
        List.find_opt
          ~f:(fun id -> not (Lam_compile_env.is_pure_module id))
          external_ids
      in
      Option.map (fun x -> Lam_module_ident.name x) non_pure_module
  | Some _ -> maybe_pure

(* Note that
   [lambda_exports] is
   lambda expression to be exported
   for the js backend, we compile to js
   for the inliner, we try to serialize it --
   relies on other optimizations to make this happen
   {[
     exports.Make = function () {.....}
   ]}
   TODO: check that we don't do this in browser environment
*)
let export_to_cmj ~case meta ~effect_ export_map =
  let values = values_of_export meta export_map in

  Js_cmj_format.make ~values ~effect_
    ~package_spec:(Js_packages_state.get_packages_info_for_cmj ())
    ~case
(* FIXME: make sure [-o] would not change its case
   add test for ns/non-ns
*)
