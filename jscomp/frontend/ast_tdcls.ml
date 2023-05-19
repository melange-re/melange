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

open Ast_helper

(**
   [newTdcls tdcls newAttrs]
   functional update attributes of last declaration *)
let newTdcls (tdcls : Parsetree.type_declaration list)
    (newAttrs : Parsetree.attributes) : Parsetree.type_declaration list =
  match tdcls with
  | [ x ] -> [ { x with Parsetree.ptype_attributes = newAttrs } ]
  | _ ->
      Ext_list.map_last tdcls (fun last x ->
          if last then { x with Parsetree.ptype_attributes = newAttrs } else x)

let disable_unused_type : Parsetree.attribute =
  {
    attr_name = Location.mknoloc "ocaml.warning";
    attr_payload =
      PStr
        [
          Str.eval
            (Exp.constant
               (Pconst_string
                  (* -unused-type-declaration -unused-field *)
                  ("-34-69", Location.none, None)));
        ];
    attr_loc = Location.none;
  }

let handleTdclsInSigi (self : Ast_mapper.mapper)
    (sigi : Parsetree.signature_item) rf
    (tdcls : Parsetree.type_declaration list) : Ast_signature.item =
  match
    Ast_attributes.process_derive_type (Ext_list.last tdcls).ptype_attributes
  with
  | { bs_deriving = Some actions }, newAttrs ->
      let loc = sigi.psig_loc in
      let originalTdclsNewAttrs =
        newTdcls tdcls (disable_unused_type :: newAttrs)
      in
      (* remove the processed attr*)
      let newTdclsNewAttrs =
        List.map (self.type_declaration self) originalTdclsNewAttrs
      in
      let kind = Ast_derive_abstract.isAbstract actions in
      if kind <> Not_abstract then
        let codes =
          Ast_derive_abstract.handleTdclsInSig ~light:(kind = Light_abstract) rf
            originalTdclsNewAttrs
        in
        Ast_signature.fuseAll ~loc
          (Sig.include_ ~loc
             (Incl.mk ~loc
                (Mty.typeof_ ~loc
                   (Mod.constraint_ ~loc
                      (Mod.structure ~loc
                         [
                           Ast_compatible.rec_type_str ~loc rf newTdclsNewAttrs;
                         ])
                      (Mty.signature ~loc []))))
          :: (* include module type of struct [processed_code for checking like invariance ]end *)
             self.signature self codes)
      else
        Ast_signature.fuseAll ~loc
          (Ast_compatible.rec_type_sig ~loc rf newTdclsNewAttrs
          :: self.signature self (Ast_derive.gen_signature tdcls actions rf))
  | { bs_deriving = None }, _ ->
      Ast_mapper.default_mapper.signature_item self sigi

let handleTdclsInStru (self : Ast_mapper.mapper)
    (str : Parsetree.structure_item) rf
    (tdcls : Parsetree.type_declaration list) : Ast_structure.item =
  match
    Ast_attributes.process_derive_type (Ext_list.last tdcls).ptype_attributes
  with
  | { bs_deriving = Some actions }, newAttrs ->
      let loc = str.pstr_loc in
      let originalTdclsNewAttrs =
        newTdcls tdcls (disable_unused_type :: newAttrs)
      in
      let newStr : Parsetree.structure_item =
        Ast_compatible.rec_type_str ~loc rf
          (List.map (self.type_declaration self) originalTdclsNewAttrs)
      in
      let kind = Ast_derive_abstract.isAbstract actions in
      if kind <> Not_abstract then
        let codes =
          Ast_derive_abstract.handleTdclsInStr ~light:(kind = Light_abstract) rf
            originalTdclsNewAttrs
        in
        (* use [tdcls2] avoid nonterminating *)
        Ast_structure.fuseAll ~loc
          (Ast_structure.constraint_ ~loc [ newStr ] []
          :: (* [include struct end : sig end] for error checking *)
             self.structure self codes)
      else
        Ast_structure.fuseAll ~loc
          (newStr
          :: self.structure self
               (Ext_list.filter_map actions (fun action ->
                    Ast_derive.gen_structure_signature loc tdcls action rf)))
  | { bs_deriving = None }, _ ->
      Ast_mapper.default_mapper.structure_item self str
