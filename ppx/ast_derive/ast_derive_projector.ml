open Ast_helper

type tdcls = Parsetree.type_declaration list

let derivingName = "accessors"

let gen =
  {
    Ast_derive.structure_gen =
      (fun (tdcls : tdcls) _explict_nonrec ->
        let handle_tdcl tdcl =
          let core_type = Ast_derive_util.core_type_of_type_declaration tdcl in
          match tdcl.ptype_kind with
          | Ptype_record label_declarations ->
              Ext_list.map label_declarations
                (fun
                  ({ pld_name = { loc; txt = pld_label } as pld_name } :
                    Parsetree.label_declaration)
                ->
                  let txt = "param" in
                  Str.value Nonrecursive
                    [
                      Vb.mk (Pat.var pld_name)
                        (Exp.fun_ Nolabel None
                           (Pat.constraint_ (Pat.var { txt; loc }) core_type)
                           (Exp.field
                              (Exp.ident { txt = Lident txt; loc })
                              { txt = Longident.Lident pld_label; loc }));
                    ])
          | Ptype_variant constructor_declarations ->
              Ext_list.map constructor_declarations
                (fun
                  {
                    pcd_name = { loc; txt = con_name };
                    pcd_args;
                    pcd_loc = _;
                    pcd_res;
                  }
                ->
                  (* TODO: add type annotations *)
                  let pcd_args =
                    match pcd_args with
                    | Pcstr_tuple pcd_args -> pcd_args
                    | Pcstr_record _ -> assert false
                  in
                  let little_con_name =
                    Ext_string.uncapitalize_ascii con_name
                  in
                  let arity = List.length pcd_args in
                  let annotate_type =
                    match pcd_res with None -> core_type | Some x -> x
                  in
                  Str.value Nonrecursive
                    [
                      Vb.mk
                        (Pat.var { loc; txt = little_con_name })
                        (if arity = 0 then
                           (*TODO: add a prefix, better inter-op with FFI *)
                           Exp.constraint_
                             (Exp.construct
                                { loc; txt = Longident.Lident con_name }
                                None)
                             annotate_type
                         else
                           let vars =
                             Ext_list.init arity (fun x ->
                                 "param_" ^ string_of_int x)
                           in
                           let exp =
                             Exp.constraint_
                               (Exp.construct
                                  { loc; txt = Longident.Lident con_name }
                               @@ Some
                                    (if arity = 1 then
                                       Exp.ident
                                         { loc; txt = Lident (List.hd vars) }
                                     else
                                       Exp.tuple
                                         (Ext_list.map vars (fun x ->
                                              Exp.ident { loc; txt = Lident x })))
                               )
                               annotate_type
                           in
                           Ext_list.fold_right vars exp (fun var b ->
                               Exp.fun_ Nolabel None
                                 (Pat.var { loc; txt = var })
                                 b));
                    ])
          | Ptype_abstract | Ptype_open ->
              let loc = tdcl.ptype_loc in
              [
                [%stri
                  [%%ocaml.error
                  [%e
                    Exp.constant
                      (Pconst_string
                         (Ast_derive_util.notApplicable derivingName, loc, None))]]];
              ]
          (* Location.raise_errorf "projector only works with record" *)
        in
        Ext_list.flat_map tdcls handle_tdcl);
    signature_gen =
      (fun (tdcls : Parsetree.type_declaration list) _explict_nonrec ->
        let handle_tdcl tdcl =
          let core_type = Ast_derive_util.core_type_of_type_declaration tdcl in
          match tdcl.ptype_kind with
          | Ptype_record label_declarations ->
              Ext_list.map label_declarations
                (fun { pld_name; pld_type; pld_loc } ->
                  let loc = pld_loc in
                  Sig.value
                    (Val.mk pld_name [%type: [%t core_type] -> [%t pld_type]]))
          | Ptype_variant constructor_declarations ->
              Ext_list.map constructor_declarations
                (fun
                  {
                    pcd_name = { loc; txt = con_name };
                    pcd_args;
                    pcd_loc = _;
                    pcd_res;
                  }
                ->
                  let pcd_args =
                    match pcd_args with
                    | Pcstr_tuple pcd_args -> pcd_args
                    | Pcstr_record _ -> assert false
                  in
                  let annotate_type =
                    match pcd_res with Some x -> x | None -> core_type
                  in
                  Sig.value
                    (Val.mk
                       { loc; txt = Ext_string.uncapitalize_ascii con_name }
                       (Ext_list.fold_right pcd_args annotate_type (fun x acc ->
                            [%type: [%t x] -> [%t acc]]))))
          | Ptype_open | Ptype_abstract ->
              let loc = tdcl.ptype_loc in
              [
                [%sigi:
                  [%%ocaml.error
                  [%e
                    Exp.constant
                      (Pconst_string
                         (Ast_derive_util.notApplicable derivingName, loc, None))]]];
              ]
        in
        Ext_list.flat_map tdcls handle_tdcl);
    expression_gen = None;
  }
