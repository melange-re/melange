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

open Import
open Ast_helper

let derivingName = "accessors"
let ghost loc = { loc with Location.loc_ghost = true }

let ghost_locations =
  object
    inherit Ast_traverse.map
    method! location = ghost
  end

let derive_structure tdcls =
  let handle_tdcl tdcl =
    let core_type =
      ghost_locations#core_type
        (Ast_derive_util.core_type_of_type_declaration tdcl)
    in
    match tdcl.ptype_kind with
    | Ptype_record label_declarations ->
        List.map
          ~f:(fun
              {
                pld_name = { loc = source_loc; txt = pld_label } as pld_name;
                _;
              }
            ->
            let loc = ghost source_loc in
            let pld_name = { pld_name with loc } in
            let txt = "param" in
            Str.value ~loc Nonrecursive
              [
                Vb.mk ~loc (Pat.var ~loc pld_name)
                  (Exp.fun_ ~loc Nolabel None
                     (Pat.constraint_ ~loc
                        (Pat.var ~loc { txt; loc })
                        core_type)
                     (Exp.field ~loc
                        (Exp.ident ~loc { txt = Lident txt; loc })
                        { txt = Longident.Lident pld_label; loc }));
              ])
          label_declarations
    | Ptype_variant constructor_declarations ->
        List.map
          ~f:(fun
              {
                pcd_name = { loc = source_loc; txt = con_name };
                pcd_args;
                pcd_loc = _;
                pcd_res;
                _;
              }
            ->
            let loc = ghost source_loc in
            (* TODO: add type annotations *)
            let pcd_args =
              match pcd_args with
              | Pcstr_tuple pcd_args -> pcd_args
              | Pcstr_record _ -> assert false
            in
            let little_con_name = String.uncapitalize_ascii con_name in
            let annotate_type =
              match pcd_res with
              | None -> core_type
              | Some core_type -> ghost_locations#core_type core_type
            in
            Str.value ~loc Nonrecursive
              [
                Vb.mk ~loc
                  (Pat.var ~loc { loc; txt = little_con_name })
                  (match pcd_args with
                  | [] ->
                      (*TODO: add a prefix, better inter-op with FFI *)
                      Exp.constraint_ ~loc
                        (Exp.construct ~loc
                           { loc; txt = Longident.Lident con_name }
                           None)
                        annotate_type
                  | _ :: _ ->
                      let vars =
                        List.mapi
                          ~f:(fun x _ -> "param_" ^ string_of_int x)
                          pcd_args
                      in
                      let exp =
                        Exp.constraint_ ~loc
                          (Exp.construct ~loc
                             { loc; txt = Longident.Lident con_name }
                          @@ Some
                               (match vars with
                               | [ var ] ->
                                   Exp.ident ~loc { loc; txt = Lident var }
                               | vars ->
                                   Exp.tuple ~loc
                                     (List.map
                                        ~f:(fun x ->
                                          Exp.ident ~loc { loc; txt = Lident x })
                                        vars)))
                          annotate_type
                      in
                      List.fold_right
                        ~f:(fun var b ->
                          Ast_builder.Default.pexp_fun ~loc Nolabel None
                            (Pat.var ~loc { loc; txt = var })
                            b)
                        vars ~init:exp);
              ])
          constructor_declarations
    | Ptype_abstract | Ptype_open ->
        let loc = tdcl.ptype_name.loc in
        [
          [%stri
            [%%ocaml.error
            [%e
              Exp.constant ~loc
                (Pconst_string
                   (Ast_derive_util.notApplicable derivingName, loc, None))]]];
        ]
  in
  List.concat_map ~f:handle_tdcl tdcls

let derive_signature tdcls =
  let handle_tdcl tdcl =
    let core_type =
      ghost_locations#core_type
        (Ast_derive_util.core_type_of_type_declaration tdcl)
    in
    match tdcl.ptype_kind with
    | Ptype_record label_declarations ->
        List.map
          ~f:(fun
              { pld_name = { loc = source_loc; _ } as pld_name; pld_type; _ } ->
            let loc = ghost source_loc in
            let pld_name = { pld_name with loc } in
            let pld_type = ghost_locations#core_type pld_type in
            Sig.value ~loc
              (Val.mk ~loc pld_name [%type: [%t core_type] -> [%t pld_type]]))
          label_declarations
    | Ptype_variant constructor_declarations ->
        List.map
          ~f:(fun
              {
                pcd_name = { loc = source_loc; txt = con_name };
                pcd_args;
                pcd_loc = _;
                pcd_res;
                _;
              }
            ->
            let loc = ghost source_loc in
            let pcd_args =
              match pcd_args with
              | Pcstr_tuple pcd_args ->
                  List.map
                    ~f:(fun core_type -> ghost_locations#core_type core_type)
                    pcd_args
              | Pcstr_record _ -> assert false
            in
            let annotate_type =
              match pcd_res with
              | Some core_type -> ghost_locations#core_type core_type
              | None -> core_type
            in
            Sig.value ~loc
              (Val.mk ~loc
                 { loc; txt = String.uncapitalize_ascii con_name }
                 (List.fold_right
                    ~f:(fun x acc -> [%type: [%t x] -> [%t acc]])
                    pcd_args ~init:annotate_type)))
          constructor_declarations
    | Ptype_open | Ptype_abstract ->
        let loc = tdcl.ptype_name.loc in
        [
          [%sigi:
            [%%ocaml.error
            [%e
              Exp.constant ~loc
                (Pconst_string
                   (Ast_derive_util.notApplicable derivingName, loc, None))]]];
        ]
  in
  List.concat_map ~f:handle_tdcl tdcls
