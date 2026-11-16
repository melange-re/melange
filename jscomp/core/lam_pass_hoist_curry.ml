(* Copyright (C) 2026- Authors of Melange
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

type call_position = Outside_loop | Inside_loop

type usage =
  | Unused
  | Called of { arity : int; call_position : call_position }
  | Escapes

let hoist_curry lam =
  let normalizable_params ~self_name (params : Ident.t list) (body : Lam.t) =
    let exception Self_escaped in
    let usages = Ident.Hashtbl.create 7 in
    List.iter params ~f:(fun param ->
        Ident.Hashtbl.replace usages ~key:param ~data:Unused);
    let is_self_name id =
      match self_name with Some name -> Ident.same id name | None -> false
    in
    let outermost =
      match self_name with Some _ -> Inside_loop | None -> Outside_loop
    in
    let record_usage id (usage : usage) =
      match (Ident.Hashtbl.find_opt usages id, usage) with
      | (None | Some Escapes), _ -> ()
      | Some Unused, _ -> Ident.Hashtbl.replace usages ~key:id ~data:usage
      | Some (Called { arity; call_position }), Called c when c.arity = arity
        -> (
          match call_position with
          | Inside_loop -> ()
          | Outside_loop -> Ident.Hashtbl.replace usages ~key:id ~data:usage)
      | Some (Called _), (Called _ | Escapes | Unused) ->
          Ident.Hashtbl.replace usages ~key:id ~data:Escapes
    in
    let rec visit ~call_position (lam : Lam.t) =
      match lam with
      | Lvar id ->
          if is_self_name id then raise_notrace Self_escaped;
          record_usage id Escapes
      | Lapply { ap_func = Lvar id; ap_args; ap_info = { ap_status; _ } }
        when Ident.Hashtbl.mem usages id ->
          (match ap_status with
          | App_na ->
              let arity = List.length ap_args in
              record_usage id
                (if 1 <= arity && arity <= Js_runtime_modules.curry_max_arity
                 then Called { arity; call_position }
                 else Escapes)
          | App_infer_full -> ()
          | App_uncurry -> record_usage id Escapes);
          List.iter ap_args ~f:(visit ~call_position)
      | Lapply { ap_func = Lvar id; ap_args; _ }
        when is_self_name id && List.same_length ap_args params ->
          List.iter2 ap_args params ~f:(fun (arg : Lam.t) param ->
              match arg with
              | Lvar arg when Ident.same arg param -> ()
              | arg ->
                  record_usage param Escapes;
                  visit ~call_position arg)
      | Lwhile _ -> Lam_iter.iter lam ~f:(visit ~call_position:Inside_loop)
      | Lfor (_, start, finish, _, body) ->
          visit ~call_position start;
          visit ~call_position finish;
          visit ~call_position:Inside_loop body
      | Lletrec (bindings, body) ->
          let group_ids = Ident.Set.of_list (List.map ~f:fst bindings) in
          if
            List.exists bindings ~f:(fun (_, binding) ->
                Lam_hit.hit_variables group_ids binding)
          then (
            List.iter bindings ~f:(fun (_, (binding : Lam.t)) ->
                match binding with
                | Lfunction { body; _ } -> visit ~call_position:Inside_loop body
                | binding -> visit ~call_position binding);
            visit ~call_position body)
          else Lam_iter.iter lam ~f:(visit ~call_position)
      | Lfunction _ -> Lam_iter.iter lam ~f:(visit ~call_position:outermost)
      | _ -> Lam_iter.iter lam ~f:(visit ~call_position)
    in
    match visit ~call_position:outermost body with
    | exception Self_escaped -> Ident.Map.empty
    | () ->
        List.fold_right params ~init:Ident.Map.empty ~f:(fun param param_map ->
            match Ident.Hashtbl.find usages param with
            | Called { arity; call_position = Inside_loop } ->
                Ident.Map.add param_map ~key:param
                  ~data:(arity, Ident.rename param)
            | Called { call_position = Outside_loop; _ } | Unused | Escapes ->
                param_map)
  in
  let function_with_normalized_params ~param_map ~attr ~arity params body =
    Lam.function_ ~attr ~arity ~params
      ~body:
        (List.fold_right params ~init:body ~f:(fun param body ->
             match Ident.Map.find_opt param param_map with
             | None -> body
             | Some (arity, replacement) ->
                 Lam.let_ StrictOpt replacement
                   (Lam_eta_conversion.unsafe_adjust_to_arity ~loc:Location.none
                      ~to_:arity (Lam.var param))
                   body))
  in
  let rec rewrite ~param_map ~recursive_call (lam : Lam.t) : Lam.t =
    match lam with
    | Lapply { ap_func = Lvar id; ap_args; ap_info } -> (
        match (ap_info.ap_status, Ident.Map.find_opt id param_map) with
        | App_na, Some (_, replacement) ->
            Lam.apply (Lam.var replacement)
              (List.map ~f:(rewrite ~param_map ~recursive_call) ap_args)
              { ap_info with ap_status = App_infer_full }
        | App_na, None | (App_infer_full | App_uncurry), _ -> (
            match recursive_call with
            | Some (name, worker, params) when Ident.same id name ->
                Lam.apply (Lam.var worker)
                  (List.fold_right2 params ap_args ~init:[]
                     ~f:(fun param arg args ->
                       if Ident.Map.mem param param_map then args
                       else rewrite ~param_map ~recursive_call arg :: args))
                  { ap_info with ap_status = App_infer_full }
            | Some _ | None ->
                Lam.inner_map lam (rewrite ~param_map ~recursive_call)))
    | _ -> Lam.inner_map lam (rewrite ~param_map ~recursive_call)
  in
  let rec transform (lam : Lam.t) : Lam.t =
    match lam with
    | Lletrec
        ([ (name, (Lfunction { params; body; attr; arity } as binding)) ], rest)
      ->
        let binding =
          match params with
          | _ :: _ when Lam_hit.hit_variable name body ->
              let param_map =
                normalizable_params ~self_name:(Some name) params body
              in
              if Ident.Map.is_empty param_map then
                Lam.inner_map binding transform
              else
                let kept =
                  List.filter params ~f:(fun param ->
                      not (Ident.Map.mem param param_map))
                in
                let worker = Ident.rename name in
                let worker_subst, worker_params =
                  List.fold_left_map kept ~init:Ident.Map.empty
                    ~f:(fun subst param ->
                      let worker_param = Ident.rename param in
                      ( Ident.Map.add subst ~key:param
                          ~data:(Lam.var worker_param),
                        worker_param ))
                in
                let worker_body =
                  rewrite ~param_map
                    ~recursive_call:(Some (name, worker, params))
                    (Lam_subst.subst worker_subst body)
                in
                function_with_normalized_params ~param_map ~attr ~arity params
                  (Lam.letrec
                     [
                       ( worker,
                         Lam.function_ ~attr
                           ~arity:(List.length worker_params)
                           ~params:worker_params ~body:(transform worker_body)
                       );
                     ]
                     (Lam.apply (Lam.var worker) (List.map ~f:Lam.var kept)
                        {
                          ap_loc = Location.none;
                          ap_inlined = Default_inline;
                          ap_status = App_infer_full;
                        }))
          | _ -> transform binding
        in
        Lam.letrec [ (name, binding) ] (transform rest)
    | Lfunction { params = _ :: _ as params; body; attr; arity } ->
        let param_map = normalizable_params ~self_name:None params body in
        if Ident.Map.is_empty param_map then Lam.inner_map lam transform
        else
          function_with_normalized_params ~param_map ~attr ~arity params
            (transform (rewrite ~param_map ~recursive_call:None body))
    | _ -> Lam.inner_map lam transform
  in
  transform lam
