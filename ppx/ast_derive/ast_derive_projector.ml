(* Copyright (C) 2017 Authors of ReScript
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

open Ppxlib

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
              List.map
                (fun ({ pld_name = { loc; txt = pld_label } as pld_name } :
                       Parsetree.label_declaration) ->
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
                label_declarations
          | Ptype_variant constructor_declarations ->
              List.map
                (fun {
                       Parsetree.pcd_name = { loc; txt = con_name };
                       pcd_args;
                       pcd_loc = _;
                       pcd_res;
                     } ->
                  (* TODO: add type annotations *)
                  let pcd_args =
                    match pcd_args with
                    | Pcstr_tuple pcd_args -> pcd_args
                    | Pcstr_record _ -> assert false
                  in
                  let little_con_name = String.uncapitalize_ascii con_name in
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
                             List.init arity (fun x ->
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
                                         (List.map
                                            (fun x ->
                                              Exp.ident { loc; txt = Lident x })
                                            vars)))
                               annotate_type
                           in
                           List.fold_right
                             (fun var b ->
                               Exp.fun_ Nolabel None
                                 (Pat.var { loc; txt = var })
                                 b)
                             vars exp);
                    ])
                constructor_declarations
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
        List.concat_map handle_tdcl tdcls);
    signature_gen =
      (fun (tdcls : Parsetree.type_declaration list) _explict_nonrec ->
        let handle_tdcl tdcl =
          let core_type = Ast_derive_util.core_type_of_type_declaration tdcl in
          match tdcl.ptype_kind with
          | Ptype_record label_declarations ->
              List.map
                (fun { Parsetree.pld_name; pld_type; pld_loc } ->
                  let loc = pld_loc in
                  Sig.value
                    (Val.mk pld_name [%type: [%t core_type] -> [%t pld_type]]))
                label_declarations
          | Ptype_variant constructor_declarations ->
              List.map
                (fun {
                       Parsetree.pcd_name = { loc; txt = con_name };
                       pcd_args;
                       pcd_loc = _;
                       pcd_res;
                     } ->
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
                       { loc; txt = String.uncapitalize_ascii con_name }
                       (List.fold_right
                          (fun x acc -> [%type: [%t x] -> [%t acc]])
                          pcd_args annotate_type)))
                constructor_declarations
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
        List.concat_map handle_tdcl tdcls);
    expression_gen = None;
  }
