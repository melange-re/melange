open Import

let enabled_from_env () =
  match Sys.getenv "MELANGE_EFFECT_CPS_EXPERIMENT" with
  | "1" | "true" | "yes" -> true
  | _ -> false
  | exception Not_found -> false

let debug_enabled () =
  match Sys.getenv "MELANGE_EFFECT_CPS_DEBUG" with
  | "1" -> true
  | _ -> false
  | exception Not_found -> false

let map_find_cps_id (cps_ids : Ident.t Ident.Map.t) (id : Ident.t) =
  Ident.Map.find_opt id cps_ids

let rec rewrite_value ~(owner : Ident.t) ~(cps_ids : Ident.t Ident.Map.t)
    ~(k : Ident.t) (lam : Lam.t) : Lam.t =
  match lam with
  | Lvar _ | Lmutvar _ | Lconst _ | Lglobal_module _ -> lam
  | Lapply { ap_func; ap_args; ap_info } ->
      Lam.apply
        (rewrite_value ~owner ~cps_ids ~k ap_func)
        (List.map ~f:(rewrite_value ~owner ~cps_ids ~k) ap_args)
        ap_info
  | Lfunction { arity; params; body; attr; loc } ->
      Lam.function_ ~loc ~attr ~arity ~params
        ~body:(rewrite_value ~owner ~cps_ids ~k body)
  | Llet (kind, id, arg, body) ->
      Lam.let_ kind id
        (rewrite_value ~owner ~cps_ids ~k arg)
        (rewrite_value ~owner ~cps_ids ~k body)
  | Lmutlet (id, arg, body) ->
      Lam.mutlet id
        (rewrite_value ~owner ~cps_ids ~k arg)
        (rewrite_value ~owner ~cps_ids ~k body)
  | Lletrec (bindings, body) ->
      Lam.letrec
        (List.map bindings ~f:(fun (id, rhs) ->
             (id, rewrite_value ~owner ~cps_ids ~k rhs)))
        (rewrite_value ~owner ~cps_ids ~k body)
  | Lprim { primitive; args; loc } ->
      Lam.prim ~primitive
        ~args:(List.map args ~f:(rewrite_value ~owner ~cps_ids ~k))
        ~loc
  | Lswitch
      ( arg,
        {
          sw_consts;
          sw_consts_full;
          sw_blocks;
          sw_blocks_full;
          sw_failaction;
          sw_names;
        } ) ->
      Lam.switch
        (rewrite_value ~owner ~cps_ids ~k arg)
        {
          sw_consts =
            List.map sw_consts ~f:(fun (tag, case) ->
                (tag, rewrite_value ~owner ~cps_ids ~k case));
          sw_consts_full;
          sw_blocks =
            List.map sw_blocks ~f:(fun (tag, case) ->
                (tag, rewrite_value ~owner ~cps_ids ~k case));
          sw_blocks_full;
          sw_failaction = Option.map sw_failaction ~f:(rewrite_value ~owner ~cps_ids ~k);
          sw_names;
        }
  | Lstringswitch (arg, cases, default) ->
      Lam.stringswitch
        (rewrite_value ~owner ~cps_ids ~k arg)
        (List.map cases ~f:(fun (s, case) ->
             (s, rewrite_value ~owner ~cps_ids ~k case)))
        (Option.map default ~f:(rewrite_value ~owner ~cps_ids ~k))
  | Lstaticraise (i, args) ->
      Lam.staticraise i
        (List.map args ~f:(rewrite_value ~owner ~cps_ids ~k))
  | Lstaticcatch (body, (i, vars), handler) ->
      Lam.staticcatch
        (rewrite_value ~owner ~cps_ids ~k body)
        (i, vars)
        (rewrite_value ~owner ~cps_ids ~k handler)
  | Ltrywith (body, exn, handler) ->
      Lam.try_
        (rewrite_value ~owner ~cps_ids ~k body)
        exn
        (rewrite_value ~owner ~cps_ids ~k handler)
  | Lifthenelse (pred, ifso, ifnot) ->
      Lam.if_
        (rewrite_value ~owner ~cps_ids ~k pred)
        (rewrite_value ~owner ~cps_ids ~k ifso)
        (rewrite_value ~owner ~cps_ids ~k ifnot)
  | Lsequence (left, right) ->
      Lam.seq
        (rewrite_value ~owner ~cps_ids ~k left)
        (rewrite_value ~owner ~cps_ids ~k right)
  | Lwhile (pred, body) ->
      Lam.while_
        (rewrite_value ~owner ~cps_ids ~k pred)
        (rewrite_value ~owner ~cps_ids ~k body)
  | Lfor (id, from_, to_, dir, body) ->
      Lam.for_ id
        (rewrite_value ~owner ~cps_ids ~k from_)
        (rewrite_value ~owner ~cps_ids ~k to_) dir
        (rewrite_value ~owner ~cps_ids ~k body)
  | Lassign (id, rhs) ->
      Lam.assign id (rewrite_value ~owner ~cps_ids ~k rhs)
  | Lsend (mk, meth, obj, args, loc) ->
      Lam.send mk
        (rewrite_value ~owner ~cps_ids ~k meth)
        (rewrite_value ~owner ~cps_ids ~k obj)
        (List.map args ~f:(rewrite_value ~owner ~cps_ids ~k))
        ~loc
  | Lifused (id, body) ->
      Lam.ifused id (rewrite_value ~owner ~cps_ids ~k body)

