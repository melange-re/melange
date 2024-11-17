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

let deprecated_abstract =
  let loc = Location.none in
  {
    attr_name = { txt = "alert"; loc };
    attr_payload =
      PStr
        [
          [%stri
            deprecated
              "`@@deriving abstract' deprecated. Use `@@deriving jsProperties, \
               getSet' instead."];
        ];
    attr_loc = loc;
  }

let with_deprecation ~is_deprecated attrs =
  match is_deprecated with
  | false -> attrs
  | true -> deprecated_abstract :: attrs

let get_pld_type pld_type ~attrs =
  let is_optional = Ast_attributes.has_mel_optional attrs in
  if is_optional then
    match pld_type.ptyp_desc with
    | Ptyp_constr ({ txt = Lident "option"; _ }, [ pld_type ]) -> pld_type
    | _ ->
        Location.raise_errorf ~loc:pld_type.ptyp_loc
          "`[@mel.optional]' must appear on an option literal type (`_ option')"
  else pld_type

let derive_js_constructor =
  let pval_prim_of_option_labels (labels : (bool * string Asttypes.loc) list)
      (ends_with_unit : bool) =
    let arg_kinds =
      List.fold_right
        ~f:(fun (is_option, p) arg_kinds ->
          let label_name = Melange_ffi.Lam_methname.translate p.txt in
          let obj_arg_label =
            if is_option then
              Melange_ffi.External_arg_spec.optional false label_name
            else Melange_ffi.External_arg_spec.obj_label label_name
          in
          {
            Melange_ffi.External_arg_spec.arg_type = Nothing;
            arg_label = obj_arg_label;
          }
          :: arg_kinds)
        labels
        ~init:
          (if ends_with_unit then
             [ Melange_ffi.External_arg_spec.empty_kind Extern_unit ]
           else [])
    in
    Melange_ffi.External_ffi_types.ffi_obj_as_prims arg_kinds
  in
  fun ?(is_deprecated = false) tdcl ->
    match tdcl.ptype_kind with
    | Ptype_record label_declarations -> (
        let loc = tdcl.ptype_loc in
        let has_optional_field =
          List.exists
            ~f:(fun (x : label_declaration) ->
              Ast_attributes.has_mel_optional x.pld_attributes)
            label_declarations
        in
        let makeType, labels =
          List.fold_right
            ~f:(fun
                {
                  pld_name = { txt = label_name; loc = _ } as pld_name;
                  pld_type;
                  pld_attributes;
                  pld_loc;
                  _;
                }
                (maker, labels)
              ->
              let newLabel =
                match
                  Ast_attributes.iter_process_mel_string_as pld_attributes
                with
                | None -> pld_name
                | Some new_name -> { pld_name with txt = new_name }
              in
              let is_optional =
                Ast_attributes.has_mel_optional pld_attributes
              in
              let maker =
                if is_optional then
                  let pld_type = get_pld_type ~attrs:pld_attributes pld_type in
                  Typ.arrow ~loc:pld_loc (Optional label_name) pld_type maker
                else Typ.arrow ~loc:pld_loc (Labelled label_name) pld_type maker
              in
              (maker, (is_optional, newLabel) :: labels))
            label_declarations
            ~init:
              ( (let core_type =
                   Ast_derive_util.core_type_of_type_declaration tdcl
                 in
                 if has_optional_field then [%type: unit -> [%t core_type]]
                 else core_type),
                [] )
        in
        match tdcl.ptype_private with
        | Private -> []
        | Public ->
            let myPrims =
              pval_prim_of_option_labels labels has_optional_field
            in
            [
              Val.mk ~loc
                { loc; txt = tdcl.ptype_name.txt }
                ~attrs:
                  (with_deprecation ~is_deprecated
                     [ Ast_attributes.unboxable_type_in_prim_decl ])
                ~prim:myPrims makeType;
            ])
    | Ptype_abstract | Ptype_variant _ | Ptype_open ->
        (* Looks obvious that it does not make sense to warn *)
        []

let derive_getters_setters =
  let get_optional_attrs =
    (* For these attributes, its type was wrapped as an option,
       so we can still reuse existing framework *)
    [ Ast_attributes.mel_get; Ast_attributes.mel_return_undefined ]
  in
  let get_attrs =
    Ast_attributes.[ mel_get_arity; unboxable_type_in_prim_decl ]
  in
  let set_attrs = Ast_attributes.[ mel_set; unboxable_type_in_prim_decl ] in
  fun ?(is_deprecated = false) ~light tdcl ->
    match tdcl.ptype_kind with
    | Ptype_record label_declarations ->
        let loc = tdcl.ptype_loc in
        let core_type = Ast_derive_util.core_type_of_type_declaration tdcl in
        List.fold_right
          ~f:(fun
              {
                pld_name = { txt = label_name; loc = label_loc } as pld_name;
                pld_type;
                pld_mutable;
                pld_attributes;
                pld_loc;
              }
              acc
            ->
            let prim_as_name =
              match
                Ast_attributes.iter_process_mel_string_as pld_attributes
              with
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
                  ~attrs:(with_deprecation ~is_deprecated get_attrs)
                  ~prim:
                    ((* Not needed actually*)
                     Melange_ffi.External_ffi_types.ffi_mel_as_prims
                       [ Melange_ffi.External_arg_spec.dummy ]
                       Return_identity
                       (Js_get
                          { js_get_name = prim_as_name; js_get_scopes = [] }))
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
                  ~attrs:(with_deprecation ~is_deprecated set_attrs)
                  ~prim setter_type
                :: acc
            | Immutable -> acc)
          label_declarations ~init:[]
    | Ptype_abstract | Ptype_variant _ | Ptype_open ->
        (* Looks obvious that it does not make sense to warn *)
        []

let derive_js_constructor_str tdcls =
  List.fold_right
    ~f:(fun tdcl sts ->
      let value_descriptions = derive_js_constructor tdcl in
      List.map ~f:Str.primitive value_descriptions @ sts)
    tdcls ~init:[]

let derive_js_constructor_sig tdcls =
  List.fold_right
    ~f:(fun tdcl sts ->
      let value_descriptions = derive_js_constructor tdcl in
      List.map ~f:Sig.value value_descriptions @ sts)
    tdcls ~init:[]

let derive_getters_setters_str ~light tdcls =
  List.fold_right
    ~f:(fun tdcl sts ->
      let value_descriptions = derive_getters_setters tdcl ~light in
      List.map ~f:Str.primitive value_descriptions @ sts)
    tdcls ~init:[]

let derive_getters_setters_sig ~light tdcls =
  List.fold_right
    ~f:(fun tdcl sts ->
      let value_descriptions = derive_getters_setters ~light tdcl in
      List.map ~f:Sig.value value_descriptions @ sts)
    tdcls ~init:[]

let derive_abstract_str ~light tdcls =
  List.fold_right
    ~f:(fun tdcl sts ->
      let cstr_descriptions = derive_js_constructor ~is_deprecated:true tdcl in
      let value_descriptions =
        derive_getters_setters ~is_deprecated:true ~light tdcl
      in
      List.map ~f:Str.primitive (cstr_descriptions @ value_descriptions) @ sts)
    tdcls ~init:[]

let derive_abstract_sig ~light tdcls =
  List.fold_right
    ~f:(fun tdcl sts ->
      let cstr_descriptions = derive_js_constructor ~is_deprecated:true tdcl in
      let value_descriptions =
        derive_getters_setters ~is_deprecated:true ~light tdcl
      in
      List.map ~f:Sig.value (cstr_descriptions @ value_descriptions) @ sts)
    tdcls ~init:[]
