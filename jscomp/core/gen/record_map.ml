open Node_types

let rec mkBodyApply0 ty allNames arg =
  let fn = mkStructuralTy ty allNames in
  if fn == skip_obj then None else Some (fn.beta arg)

and mkBodyApply =
  let collapse_body body =
    List.map
      ~f:(fun ((x, e) : string * Ast.expression) ->
        Ast_helper.(Vb.mk (Pat.var { txt = x; loc }) e))
      body
  in
  fun tys allNames args ->
    let body =
      List.mapi
        ~f:(fun i ty ->
          let x = args.(i) in
          (x, mkBodyApply0 ty allNames x))
        tys
      |> List.filter_map ~f:(fun (x, body) ->
             Option.map (fun body -> (x, body)) body)
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
                [%expr [%e code] _self [%e x]]);
            meth = Some code;
          })
  | Ptyp_constr ({ txt = Lident (("option" | "list") as list); _ }, [ base ]) ->
      let inner = mkStructuralTy base allNames in
      if inner == skip_obj then inner
      else
        let inner_code = Option.value inner.meth ~default:inner.eta in
        let list = Ast_helper.Exp.ident { txt = Lident list; loc } in
        {
          eta = [%expr fun _self arg -> [%e list] [%e inner_code] _self arg];
          beta =
            (fun x ->
              let x = Ast_helper.Exp.ident { txt = Lident x; loc } in
              [%expr [%e list] [%e inner_code] _self [%e x]]);
          meth = None;
        }
  | Ptyp_constr ({ txt; _ }, _) ->
      failwith
        (Format.asprintf "unsupported high order type %s"
           (txt |> Longident.flatten |> String.concat ~sep:"."))
  | Ptyp_tuple xs ->
      let len = List.length xs in
      let args0 = Array.init len ~f:(fun i -> "_x" ^ string_of_int i) in
      let vbs = mkBodyApply xs allNames args0 in
      let args =
        Ast_helper.Pat.tuple
          (Array.map ~f:(fun s -> Ast_helper.Pat.var { txt = s; loc }) args0
          |> Array.to_list)
      in
      let body =
        Ast_helper.Exp.(
          let_ Nonrecursive vbs
            (tuple
               (Array.map ~f:(fun s -> ident { txt = Lident s; loc }) args0
               |> Array.to_list)))
      in
      {
        eta = [%expr fun _self [%p args] -> [%e body]];
        beta =
          (fun x ->
            let x = Ast_helper.Exp.ident { txt = Lident x; loc } in
            (*  TODO: could be inlined further *)
            [%expr (fun [%p args] -> [%e body]) [%e x]]);
        meth = None;
      }
  | _ -> assert false

let mkBranch (branch : Ast.constructor_declaration) allNames =
  match branch.pcd_args with
  | Pcstr_tuple [] ->
      Ast_helper.(
        Exp.case
          (Pat.alias
             (Pat.construct { txt = Lident branch.pcd_name.txt; loc } None)
             { txt = "v"; loc })
          (Exp.ident { txt = Lident "v"; loc }))
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
      | [] ->
          Ast_helper.(
            Exp.case
              (Pat.alias
                 (Pat.construct
                    { txt = Lident branch.pcd_name.txt; loc }
                    (Some (Pat.any ())))
                 { txt = "v"; loc })
              (Exp.ident { txt = Lident "v"; loc }))
      | vbs ->
          let exp =
            Ast_helper.Exp.(
              construct
                { txt = Lident branch.pcd_name.txt; loc }
                (Some
                   (match tys with
                   | [] -> assert false
                   | _ :: [] -> ident { txt = Lident args.(0); loc }
                   | tys ->
                       tuple
                         (List.mapi
                            ~f:(fun idx _ ->
                              ident { txt = Lident args.(idx); loc })
                            tys))))
          in
          Ast_helper.Exp.(case pat_exp (let_ Nonrecursive vbs exp)))
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
                       ( { pld_name with txt = Longident.Lident name },
                         Ast_helper.Pat.var { txt = args.(idx); loc } ))
                     lbdcls)
                  Closed)))
      in
      match
        mkBodyApply
          (List.map ~f:(fun { Ast.pld_type = ty; _ } -> ty) lbdcls)
          allNames args
      with
      | [] ->
          Ast_helper.(
            Exp.case
              (Pat.alias
                 (Pat.construct
                    { txt = Lident branch.pcd_name.txt; loc }
                    (Some (Pat.any ())))
                 { txt = "v"; loc })
              (Exp.ident { txt = Lident "v"; loc }))
      | vbs ->
          let exp =
            Ast_helper.Exp.(
              construct
                { txt = Lident branch.pcd_name.txt; loc }
                (Some
                   (record
                      (List.mapi
                         ~f:(fun idx { Ast.pld_name; _ } ->
                           let { Asttypes.txt = name; loc } = pld_name in
                           ( { pld_name with txt = Longident.Lident name },
                             ident { txt = Lident args.(idx); loc } ))
                         lbdcls)
                      None)))
          in
          Ast_helper.Exp.(case pat_exp (let_ Nonrecursive vbs exp)))