let apply_k (ap_info : Lam.ap_info) (k : Ident.t) (value : Lam.t) =
  Lam.apply (Lam.var k) [ value ] ap_info

let perform_prim (lam : Lam.t) =
  match lam with
  | Lprim
      {
        primitive = Lam_primitive.Pccall { prim_name = "caml_perform" };
        args = [ eff ];
        loc;
      } ->
      Some (eff, loc)
  | _ -> None

let rec split_first_perform_arg (args : Lam.t list) =
  match args with
  | [] -> None
  | arg :: rest -> (
      match perform_prim arg with
      | Some perf -> Some ([], perf, rest)
      | None -> (
          match split_first_perform_arg rest with
          | None -> None
          | Some (before, perf, after) -> Some (arg :: before, perf, after)))

let bind_prefix_args ~(owner : Ident.t) ~(cps_ids : Ident.t Ident.Map.t)
    ~(k : Ident.t) (args : Lam.t list) (continue : Lam.t list -> Lam.t) =
  let rec aux args acc =
    match args with
    | [] -> continue (List.rev acc)
    | arg :: rest ->
        let id = Ident.create_local "__arg" in
        Lam.let_ Strict id
          (rewrite_value ~owner ~cps_ids ~k arg)
          (aux rest (Lam.var id :: acc))
  in
  aux args []

