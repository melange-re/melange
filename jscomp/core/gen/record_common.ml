open Node_types

let indexed_names len = Array.init len ~f:(fun i -> "_x" ^ string_of_int i)
let ident name = Ast_helper.Exp.ident { txt = Lident name; loc }
let ident_at name loc = Ast_helper.Exp.ident { txt = Lident name; loc }
let var name = Ast_helper.Pat.var { txt = name; loc }

let tuple_pattern names =
  Ast_helper.Pat.tuple (Array.map ~f:var names |> Array.to_list)

let tuple_expression names =
  Ast_helper.Exp.tuple (Array.map ~f:ident names |> Array.to_list)

let record_fields lbdcls names ~f =
  List.mapi
    ~f:(fun idx { Ast.pld_name; _ } ->
      let { Asttypes.txt = name; loc } = pld_name in
      ({ pld_name with txt = Ppxlib.Longident.Lident name }, f names.(idx) loc))
    lbdcls

let record_pattern lbdcls names =
  Ast_helper.Pat.record
    (record_fields lbdcls names ~f:(fun name loc ->
         Ast_helper.Pat.var { txt = name; loc }))
    Closed

let record_expression lbdcls names =
  Ast_helper.Exp.record
    (record_fields lbdcls names ~f:(fun name loc -> ident_at name loc))
    None

let constructor_pattern name names =
  let argument =
    match Array.length names with
    | 0 -> None
    | 1 -> Some (var names.(0))
    | _ -> Some (tuple_pattern names)
  in
  Ast_helper.Pat.construct { txt = Lident name; loc } argument

let constructor_expression name names =
  let argument =
    match Array.length names with
    | 0 -> None
    | 1 -> Some (ident names.(0))
    | _ -> Some (tuple_expression names)
  in
  Ast_helper.Exp.construct { txt = Lident name; loc } argument

let constructor_record_pattern name lbdcls names =
  Ast_helper.Pat.construct { txt = Lident name; loc }
    (Some (record_pattern lbdcls names))

let constructor_record_expression name lbdcls names =
  Ast_helper.Exp.construct { txt = Lident name; loc }
    (Some (record_expression lbdcls names))

let structural_method def all_names =
  match isSupported def all_names with
  | `no -> None
  | `yes name ->
      Some
        Ast_helper.Exp.(
          field (ident { txt = Lident "_self"; loc }) { txt = Lident name; loc })
  | `exclude name -> Some (ident name)

let traversal_types custom_names ~iter_params ~field_type ~fn_params
    ~fn_manifest =
  let record =
    Parsetree.Ptype_record
      (List.map
         ~f:(fun name ->
           Ast_helper.Type.field { txt = name; loc } (field_type name))
         (StringSet.to_seq custom_names |> List.of_seq))
  in
  let iter =
    Ast_helper.Type.mk ~params:iter_params ~kind:record { txt = "iter"; loc }
  in
  let fn =
    Ast_helper.Type.mk ~params:fn_params ~manifest:fn_manifest
      { txt = "fn"; loc }
  in
  Ast_helper.Str.type_ Recursive [ iter; fn ]

let super custom_names typ =
  let super =
    Ast_helper.Exp.record
      (List.map
         ~f:(fun name ->
           let lid = { Asttypes.txt = Ppxlib.Longident.Lident name; loc } in
           (lid, Ast_helper.Exp.ident lid))
         (StringSet.to_seq custom_names |> List.of_seq))
      None
  in
  [%stri let super : [%t typ] = [%e super]]
