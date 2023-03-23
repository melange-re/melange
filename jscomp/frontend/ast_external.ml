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

(* We disable warning 61 in Melange externals since they're substantially
   different from OCaml externals. This warning doesn't make sense for a JS
   runtime *)
let unboxable_type_in_prim_decl : Parsetree.attribute =
  let open Ast_helper in
  {
    attr_name = Location.mknoloc "ocaml.warning";
    attr_payload =
      PStr
        [
          Str.eval
            (Exp.constant
               (Pconst_string
                  ("-unboxable-type-in-prim-decl", Location.none, None)));
        ];
    attr_loc = Location.none;
  }

let handleExternalInSig self (prim : Parsetree.value_description)
    (sigi : Parsetree.signature_item) : Parsetree.signature_item =
  let loc = prim.pval_loc in
  let pval_type = self#core_type prim.pval_type in
  let pval_attributes = self#attributes prim.pval_attributes in
  match prim.pval_prim with
  | [] -> Location.raise_errorf ~loc "empty primitive string"
  | a :: b :: _ ->
      Location.raise_errorf ~loc
        "only a single string is allowed in bs external %S %S" a b
  | [ v ] -> (
      match
        Ast_external_process.handle_attributes_as_string loc pval_type
          pval_attributes prim.pval_name.txt v
      with
      | { pval_type; pval_prim; pval_attributes; no_inline_cross_module } ->
          {
            sigi with
            psig_desc =
              Psig_value
                {
                  prim with
                  pval_type;
                  pval_prim = (if no_inline_cross_module then [] else pval_prim);
                  pval_attributes =
                    unboxable_type_in_prim_decl :: pval_attributes;
                };
          })

let handleExternalInStru self (prim : Parsetree.value_description)
    (str : Parsetree.structure_item) : Parsetree.structure_item =
  let loc = prim.pval_loc in
  let pval_type = self#core_type prim.pval_type in
  let pval_attributes = self#attributes prim.pval_attributes in
  match prim.pval_prim with
  | [] -> Location.raise_errorf ~loc "empty primitive string"
  | a :: b :: _ ->
      Location.raise_errorf ~loc
        "only a single string is allowed in bs external %S : %S" a b
  | [ v ] -> (
      match
        Ast_external_process.handle_attributes_as_string loc pval_type
          pval_attributes prim.pval_name.txt v
      with
      | { pval_type; pval_prim; pval_attributes; no_inline_cross_module } ->
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
                      unboxable_type_in_prim_decl :: pval_attributes;
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
                       ]))))