let rec rewrite_tail ~(owner : Ident.t) ~(cps_ids : Ident.t Ident.Map.t)
    ~(k : Ident.t) ~(ap_info : Lam.ap_info) (lam : Lam.t) : Lam.t =
  match lam with
  | Lapply { ap_func; ap_args; ap_info = call_ap_info } -> (
      match split_first_perform_arg ap_args with
      | Some (before, (eff, eff_loc), after) ->
          if debug_enabled () then
            Format.eprintf "[effect-cps] apply-arg-perform rewrite in %s@."
              (Ident.name owner);
          bind_prefix_args ~owner ~cps_ids ~k before (fun before_vars ->
              let pv = Ident.create_local "__p" in
              let rest_args = List.append before_vars (Lam.var pv :: after) in
              let rest_apply = Lam.apply ap_func rest_args call_ap_info in
              let cont =
                Lam.function_ ~loc:eff_loc
                  ~attr:Lambda.default_function_attribute ~arity:1
                  ~params:[ pv ]
                  ~body:(rewrite_tail ~owner ~cps_ids ~k ~ap_info rest_apply)
              in
              Lam.prim
                ~primitive:
                  (Lam_primitive.Pccall { prim_name = "caml_perform_tail" })
                ~args:[ rewrite_value ~owner ~cps_ids ~k eff; cont ]
                ~loc:eff_loc)
      | None -> (
          match ap_func with
          | Lvar id | Lmutvar id -> (
              match map_find_cps_id cps_ids id with
              | Some cps_id ->
                  if debug_enabled () then
                    Format.eprintf
                      "[effect-cps] tail-call rewrite %s -> %s in %s@."
                      (Ident.name id) (Ident.name cps_id) (Ident.name owner);
                  Lam.apply (Lam.var cps_id)
                    (List.append
                       (List.map ~f:(rewrite_value ~owner ~cps_ids ~k) ap_args)
                       [ Lam.var k ])
                    call_ap_info
              | None -> apply_k ap_info k (rewrite_value ~owner ~cps_ids ~k lam))
          | _ -> apply_k ap_info k (rewrite_value ~owner ~cps_ids ~k lam)))
  | Lprim _ -> (
      match perform_prim lam with
      | Some (eff, loc) ->
          if debug_enabled () then
            Format.eprintf "[effect-cps] tail-perform rewrite in %s@."
              (Ident.name owner);
          Lam.prim
            ~primitive:(Lam_primitive.Pccall { prim_name = "caml_perform_tail" })
            ~args:[ rewrite_value ~owner ~cps_ids ~k eff; Lam.var k ]
            ~loc
      | None -> (
          match lam with
          | Lprim { primitive; args; loc } -> (
              match split_first_perform_arg args with
              | None -> apply_k ap_info k (rewrite_value ~owner ~cps_ids ~k lam)
              | Some (before, (eff, eff_loc), after) ->
                  if debug_enabled () then
                    Format.eprintf
                      "[effect-cps] prim-arg-perform rewrite in %s@."
                      (Ident.name owner);
                  bind_prefix_args ~owner ~cps_ids ~k before (fun before_vars ->
                      let pv = Ident.create_local "__p" in
                      let rest_args = List.append before_vars (Lam.var pv :: after) in
                      let rest_expr = Lam.prim ~primitive ~args:rest_args ~loc in
                      let cont =
                        Lam.function_ ~loc:eff_loc
                          ~attr:Lambda.default_function_attribute ~arity:1
                          ~params:[ pv ]
                          ~body:(rewrite_tail ~owner ~cps_ids ~k ~ap_info rest_expr)
                      in
                      Lam.prim
                        ~primitive:
                          (Lam_primitive.Pccall { prim_name = "caml_perform_tail" })
                        ~args:[ rewrite_value ~owner ~cps_ids ~k eff; cont ]
                        ~loc:eff_loc)
              )
          | _ -> apply_k ap_info k (rewrite_value ~owner ~cps_ids ~k lam)))
  | Llet (kind, id, arg, body) -> (
      match perform_prim arg with
      | Some (eff, loc) ->
          if debug_enabled () then
            Format.eprintf "[effect-cps] let-perform rewrite in %s@."
              (Ident.name owner);
          let cont =
            Lam.function_ ~loc ~attr:Lambda.default_function_attribute ~arity:1
              ~params:[ id ]
              ~body:(rewrite_tail ~owner ~cps_ids ~k ~ap_info body)
          in
          Lam.prim
            ~primitive:(Lam_primitive.Pccall { prim_name = "caml_perform_tail" })
            ~args:[ rewrite_value ~owner ~cps_ids ~k eff; cont ]
            ~loc
      | None ->
          Lam.let_ kind id
            (rewrite_value ~owner ~cps_ids ~k arg)
            (rewrite_tail ~owner ~cps_ids ~k ~ap_info body))
  | Lmutlet (id, arg, body) -> (
      match perform_prim arg with
      | Some (eff, loc) ->
          if debug_enabled () then
            Format.eprintf "[effect-cps] mutlet-perform rewrite in %s@."
              (Ident.name owner);
          let cont =
            Lam.function_ ~loc ~attr:Lambda.default_function_attribute ~arity:1
              ~params:[ id ]
              ~body:(rewrite_tail ~owner ~cps_ids ~k ~ap_info body)
          in
          Lam.prim
            ~primitive:(Lam_primitive.Pccall { prim_name = "caml_perform_tail" })
            ~args:[ rewrite_value ~owner ~cps_ids ~k eff; cont ]
            ~loc
      | None ->
          Lam.mutlet id
            (rewrite_value ~owner ~cps_ids ~k arg)
            (rewrite_tail ~owner ~cps_ids ~k ~ap_info body))
  | Lsequence (left, right) -> (
      match perform_prim left with
      | Some (eff, loc) ->
          if debug_enabled () then
            Format.eprintf "[effect-cps] seq-perform rewrite in %s@."
              (Ident.name owner);
          let u = Ident.create_local "__u" in
          let cont =
            Lam.function_ ~loc ~attr:Lambda.default_function_attribute ~arity:1
              ~params:[ u ]
              ~body:(rewrite_tail ~owner ~cps_ids ~k ~ap_info right)
          in
          Lam.prim
            ~primitive:(Lam_primitive.Pccall { prim_name = "caml_perform_tail" })
            ~args:[ rewrite_value ~owner ~cps_ids ~k eff; cont ]
            ~loc
      | None ->
          Lam.seq
            (rewrite_value ~owner ~cps_ids ~k left)
            (rewrite_tail ~owner ~cps_ids ~k ~ap_info right))
  | Lifthenelse (pred, ifso, ifnot) ->
      Lam.if_
        (rewrite_value ~owner ~cps_ids ~k pred)
        (rewrite_tail ~owner ~cps_ids ~k ~ap_info ifso)
        (rewrite_tail ~owner ~cps_ids ~k ~ap_info ifnot)
  | Lswitch
      ( arg,
        {
          sw_consts;
          sw_consts_full;
          sw_blocks;
          sw_blocks_full;
          sw_failaction;
          sw_names;
        } ) ->
      Lam.switch
        (rewrite_value ~owner ~cps_ids ~k arg)
        {
          sw_consts =
            List.map sw_consts ~f:(fun (tag, case) ->
                (tag, rewrite_tail ~owner ~cps_ids ~k ~ap_info case));
          sw_consts_full;
          sw_blocks =
            List.map sw_blocks ~f:(fun (tag, case) ->
                (tag, rewrite_tail ~owner ~cps_ids ~k ~ap_info case));
          sw_blocks_full;
          sw_failaction =
            Option.map sw_failaction ~f:(rewrite_tail ~owner ~cps_ids ~k ~ap_info);
          sw_names;
        }
  | Lstringswitch (arg, cases, default) ->
      Lam.stringswitch
        (rewrite_value ~owner ~cps_ids ~k arg)
        (List.map cases ~f:(fun (s, case) ->
             (s, rewrite_tail ~owner ~cps_ids ~k ~ap_info case)))
        (Option.map default ~f:(rewrite_tail ~owner ~cps_ids ~k ~ap_info))
  | Lstaticcatch (body, (i, vars), handler) ->
      Lam.staticcatch
        (rewrite_tail ~owner ~cps_ids ~k ~ap_info body)
        (i, vars)
        (rewrite_tail ~owner ~cps_ids ~k ~ap_info handler)
  | Ltrywith (body, exn, handler) ->
      Lam.try_
        (rewrite_tail ~owner ~cps_ids ~k ~ap_info body)
        exn
        (rewrite_tail ~owner ~cps_ids ~k ~ap_info handler)
  | _ -> apply_k ap_info k (rewrite_value ~owner ~cps_ids ~k lam)

