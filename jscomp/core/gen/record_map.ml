open Node_types

let rec mkBodyApply0 ty allNames arg =
  let fn = mkStructuralTy ty allNames in
  if fn == skip_obj then None else Some (fn.beta arg)

and mkBodyApply tys allNames args rebuild =
  let mapped_args = Array.copy args in
  let bindings =
    List.filter_mapi
      ~f:(fun i ty ->
        let x = args.(i) in
        Option.map
          (fun e ->
            let mapped = x ^ "'" in
            mapped_args.(i) <- mapped;
            (x, mapped, e))
          (mkBodyApply0 ty allNames x))
      tys
  in
  let original = Record_common.ident "_original" in
  match bindings with
  | [] -> original
  | _ ->
      let unchanged =
        List.fold_right
          ~f:(fun (x, mapped, _) rest ->
            let x = Record_common.ident x in
            let mapped = Record_common.ident mapped in
            [%expr [%e x] == [%e mapped] && [%e rest]])
          bindings ~init:[%expr true]
      in
      let vbs =
        List.map
          ~f:(fun (_, mapped, e) ->
            Ast_helper.Vb.mk (Record_common.var mapped) e)
          bindings
      in
      (* Run every callback in the original binding order before checking for
         changes: callbacks may update metadata even when they return the node. *)
      Ast_helper.Exp.let_ Nonrecursive vbs
        [%expr
          if [%e unchanged] then [%e original] else [%e rebuild mapped_args]]

and mkStructuralTy (ty : Ast.core_type) allNames =
  match ty.ptyp_desc with
  | Ptyp_constr ({ txt = def; _ }, []) -> (
      match Record_common.structural_method def allNames with
      | None -> skip_obj
      | Some code ->
          {
            eta = [%expr fun _self arg -> [%e code] _self arg];
            beta =
              (fun x ->
                let x = Ast_helper.Exp.ident { txt = Lident x; loc } in
                [%expr [%e code] _self [%e x]]);
            meth = Some code;
          })
  | Ptyp_constr ({ txt; _ }, args) -> (
      match (Record_common.Container.of_longident txt, args) with
      | Some container, [ base ] -> higher_order_constr container base allNames
      | _ ->
          failwith
            (Printf.sprintf "unsupported high order type %s"
               (txt |> Ppxlib.Longident.flatten_exn |> String.concat ~sep:".")))
  | Ptyp_tuple xs ->
      let len = List.length xs in
      let args0 = Record_common.indexed_names len in
      let args =
        Ast_helper.Pat.alias
          (Record_common.tuple_pattern args0)
          { txt = "_original"; loc }
      in
      let body = mkBodyApply xs allNames args0 Record_common.tuple_expression in
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

and higher_order_constr container base allNames =
  let inner = mkStructuralTy base allNames in
  if inner == skip_obj then inner
  else
    let inner_code = Option.value inner.meth ~default:inner.eta in
    let traversal =
      Record_common.ident (Record_common.Container.traversal_name container)
    in
    {
      eta = [%expr fun _self arg -> [%e traversal] [%e inner_code] _self arg];
      beta =
        (fun x ->
          let x = Ast_helper.Exp.ident { txt = Lident x; loc } in
          [%expr [%e traversal] [%e inner_code] _self [%e x]]);
      meth = None;
    }

let mkBranch (branch : Ast.constructor_declaration) allNames =
  let name = branch.pcd_name.txt in
  let pattern, body =
    match branch.pcd_args with
    | Pcstr_tuple tys ->
        let args = Record_common.indexed_names (List.length tys) in
        ( Record_common.constructor_pattern name args,
          mkBodyApply tys allNames args
            (Record_common.constructor_expression name) )
    | Pcstr_record lbdcls ->
        let args = Record_common.indexed_names (List.length lbdcls) in
        ( Record_common.constructor_record_pattern name lbdcls args,
          mkBodyApply
            (List.map ~f:(fun { Ast.pld_type = ty; _ } -> ty) lbdcls)
            allNames args
            (Record_common.constructor_record_expression name lbdcls) )
  in
  Ast_helper.Exp.case
    (Ast_helper.Pat.alias pattern { txt = "_original"; loc })
    body

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
      let args = Record_common.indexed_names len in
      let pat_exp =
        Ast_helper.Pat.alias
          (Record_common.record_pattern lbdcls args)
          { txt = "_original"; loc }
      in
      let body =
        mkBodyApply
          (List.map ~f:(fun { Ast.pld_type = ty; _ } -> ty) lbdcls)
          allNames args
          (Record_common.record_expression lbdcls)
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
    Record_common.traversal_types customNames ~iter_params:[]
      ~field_type:(fun name ->
        Ast_helper.Typ.constr { txt = Lident "fn"; loc }
          [ Ast_helper.Typ.constr { txt = Lident name; loc } [] ])
      ~fn_params:[ ([%type: 'a], (NoVariance, NoInjectivity)) ]
      ~fn_manifest:[%type: iter -> 'a -> 'a]
  in
  let let_super = Record_common.super customNames [%type: iter] in

  [%str
    open J

    let[@inline] unknown _ x = x

    let[@inline] option sub self v =
      match v with
      | None -> None
      | Some x ->
          let x' = sub self x in
          if x == x' then v else Some x'

    let rec list sub self x =
      match x with
      | [] -> []
      | head :: tail as original ->
          let head' = sub self head in
          let tail' = list sub self tail in
          if head == head' && tail == tail' then original else head' :: tail'

    let nonempty_list sub self (x :: xs as original : _ Melstd.Nonempty_list.t)
        : _ Melstd.Nonempty_list.t =
      let x' = sub self x in
      let xs' = list sub self xs in
      if x == x' && xs == xs' then original else x' :: xs'

    [%%i type_iter]]
  @ output @ [ let_super ]
