(* Copyright (C) 2018 Hongbo Zhang, Authors of ReScript
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

let single_string_payload_error ~loc =
  Ast_helper.Exp.constant
    (Pconst_string
       ("Melange requires a single string in `external` payloads", loc, None))

let handleExternalInSig (self : Ast_traverse.map) (prim : value_description)
    (sigi : signature_item) : signature_item =
  let loc = prim.pval_loc in
  let pval_type = self#core_type prim.pval_type in
  let pval_attributes = self#attributes prim.pval_attributes in
  match prim.pval_prim with
  | [] -> Location.raise_errorf ~loc "empty primitive string"
  | _ :: _ :: _ ->
      [%sigi: [%%ocaml.error [%e single_string_payload_error ~loc]]]
  | [ v ] ->
      let {
        Ast_external_process.pval_type;
        pval_prim;
        pval_attributes;
        no_inline_cross_module;
      } =
        Ast_external_process.handle_attributes_as_string loc pval_type
          pval_attributes prim.pval_name.txt v
      in

      {
        sigi with
        psig_desc =
          Psig_value
            {
              prim with
              pval_type;
              pval_prim = (if no_inline_cross_module then [] else pval_prim);
              pval_attributes =
                Ast_attributes.unboxable_type_in_prim_decl :: pval_attributes;
            };
      }

let handleExternalInStru (self : Ast_traverse.map) (prim : value_description)
    (str : structure_item) : structure_item =
  let loc = prim.pval_loc in
  let pval_type = self#core_type prim.pval_type in
  let pval_attributes = self#attributes prim.pval_attributes in
  match prim.pval_prim with
  | [] -> Location.raise_errorf ~loc "empty primitive string"
  | _ :: _ :: _ -> [%stri [%%ocaml.error [%e single_string_payload_error ~loc]]]
  | [ v ] ->
      let {
        Ast_external_process.pval_type;
        pval_prim;
        pval_attributes;
        no_inline_cross_module;
      } =
        Ast_external_process.handle_attributes_as_string loc pval_type
          pval_attributes prim.pval_name.txt v
      in
      let external_result =
        {
          str with
          pstr_desc =
            Pstr_primitive
              {
                prim with
                pval_type;
                pval_prim;
                pval_attributes =
                  Ast_attributes.unboxable_type_in_prim_decl :: pval_attributes;
              };
        }
      in
      if not no_inline_cross_module then external_result
      else
        let open Ast_helper in
        Str.include_ ~loc
          (Incl.mk ~loc
             (Mod.constraint_ ~loc
                (Mod.structure ~loc [ external_result ])
                (Mty.signature ~loc
                   [
                     {
                       psig_desc =
                         Psig_value
                           {
                             prim with
                             pval_type;
                             pval_prim = [];
                             pval_attributes;
                           };
                       psig_loc = loc;
                     };
                   ])))