let make_identity_cont ~loc ~attr =
  let id_x = Ident.create_local "__x" in
  Lam.function_ ~loc ~attr ~arity:1 ~params:[ id_x ] ~body:(Lam.var id_x)

let build_cps_ids (effectful : Ident.Set.t) (groups : Lam_group.t list) =
  List.fold_left groups ~init:Ident.Map.empty ~f:(fun acc group ->
      match group with
      | Lam_group.Single (_, id, Lfunction _) when Ident.Set.mem id effectful ->
          Ident.Map.add ~key:id ~data:(Ident.create (Ident.name id ^ "$cps")) acc
      | _ -> acc)

let lift_group ~(effectful : Ident.Set.t) ~(cps_ids : Ident.t Ident.Map.t)
    (group : Lam_group.t) : Lam_group.t list =
  match group with
  | Lam_group.Single
      ( kind,
        id,
        Lfunction
          {
            arity;
            params;
            body;
            attr;
            loc;
          } )
    when Ident.Set.mem id effectful -> (
      match map_find_cps_id cps_ids id with
      | None -> [ group ]
      | Some cps_id ->
          let k = Ident.create_local "__k" in
          let ap_info =
            {
              Lam.ap_loc = loc;
              ap_inlined = Default_inline;
              ap_status = App_na;
            }
          in
          let cps_body = rewrite_tail ~owner:id ~cps_ids ~k ~ap_info body in
          let cps_fun =
            Lam.function_ ~loc ~attr:{ attr with inline = Never_inline }
              ~arity:(arity + 1)
              ~params:(List.append params [ k ])
              ~body:cps_body
          in
          let id_fun = make_identity_cont ~loc ~attr in
          let wrapper_body =
            Lam.apply (Lam.var cps_id)
              (List.append (List.map ~f:Lam.var params) [ id_fun ])
              ap_info
          in
          let wrapper_fun =
            Lam.function_ ~loc ~attr ~arity ~params ~body:wrapper_body
          in
          if debug_enabled () then
            Format.eprintf "[effect-cps] lifted %s -> %s@." (Ident.name id)
              (Ident.name cps_id);
          [
            Lam_group.Single (kind, cps_id, cps_fun);
            Lam_group.Single (kind, id, wrapper_fun);
          ])
  | Lam_group.Single (_, id, lam) ->
      if debug_enabled () && Ident.Set.mem id effectful then
        Format.eprintf
          "[effect-cps] skip non-function effectful binding %s (%s)@."
          (Ident.name id)
          (match lam with
          | Lvar _ | Lmutvar _ -> "var"
          | Lconst _ -> "const"
          | Lapply _ -> "apply"
          | Lfunction _ -> "function"
          | Llet _ | Lmutlet _ -> "let"
          | Lletrec _ -> "letrec"
          | Lprim _ -> "prim"
          | Lswitch _ | Lstringswitch _ -> "switch"
          | Lstaticraise _ | Lstaticcatch _ -> "static"
          | Ltrywith _ -> "try"
          | Lifthenelse _ -> "if"
          | Lsequence _ -> "seq"
          | Lwhile _ | Lfor _ -> "loop"
          | Lassign _ -> "assign"
          | Lsend _ -> "send"
          | Lifused _ -> "ifused"
          | Lglobal_module _ -> "global-module");
      [ group ]
  | Recursive bindings ->
      if debug_enabled () then
        List.iter bindings ~f:(fun (id, _) ->
            if Ident.Set.mem id effectful then
              Format.eprintf
                "[effect-cps] skip recursive effectful binding %s (not yet \
                 supported)@."
                (Ident.name id));
      [ group ]
  | _ -> [ group ]

let transform_groups ~(enabled : bool) ~(effectful : Ident.Set.t)
    (groups : Lam_group.t list) =
  if not enabled then groups
  else
    let cps_ids = build_cps_ids effectful groups in
    List.concat_map groups ~f:(lift_group ~effectful ~cps_ids)
