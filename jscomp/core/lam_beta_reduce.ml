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

module Beta_reduce = struct
  (* Principle: in ocaml, the apply order is not specified.
   Rules:
   1. each argument it is only used once, (avoid eval duplication)
   2. it's actually used, if not (Lsequence)
   3. no nested  compuation, other wise the evaluation order is tricky (make
      sure eval order is correct) *)

  type value = { mutable used : bool; lambda : Lam.t }

  let param_hash : _ Ident.Hashtbl.t = Ident.Hashtbl.create 20

  (* optimize cases like
   (fun f (a,b){ g (a,b,1)} (e0, e1))
   cases like
   (fun f (a,b){ g (a,b,a)} (e0, e1)) needs avoids double eval

     Note in a very special case we can avoid any allocation
    {[
      when Ext_list.for_all2_no_exn
          (fun p a ->
             match (a : Lam.t) with
             | Lvar a -> Ident.same p a
             | _ -> false ) params args'
    ]} *)
  let simple_beta_reduce params body args =
    let exception Not_simple_apply in
    let find_param_exn v opt =
      match Ident.Hashtbl.find param_hash v with
      | exp ->
          if exp.used then raise_notrace Not_simple_apply else exp.used <- true;
          exp.lambda
      | exception Not_found -> opt
    in
    let rec aux_exn acc (us : Lam.t list) =
      match us with
      | [] -> List.rev acc
      | (Lvar x as a) :: rest -> aux_exn (find_param_exn x a :: acc) rest
      | (Lconst _ as u) :: rest -> aux_exn (u :: acc) rest
      | _ :: _ -> raise_notrace Not_simple_apply
    in
    match (body : Lam.t) with
    | Lprim { primitive; args = ap_args; loc = ap_loc }
    (* There is no lambda in primitive *) -> (
        (* catch a special case of primitives *)
        let () =
          List.iter2
            ~f:(fun p a ->
              Ident.Hashtbl.add param_hash ~key:p
                ~data:{ lambda = a; used = false })
            params args
        in
        try
          let new_args = aux_exn [] ap_args in
          let result =
            Ident.Hashtbl.fold param_hash
              ~init:(Lam.prim ~primitive ~args:new_args ~loc:ap_loc)
              ~f:(fun ~key:_param ~data:stats acc ->
                let { lambda; used } = stats in
                if not used then Lam.seq lambda acc else acc)
          in
          Ident.Hashtbl.clear param_hash;
          Some result
        with Not_simple_apply ->
          Ident.Hashtbl.clear param_hash;
          None)
    | Lapply
        {
          ap_func =
            ( Lvar _
            | Lprim { primitive = Pfield _; args = [ Lglobal_module _ ]; _ } )
            as f;
          ap_args;
          ap_info;
        } -> (
        let () =
          List.iter2
            ~f:(fun p a ->
              Ident.Hashtbl.add param_hash ~key:p
                ~data:{ lambda = a; used = false })
            params args
        in
        (*since we adde each param only once,
        iff it is removed once, no exception,
        if it is removed twice there will be exception.
        if it is never removed, we have it as rest keys
      *)
        try
          let new_args = aux_exn [] ap_args in
          let f =
            match f with Lvar fn_name -> find_param_exn fn_name f | _ -> f
          in
          let result =
            Ident.Hashtbl.fold param_hash ~init:(Lam.apply f new_args ap_info)
              ~f:(fun ~key:_param ~data:stat acc ->
                let { lambda; used } = stat in
                if not used then Lam.seq lambda acc else acc)
          in
          Ident.Hashtbl.clear param_hash;
          Some result
        with Not_simple_apply ->
          Ident.Hashtbl.clear param_hash;
          None)
    | _ -> None
end

let of_list2 ks vs = List.combine ks vs |> List.to_seq |> Ident.Hashtbl.of_seq

