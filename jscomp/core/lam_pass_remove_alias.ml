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

type outcome = Eval_false | Eval_true | Eval_unknown

let id_is_for_sure_true_in_boolean (tbl : Lam_stats.ident_tbl) id =
  match Ident.Hash.find_opt tbl id with
  | Some (ImmutableBlock _)
  | Some (Normal_optional _)
  | Some (MutableBlock _)
  | Some (Constant (Const_block _ | Const_js_true)) ->
      Eval_true
  | Some (Constant (Const_int { i; _ })) ->
      if i = 0l then Eval_false else Eval_true
  | Some (Constant (Const_js_false | Const_js_null | Const_js_undefined)) ->
      Eval_false
  | Some
      ( Constant _ | Module _ | FunctionId _ | Exception | Parameter | NA
      | OptionalBlock (_, (Undefined | Null | Null_undefined)) )
  | None ->
      Eval_unknown

let simplify_alias (meta : Lam_stats.t) (lam : Lam.t) : Lam.t =
  let rec simpl (lam : Lam.t) : Lam.t =
    match lam with
    | Lvar _ | Lmutvar _ -> lam
    | Lprim { primitive = Pfield (i, info) as primitive; args = [ arg ]; loc }
      -> (
        (* ATTENTION:
           Main use case, we should detect inline all immutable block .. *)
        match simpl arg with
        | (Lvar v | Lmutvar v) as l ->
            Lam_util.field_flatten_get
              (fun _ -> Lam.prim ~primitive ~args:[ l ] loc)
              v i info meta.ident_tbl
        | l -> Lam.prim ~primitive ~args:[ l ] loc)
    | Lprim
        {
          primitive = (Pval_from_option | Pval_from_option_not_nest) as p;
          args = [ (Lvar v as lvar) ];
          _;
        } as x -> (
        match Ident.Hash.find_opt meta.ident_tbl v with
        | Some (OptionalBlock (l, _)) -> l
        | _ -> if p = Pval_from_option_not_nest then lvar else x)
    | Lglobal_module _ -> lam
    | Lprim { primitive; args; loc } ->
        Lam.prim ~primitive ~args:(List.map ~f:simpl args) loc
    | Lifthenelse
        ( (Lprim { primitive = Pis_not_none; args = [ Lvar id ]; _ } as l1),
          l2,
          l3 ) -> (
        match Ident.Hash.find_opt meta.ident_tbl id with
        | Some (ImmutableBlock _ | MutableBlock _ | Normal_optional _) ->
            simpl l2
        | Some (OptionalBlock (l, Null)) ->
            Lam.if_
              (Lam.not_ Location.none
                 (Lam.prim ~primitive:Pis_null ~args:[ l ] Location.none))
              (simpl l2) (simpl l3)
        | Some (OptionalBlock (l, Undefined)) ->
            Lam.if_
              (Lam.not_ Location.none
                 (Lam.prim ~primitive:Pis_undefined ~args:[ l ] Location.none))
              (simpl l2) (simpl l3)
        | Some (OptionalBlock (l, Null_undefined)) ->
            Lam.if_
              (Lam.not_ Location.none
                 (Lam.prim ~primitive:Pis_null_undefined ~args:[ l ]
                    Location.none))
              (simpl l2) (simpl l3)
        | Some _ | None -> Lam.if_ l1 (simpl l2) (simpl l3))
    (* could be the code path
       {[ match x with
         | h::hs ->
       ]}
    *)
    | Lifthenelse (l1, l2, l3) -> (
        match l1 with
        | Lvar id | Lmutvar id -> (
            match id_is_for_sure_true_in_boolean meta.ident_tbl id with
            | Eval_true -> simpl l2
            | Eval_false -> simpl l3
            | Eval_unknown -> Lam.if_ (simpl l1) (simpl l2) (simpl l3))
        | _ -> Lam.if_ (simpl l1) (simpl l2) (simpl l3))
    | Lconst _ -> lam
    | Llet (str, v, l1, l2) -> Lam.let_ str v (simpl l1) (simpl l2)
    | Lmutlet (v, l1, l2) -> Lam.mutlet v (simpl l1) (simpl l2)
    | Lletrec (bindings, body) ->
        let bindings = List.map_snd bindings ~f:simpl in
        Lam.letrec bindings (simpl body)
    (* complicated
           1. inline this function
           2. ...
           exports.Make=
           function(funarg)
       {var $$let=Make(funarg);
         return [0, $$let[5],... $$let[16]]}
    *)
    | Lapply
        {
          ap_func =
            Lprim
              {
                primitive = Pfield (_, Fld_module { name = fld_name });
                args = [ Lglobal_module { id = ident; dynamic_import } ];
                _;
              } as l1;
          ap_args = args;
          ap_info;
        } -> (
        match
          Lam_compile_env.query_external_id_info ~dynamic_import ident fld_name
        with
        | Some
            {
              persistent_closed_lambda = Some (Lfunction { params; body; _ });
              _;
            }
        (* be more cautious when do cross module inlining *)
          when List.same_length params args
               && List.for_all
                    ~f:(fun (arg : Lam.t) ->
                      match arg with
                      | Lvar p | Lmutvar p -> (
                          match Ident.Hash.find_opt meta.ident_tbl p with
                          | Some v -> v <> Parameter
                          | None -> true)
                      | _ -> true)
                    args ->
            simpl (Lam_beta_reduce.propagate_beta_reduce meta params body args)
        | Some _ | None -> Lam.apply (simpl l1) (List.map ~f:simpl args) ap_info
        )
    (* Function inlining interact with other optimizations...

        - parameter attributes
        - scope issues
        - code bloat
    *)
    | Lapply { ap_func = (Lvar v | Lmutvar v) as fn; ap_args; ap_info } -> (
        (* Check info for always inlining *)

        (* Ext_log.dwarn __LOC__ "%s/%d" v.name v.stamp;     *)
        let ap_args = List.map ~f:simpl ap_args in
        let[@local] normal () = Lam.apply (simpl fn) ap_args ap_info in
        match Ident.Hash.find_opt meta.ident_tbl v with
        | Some
            (FunctionId
               {
                 lambda =
                   Some
                     ( Lfunction
                         ({ params; body; attr = { is_a_functor; _ }; _ } as m),
                       rec_flag );
                 _;
               }) ->
            if List.same_length ap_args params (* && false *) then
              if
                is_a_functor
                (* && (Ident.Set.mem v meta.export_idents) && false *)
              then
                (* TODO: check l1 if it is exported,
                   if so, maybe not since in that case,
                   we are going to have two copy?
                *)
                (* Check: recursive applying may result in non-termination *)

                (* Ext_log.dwarn __LOC__ "beta .. %s/%d" v.name v.stamp ; *)
                simpl
                  (Lam_beta_reduce.propagate_beta_reduce meta params body
                     ap_args)
              else if
                (* Lam_analysis.size body < Lam_analysis.small_inline_size *)
                (* ap_inlined = Always_inline || *)
                Lam_analysis.ok_to_inline_fun_when_app m ap_args
              then
                (* let param_map =  *)
                (*   Lam_analysis.free_variables meta.export_idents  *)
                (*     (Lam_analysis.param_map_of_list params) body in *)
                (* let old_count = List.length params in *)
                (* let new_count = Map_ident.cardinal param_map in *)
                let param_map =
                  Lam_closure.is_closed_with_map meta.export_idents params body
                in
                let is_export_id = Ident.Set.mem meta.export_idents v in
                match (is_export_id, param_map) with
                | false, (_, param_map) | true, (true, param_map) -> (
                    match rec_flag with
                    | Lam_rec ->
                        Lam_beta_reduce.propagate_beta_reduce_with_map meta
                          param_map params body ap_args
                    | Lam_self_rec -> normal ()
                    | Lam_non_rec ->
                        if
                          List.exists
                            ~f:(fun lam -> Lam_hit.hit_variable v lam)
                            ap_args
                          (*avoid nontermination, e.g, `g(g)`*)
                        then normal ()
                        else
                          simpl
                            (Lam_beta_reduce.propagate_beta_reduce_with_map meta
                               param_map params body ap_args))
                | _ -> normal ()
              else normal ()
            else normal ()
        | Some _ | None -> normal ())
    | Lapply { ap_func = Lfunction { params; body; _ }; ap_args = args; _ }
      when List.same_length params args ->
        simpl (Lam_beta_reduce.propagate_beta_reduce meta params body args)
        (* | Lapply{ fn = Lfunction{function_kind =  Tupled;  params; body};  *)
        (*          args = [Lprim {primitive = Pmakeblock _; args; _}]; _} *)
        (*   (\* TODO: keep track of this parameter in ocaml trunk, *)
        (*       can we switch to the tupled backend? *)
        (*   *\) *)
        (*   when  List.same_length params args -> *)
        (*   simpl (Lam_beta_reduce.propagate_beta_reduce meta params body args) *)
    | Lapply { ap_func = l1; ap_args = ll; ap_info } ->
        Lam.apply (simpl l1) (List.map ~f:simpl ll) ap_info
    | Lfunction { arity; params; body; attr } ->
        Lam.function_ ~arity ~params ~body:(simpl body) ~attr
    | Lswitch
        ( l,
          {
            sw_failaction;
            sw_consts;
            sw_blocks;
            sw_blocks_full;
            sw_consts_full;
            sw_names;
          } ) ->
        Lam.switch (simpl l)
          {
            sw_consts = List.map_snd sw_consts ~f:simpl;
            sw_blocks = List.map_snd sw_blocks ~f:simpl;
            sw_consts_full;
            sw_blocks_full;
            sw_failaction = Option.map simpl sw_failaction;
            sw_names;
          }
    | Lstringswitch (l, sw, d) ->
        let l =
          match l with
          | Lvar s | Lmutvar s -> (
              match Ident.Hash.find_opt meta.ident_tbl s with
              | Some (Constant s) -> Lam.const s
              | Some _ | None -> simpl l)
          | _ -> simpl l
        in
        Lam.stringswitch l (List.map_snd sw ~f:simpl) (Option.map simpl d)
    | Lstaticraise (i, ls) -> Lam.staticraise i (List.map ~f:simpl ls)
    | Lstaticcatch (l1, ids, l2) -> Lam.staticcatch (simpl l1) ids (simpl l2)
    | Ltrywith (l1, v, l2) -> Lam.try_ (simpl l1) v (simpl l2)
    | Lsequence (l1, l2) -> Lam.seq (simpl l1) (simpl l2)
    | Lwhile (l1, l2) -> Lam.while_ (simpl l1) (simpl l2)
    | Lfor (flag, l1, l2, dir, l3) ->
        Lam.for_ flag (simpl l1) (simpl l2) dir (simpl l3)
    | Lassign (v, l) ->
        (* Lalias-bound variables are never assigned, so don't increase
           v's refsimpl *)
        Lam.assign v (simpl l)
    | Lsend (u, m, o, ll, v) ->
        Lam.send u (simpl m) (simpl o) (List.map ~f:simpl ll) v
    | Lifused (v, l) -> Lam.ifused v (simpl l)
  in
  simpl lam
