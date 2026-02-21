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

let lift_effectful_single (effectful : Ident.Set.t) (group : Lam_group.t) :
    Lam_group.t list =
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
    when Ident.Set.mem id effectful ->
      let cps_id = Ident.create (Ident.name id ^ "$cps") in
      let k = Ident.create_local "__k" in
      let ap_info =
        {
          Lam.ap_loc = loc;
          ap_inlined = Default_inline;
          ap_status = App_na;
        }
      in
      let cps_body = Lam.apply (Lam.var k) [ body ] ap_info in
      let cps_fun =
        Lam.function_ ~loc ~attr:{ attr with inline = Never_inline }
          ~arity:(arity + 1)
          ~params:(List.append params [ k ])
          ~body:cps_body
      in
      let id_x = Ident.create_local "__x" in
      let id_fun =
        Lam.function_ ~loc ~attr ~arity:1 ~params:[ id_x ] ~body:(Lam.var id_x)
      in
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
      ]
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
  | _ -> [ group ]

let transform_groups ~(enabled : bool) ~(effectful : Ident.Set.t)
    (groups : Lam_group.t list) =
  if not enabled then groups
  else List.concat_map groups ~f:(lift_effectful_single effectful)