let mkBody (tdcl : Ast.type_declaration) allNames =
  match tdcl.ptype_kind with
  | Ptype_variant cstrs ->
      let branches =
        List.map ~f:(fun branch -> mkBranch branch allNames) cstrs
      in
      let branches_fn = Ast_helper.Exp.function_ branches in
      [%expr fun _self -> [%e branches_fn]]
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
               ( { pld_name with txt = Longident.Lident name },
                 Ast_helper.Pat.var { txt = args.(idx); loc } ))
             lbdcls)
          Closed
      in
      let vbs =
        mkBodyApply
          (List.map ~f:(fun { Ast.pld_type = ty; _ } -> ty) lbdcls)
          allNames args
      in
      let body =
        Ast_helper.Exp.(
          let_ Nonrecursive vbs
            (record
               (List.mapi
                  ~f:(fun idx { Ast.pld_name; _ } ->
                    let { Asttypes.txt = name; loc } = pld_name in
                    ( { pld_name with txt = Longident.Lident name },
                      ident { txt = Lident args.(idx); loc } ))
                  lbdcls)
               None))
      in
      [%expr fun _self [%p pat_exp] -> [%e body]]
  | Ptype_open -> failwith "unknown"

let mkMethod (tdcl : Ast.type_declaration) allNames =
  let name = Ast_helper.Pat.var { txt = tdcl.ptype_name.txt; loc } in
  let typ =
    Ast_helper.(
      Typ.constr { txt = Lident "fn"; loc }
        [ Typ.constr { txt = Lident tdcl.ptype_name.txt; loc } [] ])
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
                    [ Typ.constr { txt = Lident name; loc } [] ])))
           (StringSet.to_seq customNames |> List.of_seq))
    in
    let iter = Ast_helper.Type.mk ~kind:record { txt = "iter"; loc } in
    let fn =
      Ast_helper.Type.mk
        ~params:[ ([%type: 'a], (NoVariance, NoInjectivity)) ]
        ~manifest:[%type: iter -> 'a -> 'a] { txt = "fn"; loc }
    in
    Ast_helper.Str.type_ Recursive [ iter; fn ]
  in
  let let_super =
    let super =
      Ast_helper.Exp.record
        (List.map
           ~f:(fun s ->
             let lid = { Asttypes.txt = Longident.Lident s; loc } in
             (lid, Ast_helper.Exp.ident lid))
           (StringSet.to_seq customNames |> List.of_seq))
        None
    in
    [%stri let super : iter = [%e super]]
  in

  [%str
    open J

    let[@inline] unknown _ x = x

    let[@inline] option sub self v =
      match v with None -> None | Some v -> Some (sub self v)

    let rec list sub self x =
      match x with
      | [] -> []
      | x :: xs ->
          let v = sub self x in
          v :: list sub self xs

    [%%i type_iter]]
  @ output @ [ let_super ]
