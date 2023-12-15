(* Copyright (C) 2017 Hongbo Zhang, Authors of ReScript
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

(** For this attributes, its type was wrapped as an option,
   so we can still reuse existing frame work
*)
let get_optional_attrs =
  [ Ast_attributes.mel_get; Ast_attributes.mel_return_undefined ]

let get_attrs = Ast_attributes.[ mel_get_arity; unboxable_type_in_prim_decl ]
let set_attrs = Ast_attributes.[ mel_set; unboxable_type_in_prim_decl ]

let get_pld_type pld_type ~attrs =
  let is_optional = Ast_attributes.has_mel_optional attrs in
  if is_optional then
    match pld_type.ptyp_desc with
    | Ptyp_constr ({ txt = Lident "option"; _ }, [ pld_type ]) -> pld_type
    | _ ->
        Location.raise_errorf ~loc:pld_type.ptyp_loc
          "`[@mel.optional]' must appear on an option literal type (`_ option')"
  else pld_type

let derive_js_constructor (tdcl : Parsetree.type_declaration) :
    Parsetree.value_description list =
  let loc = tdcl.ptype_loc in
  let type_name = tdcl.ptype_name.txt in
  let core_type = Ast_derive_util.core_type_of_type_declaration tdcl in
  match tdcl.ptype_kind with
  | Ptype_record label_declarations ->
      let is_private = tdcl.ptype_private = Private in
      let has_optional_field =
        List.exists
          ~f:(fun (x : Parsetree.label_declaration) ->
            Ast_attributes.has_mel_optional x.pld_attributes)
          label_declarations
      in
      let makeType, labels =
        List.fold_right
          ~f:(fun
              ({
                 pld_name = { txt = label_name; loc = _ } as pld_name;
                 pld_type;
                 pld_attributes;
                 pld_loc;
                 _;
               } :
                Parsetree.label_declaration)
              (maker, labels)
            ->
            let newLabel =
              match
                Ast_attributes.iter_process_mel_string_as pld_attributes
              with
              | None -> pld_name
              | Some new_name -> { pld_name with txt = new_name }
            in
            let is_optional = Ast_attributes.has_mel_optional pld_attributes in
            let maker =
              if is_optional then
                let pld_type = get_pld_type ~attrs:pld_attributes pld_type in
                Typ.arrow ~loc:pld_loc (Optional label_name) pld_type maker
              else Typ.arrow ~loc:pld_loc (Labelled label_name) pld_type maker
            in
            (maker, (is_optional, newLabel) :: labels))
          label_declarations
          ~init:
            ( (if has_optional_field then [%type: unit -> [%t core_type]]
               else core_type),
              [] )
      in
      if is_private then []
      else
        let myPrims =
          Ast_external_mk.pval_prim_of_option_labels labels has_optional_field
        in
        let myMaker =
          Val.mk ~loc { loc; txt = type_name }
            ~attrs:[ Ast_attributes.unboxable_type_in_prim_decl ]
            ~prim:myPrims makeType
        in
        [ myMaker ]
  | Ptype_abstract | Ptype_variant _ | Ptype_open ->
      (* Looks obvious that it does not make sense to warn *)
      []

let derive_js_constructor_str _rf tdcls =
  List.fold_right
    ~f:(fun tdcl sts ->
      let value_descriptions = derive_js_constructor tdcl in
      List.map ~f:Str.primitive value_descriptions @ sts)
    tdcls ~init:[]

let derive_js_constructor_sig _rf tdcls =
  List.fold_right
    ~f:(fun tdcl sts ->
      let value_descriptions = derive_js_constructor tdcl in
      List.map ~f:Sig.value value_descriptions @ sts)
    tdcls ~init:[]

let derive_getters_setters ~light (tdcl : Parsetree.type_declaration) :
    Parsetree.value_description list =
  let loc = tdcl.ptype_loc in
  let core_type = Ast_derive_util.core_type_of_type_declaration tdcl in
  match tdcl.ptype_kind with
  | Ptype_record label_declarations ->
      List.fold_right
        ~f:(fun
            ({
               pld_name = { txt = label_name; loc = label_loc } as pld_name;
               pld_type;
               pld_mutable;
               pld_attributes;
               pld_loc;
             } :
              Parsetree.label_declaration)
            acc
          ->
          let prim_as_name =
            match Ast_attributes.iter_process_mel_string_as pld_attributes with
            | None -> label_name
            | Some new_name -> new_name
          in
          let prim = [ prim_as_name ] in
          let acc =
            if Ast_attributes.has_mel_optional pld_attributes then
              let optional_type = pld_type in
              Val.mk ~loc:pld_loc
                (if light then pld_name
                 else { pld_name with txt = pld_name.txt ^ "Get" })
                ~attrs:get_optional_attrs ~prim
                [%type: [%t core_type] -> [%t optional_type]]
              :: acc
            else
              Val.mk ~loc:pld_loc
                (if light then pld_name
                 else { pld_name with txt = pld_name.txt ^ "Get" })
                ~attrs:get_attrs
                ~prim:
                  ((* Not needed actually*)
                   Melange_ffi.External_ffi_types.ffi_mel_as_prims
                     [ Melange_ffi.External_arg_spec.dummy ]
                     Return_identity
                     (Js_get { js_get_name = prim_as_name; js_get_scopes = [] }))
                [%type: [%t core_type] -> [%t pld_type]]
              :: acc
          in
          match pld_mutable with
          | Mutable ->
              let pld_type = get_pld_type pld_type ~attrs:pld_attributes in
              let setter_type =
                [%type: [%t core_type] -> [%t pld_type] -> unit]
              in
              Val.mk ~loc:pld_loc
                { loc = label_loc; txt = label_name ^ "Set" } (* setter *)
                ~attrs:set_attrs ~prim setter_type
              :: acc
          | Immutable -> acc)
        label_declarations ~init:[]
  | Ptype_abstract | Ptype_variant _ | Ptype_open ->
      (* Looks obvious that it does not make sense to warn *)
      []

let derive_getters_setters_str ~light _rf tdcls =
  List.fold_right
    ~f:(fun tdcl sts ->
      let value_descriptions = derive_getters_setters tdcl ~light in
      List.map ~f:Str.primitive value_descriptions @ sts)
    tdcls ~init:[]

let derive_getters_setters_sig ~light _rf tdcls =
  List.fold_right
    ~f:(fun tdcl sts ->
      let value_descriptions = derive_getters_setters ~light tdcl in
      List.map ~f:Sig.value value_descriptions @ sts)
    tdcls ~init:[]

let handleTdclsInStr ~light _rf tdcls =
  List.fold_right
    ~f:(fun tdcl sts ->
      let cstr_descriptions = derive_js_constructor tdcl in
      let value_descriptions = derive_getters_setters ~light tdcl in
      List.map ~f:Str.primitive (cstr_descriptions @ value_descriptions) @ sts)
    tdcls ~init:[]

let handleTdclsInSig ~light _rf tdcls =
  List.fold_right
    ~f:(fun tdcl sts ->
      let cstr_descriptions = derive_js_constructor tdcl in
      let value_descriptions = derive_getters_setters ~light tdcl in
      List.map ~f:Sig.value (cstr_descriptions @ value_descriptions) @ sts)
    tdcls ~init:[]
