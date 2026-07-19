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
  let direct_external ~dynamic_import id name arity ~relocatable =
    Lam_call_summary.Direct_external
      { dynamic_import; id; name; arity; relocatable }
  in
  (* Preserve sharing in the lambda graph when building recursive CMJ data. *)
  let memoize cache key f =
    match Ident.Hashtbl.find cache key with
    | value -> value
    | exception Not_found ->
        let value = f () in
        Ident.Hashtbl.replace cache ~key ~data:value;
        value
  in
  let find_external_summary ~dynamic_import ident name ~arity:direct_arity =
    match Lam_compile_env.external_id_is_relative ident with
    | Some is_relative -> (
        match direct_arity with
        | Some arity ->
            direct_external ~dynamic_import ident name arity
              ~relocatable:(not is_relative)
        | None -> Lam_call_summary.Unknown)
    | None -> (
        match
          Lam_compile_env.query_external_id_info ~dynamic_import ident name
        with
        | Some { summary = Js_cmj_format.Leaf { arity; call_summary }; _ } ->
            if not (Lam_call_summary.is_unknown call_summary) then call_summary
            else if not (Lam_arity.first_arity_na arity) then
              direct_external ~dynamic_import ident name arity ~relocatable:true
            else Lam_call_summary.Unknown
        | Some { summary = Js_cmj_format.Block _; _ } ->
            Lam_call_summary.Unknown
        | None -> Lam_call_summary.Unknown)
  in
  let find_ident_summary (meta : Lam_stats.t) ident =
    match Ident.Hashtbl.find meta.ident_tbl ident with
    | FunctionId { call_summary; _ } -> call_summary
    | _ | (exception Not_found) -> Lam_call_summary.Unknown
  in
  let summarize meta lambda =
    let call_summary =
      Lam_call_summary.of_lambda lambda ~find_ident:(find_ident_summary meta)
        ~find_external:find_external_summary
    in
    if Lam_call_summary.is_relocatable call_summary then call_summary
    else Lam_call_summary.Unknown
  in
  let relocatable_call_summary call_summary =
    if Lam_call_summary.is_relocatable call_summary then call_summary
    else Lam_call_summary.Unknown
  in
  let leaf_summary arity call_summary : Js_cmj_format.value_summary =
    Js_cmj_format.Leaf
      { arity; call_summary = relocatable_call_summary call_summary }
  in
  let block_summary fields : Js_cmj_format.value_summary =
    Js_cmj_format.Block fields
  in
  let find_external_value_summary lam =
    match Lam_arity_analysis.external_field_path lam with
    | Some (ident, dynamic_import, name, path) -> (
        match
          Lam_compile_env.query_external_id_info ~dynamic_import ident name
        with
        | Some { summary; _ } ->
            Some (Js_cmj_format.summary_at_path summary path)
        | None -> None)
    | None -> None
  in
  let summary_cache = Ident.Hashtbl.create 32 in
  let rec summary_of_lambda (meta : Lam_stats.t) seen = function
    | (Lam.Lvar v | Lmutvar v) as lam ->
        memoize summary_cache v (fun () ->
            if Ident.Set.mem v seen then Js_cmj_format.unknown_summary
            else
              let seen = Ident.Set.add v seen in
              match Ident.Hashtbl.find meta.ident_tbl v with
              | ImmutableBlock elems ->
                  block_summary
                    (Array.map elems ~f:(summary_of_element meta seen))
              | FunctionId { arity; call_summary; _ } ->
                  leaf_summary arity call_summary
              | FieldAlias lambda -> summary_of_lambda meta seen lambda
              | _ | (exception Not_found) ->
                  leaf_summary
                    (Lam_arity_analysis.get_arity meta lam)
                    (summarize meta lam))
    | Lam.Lprim { primitive = Pmakeblock (_, _, Immutable); args; _ } ->
        block_summary (Array.of_list_map args ~f:(summary_of_lambda meta seen))
    | Lam.Lprim { primitive = Pfield (i, _); args = [ owner ]; _ } as lam -> (
        match find_external_value_summary lam with
        | Some summary -> summary
        | None -> (
            match summary_of_lambda meta seen owner with
            | Js_cmj_format.Block fields -> (
                match fields.(i) with
                | summary -> summary
                | exception _ -> Js_cmj_format.unknown_summary)
            | Js_cmj_format.Leaf _ ->
                leaf_summary
                  (Lam_arity_analysis.get_arity meta lam)
                  (summarize meta lam)))
    | lam ->
        leaf_summary
          (Lam_arity_analysis.get_arity meta lam)
          (summarize meta lam)
  and summary_of_element (meta : Lam_stats.t) seen = function
    | Lam_id_kind.Element.ImmutableBlock elems ->
        block_summary (Array.map elems ~f:(summary_of_element meta seen))
    | SimpleForm lam -> summary_of_lambda meta seen lam
    | Function arity -> leaf_summary arity Lam_call_summary.Unknown
    | NA -> Js_cmj_format.unknown_summary
  in
  fun (meta : Lam_stats.t)
    (export_map : Lam.t Ident.Map.t)
    :
    Js_cmj_format.cmj_value String.Map.t
  ->
    Ident.Hashtbl.clear summary_cache;
    List.fold_left meta.exports ~init:String.Map.empty ~f:(fun acc x ->
        let summary =
          memoize summary_cache x (fun () ->
              match Ident.Hashtbl.find meta.ident_tbl x with
              | FunctionId { arity; call_summary; _ } ->
                  leaf_summary arity call_summary
              | ImmutableBlock elems ->
                  (* FIXME: field name for dumping *)
                  block_summary
                    (Array.map elems
                       ~f:(summary_of_element meta (Ident.Set.singleton x)))
              | _ | (exception Not_found) -> (
                  match Ident.Map.find x export_map with
                  | Lprim { primitive = Pmakeblock (_, _, Immutable); args; _ }
                    ->
                      block_summary
                        (Array.of_list_map args
                           ~f:(summary_of_lambda meta (Ident.Set.singleton x)))
                  | (Lvar _ | Lmutvar _ | Lprim { primitive = Pfield _; _ }) as
                    lambda -> (
                      let summary =
                        summary_of_lambda meta (Ident.Set.singleton x) lambda
                      in
                      match summary with
                      | Js_cmj_format.Block _ -> summary
                      | Js_cmj_format.Leaf _ ->
                          leaf_summary Lam_arity.na (summarize meta lambda))
                  | lambda -> leaf_summary Lam_arity.na (summarize meta lambda)
                  | exception Not_found -> Js_cmj_format.unknown_summary))
        in
        let summary =
          match Ident.Map.find x export_map with
          | lambda -> (
              match summary with
              | Js_cmj_format.Leaf { arity; _ } ->
                  leaf_summary arity (summarize meta lambda)
              | Js_cmj_format.Block _ -> summary)
          | exception Not_found -> summary
        in
        let persistent_closed_lambda =
          match Ident.Map.find x export_map with
          | Lconst
              ( Const_js_null | Const_js_undefined _ | Const_js_true
              | Const_js_false ) as lambda ->
              Some (lambda, Ident.Map.empty)
          | exception Not_found -> None
          | _ when not !Js_config.cross_module_inline -> None
          | lambda -> (
              let lambda = Lam_pass_remove_alias.simplify_alias meta lambda in
              if not (Lam_compile_env.lambda_is_relocatable lambda) then None
              else
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
                        if
                          Lam_closure.is_closed
                            lambda (* TODO: seriealize more*)
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
                            (Pp.textf "%s recorded for inlining @."
                               (Ident.name x));
                          Some (lambda, param_map lambda))
                        else None))
        in
        match (summary, persistent_closed_lambda) with
        | ( Js_cmj_format.Leaf { arity = Arity_na; call_summary },
            (None | Some (Lconst Const_module_alias, _)) )
          when Lam_call_summary.is_unknown call_summary ->
            acc
        | Js_cmj_format.Block [||], None -> acc
        | _, _ ->
            String.Map.add acc ~key:(Ident.name x)
              ~data:{ Js_cmj_format.summary; persistent_closed_lambda })

(* ATTENTION: all runtime modules, if it is not hard required,
   it should be okay to not reference it *)
let get_dependent_module_effect (maybe_pure : string option)
    (external_ids : Lam_module_ident.t list) =
  match maybe_pure with
  | None -> (
      match
        List.find external_ids ~f:(fun id ->
            not (Lam_compile_env.is_pure_module id))
      with
      | non_pure_module -> Some (Lam_module_ident.name non_pure_module)
      | exception Not_found -> None)
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
let export_to_cmj ~case meta ~effect_ export_map
    ~(delayed_program : J.deps_program) =
  let values = values_of_export meta export_map in

  Js_cmj_format.make ~values ~effect_
    ~package_spec:(Js_packages_state.get_packages_info_for_cmj ())
    ~case ~delayed_program
(* FIXME: make sure [-o] would not change its case
   add test for ns/non-ns
*)