(*
     A naive beta reduce would break the invariants of the optmization.


     The sane but slowest  way:
       when we do a beta reduction, we need rename all variables inlcuding
       let-bound ones

     A conservative one:
       - for internal one
         rename params and let bound variables
       - for external one (seriaized)
         if it's enclosed environment should be good enough
         so far, we only inline enclosed lambdas
     TODO: rename

    Optimizations:
    {[
      (fun x y -> ...     ) 100 3
    ]}
    we can bound [x] to [100] in a single step
*)
let propagate_beta_reduce (meta : Lam_stats.t) (params : Ident.t list)
    (body : Lam.t) (args : Lam.t list) =
  match Beta_reduce.simple_beta_reduce params body args with
  | Some x -> x
  | None ->
      let rest_bindings, rev_new_params =
        List.fold_left2
          ~f:(fun (rest_bindings, acc) old_param (arg : Lam.t) ->
            match arg with
            | Lconst _ | Lvar _ -> (rest_bindings, arg :: acc)
            | _ ->
                let p = Ident.rename old_param in
                ((p, arg) :: rest_bindings, Lam.var p :: acc))
          ~init:([], []) params args
      in
      let new_body =
        Lam_bounded_vars.rewrite
          (of_list2 (List.rev params) rev_new_params)
          body
      in
      List.fold_right
        ~f:(fun (param, arg) l ->
          (match arg with
          | Lam.Lprim { primitive = Pmakeblock (_, _, Immutable); args; _ } ->
              Ident.Hashtbl.replace meta.ident_tbl ~key:param
                ~data:(Lam_id_kind.of_lambda_block args)
          | Lprim { primitive = Psome | Psome_not_nest; args = [ v ]; _ } ->
              Ident.Hashtbl.replace meta.ident_tbl ~key:param
                ~data:(Normal_optional v)
          | _ -> ());
          Lam_util.refine_let ~kind:Strict param arg l)
        rest_bindings ~init:new_body

let propagate_beta_reduce_with_map (meta : Lam_stats.t)
    (map : Lam_var_stats.stats Ident.Map.t) params body args =
  match Beta_reduce.simple_beta_reduce params body args with
  | Some x -> x
  | None ->
      let rest_bindings, rev_new_params =
        List.fold_left2
          ~f:(fun (rest_bindings, acc) old_param arg ->
            match arg with
            | Lam.Lconst _ | Lvar _ -> (rest_bindings, arg :: acc)
            | Lglobal_module _ ->
                let p = Ident.rename old_param in
                ((p, arg) :: rest_bindings, Lam.var p :: acc)
            | _ ->
                if Lam_analysis.no_side_effects arg then
                  match Ident.Map.find old_param map with
                  | stat ->
                      if Lam_var_stats.top_and_used_zero_or_one stat then
                        (rest_bindings, arg :: acc)
                      else
                        let p = Ident.rename old_param in
                        ((p, arg) :: rest_bindings, Lam.var p :: acc)
                else
                  let p = Ident.rename old_param in
                  ((p, arg) :: rest_bindings, Lam.var p :: acc))
          ~init:([], []) params args
      in
      let new_body =
        Lam_bounded_vars.rewrite
          (of_list2 (List.rev params) rev_new_params)
          body
      in
      List.fold_right
        ~f:(fun (param, (arg : Lam.t)) l ->
          (match arg with
          | Lprim { primitive = Pmakeblock (_, _, Immutable); args; _ } ->
              Ident.Hashtbl.replace meta.ident_tbl ~key:param
                ~data:(Lam_id_kind.of_lambda_block args)
          | Lprim { primitive = Psome | Psome_not_nest; args = [ v ]; _ } ->
              Ident.Hashtbl.replace meta.ident_tbl ~key:param
                ~data:(Normal_optional v)
          | _ -> ());
          Lam_util.refine_let ~kind:Strict param arg l)
        rest_bindings ~init:new_body

let no_names_beta_reduce params body args =
  match Beta_reduce.simple_beta_reduce params body args with
  | Some x -> x
  | None ->
      List.fold_left2
        ~f:(fun l param arg -> Lam_util.refine_let ~kind:Strict param arg l)
        ~init:body params args
