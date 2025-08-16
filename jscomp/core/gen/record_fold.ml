open Node_types

let _st = Ast_helper.Exp.ident { txt = Lident "st"; loc }

let rec mkBodyApply0 ty allNames arg =
  let fn = mkStructuralTy ty allNames in
  if fn == skip_obj then None else Some (fn.beta arg)

and mkBodyApply =
  let collapse_body body =
    let rec collapse_body = function
      | [] -> raise_notrace Not_found
      | [ x ] ->
          fun e ->
            Ast_helper.(
              Exp.let_ Nonrecursive [ Vb.mk (Pat.var { txt = "st"; loc }) x ] e)
      | x :: xs ->
          fun e ->
            Ast_helper.(
              Exp.let_ Nonrecursive
                [ Vb.mk (Pat.var { txt = "st"; loc }) x ]
                ((collapse_body xs) e))
    in
    match collapse_body body with
    | body -> Some body
    | exception Not_found -> None
  in
  fun tys allNames args ->
    let body =
      List.mapi ~f:(fun i ty -> mkBodyApply0 ty allNames args.(i)) tys
      |> List.filter_map ~f:Fun.id
    in
    collapse_body body

and mkStructuralTy (ty : Ast.core_type) allNames =
  match ty.ptyp_desc with
  | Ptyp_constr ({ txt = def; _ }, []) -> (
      let basic = isSupported def allNames in
      match basic with
      | `no -> skip_obj
      | `yes _ | `exclude _ ->
          let code =
            match basic with
            | `yes name ->
                Ast_helper.Exp.(
                  field
                    (ident { txt = Lident "_self"; loc })
                    { txt = Lident name; loc })
            | `exclude name -> Ast_helper.Exp.ident { txt = Lident name; loc }
            | _ -> assert false
          in
          {
            eta = [%expr fun _self arg -> [%e code] _self arg];
            beta =
              (fun x ->
                let x = Ast_helper.Exp.ident { txt = Lident x; loc } in
                [%expr [%e code] _self st [%e x]]);
            meth = Some code;
          })
  | Ptyp_constr ({ txt = Lident (("option" | "list") as list); _ }, [ base ]) ->
      higher_order_constr list base allNames
  | Ptyp_constr ({ txt = Ldot (Lident "Nonempty_list", "t"); _ }, [ base ]) ->
      higher_order_constr "nonempty_list" base allNames
  | Ptyp_constr ({ txt; _ }, _) ->
      failwith
        (Format.asprintf "unsupported high order type %s"
           (txt |> Ppxlib.Longident.flatten_exn |> String.concat ~sep:"."))
  | Ptyp_tuple xs ->
      let len = List.length xs in
      let args0 = Array.init len ~f:(fun i -> "_x" ^ string_of_int i) in
      let args =
        Ast_helper.Pat.tuple
          (Array.map ~f:(fun s -> Ast_helper.Pat.var { txt = s; loc }) args0
          |> Array.to_list)
      in
      let body =
        match mkBodyApply xs allNames args0 with
        | None -> _st
        | Some body -> body _st
      in
      {
        eta = [%expr fun _self st [%p args] -> [%e body]];
        beta =
          (fun x ->
            let x = Ast_helper.Exp.ident { txt = Lident x; loc } in
            (*  TODO: could be inlined further *)
            [%expr (fun [%p args] -> [%e body]) [%e x]]);
        meth = None;
      }
  | _ -> assert false

and higher_order_constr list base allNames =
  let inner = mkStructuralTy base allNames in
  if inner == skip_obj then inner
  else
    let inner_code = Option.value inner.meth ~default:inner.eta in
    let list = Ast_helper.Exp.ident { txt = Lident list; loc } in
    {
      eta = [%expr fun _self st arg -> [%e list] [%e inner_code] _self st arg];
      beta =
        (fun x ->
          let x = Ast_helper.Exp.ident { txt = Lident x; loc } in
          [%expr [%e list] [%e inner_code] _self st [%e x]]);
      meth = None;
    }

let mkBranch (branch : Ast.constructor_declaration) allNames =
  match branch.pcd_args with
  | Pcstr_tuple [] ->
      Ast_helper.(
        Exp.case
          (Pat.construct { txt = Lident branch.pcd_name.txt; loc } None)
          _st)
  | Pcstr_tuple tys -> (
      let len = List.length tys in
      let args = Array.init len ~f:(fun i -> "_x" ^ string_of_int i) in
      let pat_exp =
        Ast_helper.(
          Pat.construct
            { txt = Lident branch.pcd_name.txt; loc }
            (Some
               (match tys with
               | [] -> assert false
               | _ :: [] -> Ast_helper.Pat.var { txt = args.(0); loc }
               | tys ->
                   Ast_helper.Pat.tuple
                     (List.mapi
                        ~f:(fun idx _ ->
                          Ast_helper.Pat.var { txt = args.(idx); loc })
                        tys))))
      in
      match mkBodyApply tys allNames args with
      | None ->
          Ast_helper.(
            Exp.case
              (Pat.construct
                 { txt = Lident branch.pcd_name.txt; loc }
                 (Some (Pat.any ())))
              _st)
      | Some body -> Ast_helper.Exp.(case pat_exp (body _st)))
  | Pcstr_record lbdcls -> (
      let len = List.length lbdcls in
      let args = Array.init len ~f:(fun i -> "_x" ^ string_of_int i) in
      let pat_exp =
        Ast_helper.(
          Pat.construct
            { txt = Lident branch.pcd_name.txt; loc }
            (Some
               (Ast_helper.Pat.record
                  (List.mapi
                     ~f:(fun idx { Ast.pld_name; _ } ->
                       let { Asttypes.txt = name; loc } = pld_name in
                       ( { pld_name with txt = Ppxlib.Longident.Lident name },
                         Ast_helper.Pat.var { txt = args.(idx); loc } ))
                     lbdcls)
                  Closed)))
      in
      match
        mkBodyApply
          (List.map ~f:(fun { Ast.pld_type = ty; _ } -> ty) lbdcls)
          allNames args
      with
      | None ->
          Ast_helper.(
            Exp.case
              (Pat.construct
                 { txt = Lident branch.pcd_name.txt; loc }
                 (Some (Pat.any ())))
              _st)
      | Some body -> Ast_helper.Exp.(case pat_exp (body _st)))

let mkBody (tdcl : Ast.type_declaration) allNames =
  match tdcl.ptype_kind with
  | Ptype_variant cstrs ->
      let branches =
        List.map ~f:(fun branch -> mkBranch branch allNames) cstrs
      in
      let branches_fn = Ast_helper.Exp.function_ branches in
      [%expr fun _self st -> [%e branches_fn]]
  | Ptype_abstract ->
      let ty = Option.get tdcl.ptype_manifest in
      (mkStructuralTy ty allNames).eta
  | Ptype_record lbdcls ->
      let len = List.length lbdcls in
      let args = Array.init len ~f:(fun i -> "_x" ^ string_of_int i) in
      let pat_exp =
        Ast_helper.Pat.record
          (List.mapi
             ~f:(fun idx { Ast.pld_name; _ } ->
               let { Asttypes.txt = name; loc } = pld_name in
               ( { pld_name with txt = Ppxlib.Longident.Lident name },
                 Ast_helper.Pat.var { txt = args.(idx); loc } ))
             lbdcls)
          Closed
      in
      let body =
        match
          mkBodyApply
            (List.map ~f:(fun { Ast.pld_type = ty; _ } -> ty) lbdcls)
            allNames args
        with
        | None -> _st
        | Some body -> body _st
      in
      [%expr fun _self st [%p pat_exp] -> [%e body]]
  | Ptype_open -> failwith "unknown"

let mkMethod (tdcl : Ast.type_declaration) allNames =
  let name = Ast_helper.Pat.var { txt = tdcl.ptype_name.txt; loc } in
  let typ =
    Ast_helper.Typ.(
      poly
        [ { txt = "a"; loc } ]
        (constr { txt = Lident "fn"; loc }
           [ var "a"; constr { txt = Lident tdcl.ptype_name.txt; loc } [] ]))
  in
  [%stri let [%p name] : [%t typ] = [%e mkBody tdcl allNames]]

let make type_declaration =
  let { names; type_declarations } = type_declaration in
  let customNames = StringSet.diff names.all names.excludes in
  let output =
    List.map ~f:(fun typedef -> mkMethod typedef names) type_declarations
  in
  let type_iter =
    let record =
      Parsetree.Ptype_record
        (List.map
           ~f:(fun name ->
             Ast_helper.(
               Type.field { txt = name; loc }
                 (Typ.constr { txt = Lident "fn"; loc }
                    [
                      Typ.var "state"; Typ.constr { txt = Lident name; loc } [];
                    ])))
           (StringSet.to_seq customNames |> List.of_seq))
    in
    let iter =
      Ast_helper.Type.mk
        ~params:[ ([%type: 'state], (NoVariance, NoInjectivity)) ]
        ~kind:record { txt = "iter"; loc }
    in
    let fn =
      Ast_helper.Type.mk
        ~params:
          [
            ([%type: 'state], (NoVariance, NoInjectivity));
            ([%type: 'a], (NoVariance, NoInjectivity));
          ]
        ~manifest:[%type: 'state iter -> 'state -> 'a -> 'state]
        { txt = "fn"; loc }
    in
    Ast_helper.Str.type_ Recursive [ iter; fn ]
  in
  let let_super =
    let super =
      Ast_helper.Exp.record
        (List.map
           ~f:(fun s ->
             let lid = { Asttypes.txt = Ppxlib.Longident.Lident s; loc } in
             (lid, Ast_helper.Exp.ident lid))
           (StringSet.to_seq customNames |> List.of_seq))
        None
    in
    [%stri let super : 'state iter = [%e super]]
  in

  [%str
    open J

    let[@inline] unknown _ st _ = st

    let[@inline] option sub self st v =
      match v with None -> st | Some v -> sub self st v

    let rec list sub self st x =
      match x with
      | [] -> st
      | x :: xs ->
          let st = sub self st x in
          list sub self st xs

    let nonempty_list sub self st (x :: xs : _ Melstd.Nonempty_list.t) =
      let st = sub self st x in
      list sub self st xs

    [%%i type_iter]]
  @ output @ [ let_super ]
