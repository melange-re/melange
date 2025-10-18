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

let get_pld_type pld_type ~attrs =
  let is_optional = Ast_attributes.has_mel_optional attrs in
  match is_optional with
  | true -> (
      match pld_type.ptyp_desc with
      | Ptyp_constr ({ txt = Lident "option"; _ }, [ pld_type ]) -> pld_type
      | _ ->
          Location.raise_errorf ~loc:pld_type.ptyp_loc
            "`[@mel.optional]' must appear on an option literal type (`_ \
             option')")
  | false -> pld_type

let derive_js_constructor =
  let do_alert_deprecated ~loc =
    Mel_ast_invariant.warn_raw ~loc ~kind:"deprecated"
      "`@@deriving abstract' deprecated. Use `@@deriving jsProperties, getSet' \
       instead."
  in
  let ffi_of_option_labels labels ~ends_with_unit =
    Melange_ffi.External_ffi_types.ffi_obj_create
      (List.fold_right labels
         ~init:
           (if ends_with_unit then
              [ Melange_ffi.External_arg_spec.empty_kind Extern_unit ]
            else [])
         ~f:(fun ((is_option, p) : bool * string Asttypes.loc) arg_kinds ->
           let obj_arg_label =
             let label_name = Melange_ffi.Lam_methname.translate p.txt in
             match is_option with
             | true ->
                 Melange_ffi.External_arg_spec.Obj_label.optional
                   ~for_sure_no_nested_option:false label_name
             | false -> Melange_ffi.External_arg_spec.Obj_label.obj label_name
           in
           {
             Melange_ffi.External_arg_spec.Param.arg_type = Nothing;
             arg_label = obj_arg_label;
           }
           :: arg_kinds))
  in
  fun ?(is_deprecated = false) tdcl ->
    match tdcl.ptype_kind with
    | Ptype_record label_declarations -> (
        let has_optional_field =
          List.exists
            ~f:(fun (x : label_declaration) ->
              Ast_attributes.has_mel_optional x.pld_attributes)
            label_declarations
        in
        let loc = tdcl.ptype_loc in
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
                match is_optional with
                | true ->
                    let pld_type =
                      get_pld_type ~attrs:pld_attributes pld_type
                    in
                    Typ.arrow ~loc:pld_loc (Optional label_name) pld_type maker
                | false ->
                    Typ.arrow ~loc:pld_loc (Labelled label_name) pld_type maker
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
            if is_deprecated then do_alert_deprecated ~loc;
            [
              Val.mk ~loc
                { loc; txt = tdcl.ptype_name.txt }
                ~attrs:
                  [
                    Ast_attributes.mel_ffi
                      (ffi_of_option_labels labels
                         ~ends_with_unit:has_optional_field);
                    Ast_attributes.unboxable_type_in_prim_decl;
                  ]
                ~prim:Ast_external.pval_prim_default makeType;
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
  fun ~light tdcl ->
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
              let name =
                if light then pld_name
                else { pld_name with txt = pld_name.txt ^ "Get" }
              in
              match Ast_attributes.has_mel_optional pld_attributes with
              | true ->
                  Val.mk ~loc:pld_loc name ~attrs:get_optional_attrs ~prim
                    [%type: [%t core_type] -> [%t pld_type]]
                  :: acc
              | false ->
                  Val.mk ~loc:pld_loc name
                    ~attrs:
                      (Ast_attributes.mel_ffi
                         (* Not needed actually *)
                         (Melange_ffi.External_ffi_types.ffi_mel
                            [ Melange_ffi.External_arg_spec.dummy ]
                            Return_identity
                            (Js_get { name = prim_as_name; scopes = [] }))
                      :: get_attrs)
                    ~prim:Ast_external.pval_prim_default
                    [%type: [%t core_type] -> [%t pld_type]]
                  :: acc
            in
            match pld_mutable with
            | Mutable ->
                let pld_type = get_pld_type pld_type ~attrs:pld_attributes in
                Val.mk ~loc:pld_loc
                  { loc = label_loc; txt = label_name ^ "Set" } (* setter *)
                  ~attrs:set_attrs ~prim
                  [%type: [%t core_type] -> [%t pld_type] -> unit]
                :: acc
            | Immutable -> acc)
          label_declarations ~init:[]
    | Ptype_abstract | Ptype_variant _ | Ptype_open ->
        (* Looks obvious that it does not make sense to warn *)
        []

let derive_js_constructor_str tdcls =
  List.fold_right tdcls ~init:[] ~f:(fun tdcl sts ->
      let value_descriptions = derive_js_constructor tdcl in
      List.map ~f:Str.primitive value_descriptions @ sts)

let derive_js_constructor_sig tdcls =
  List.fold_right tdcls ~init:[] ~f:(fun tdcl sts ->
      let value_descriptions = derive_js_constructor tdcl in
      List.map ~f:Sig.value value_descriptions @ sts)

let derive_getters_setters_str ~light tdcls =
  List.fold_right tdcls ~init:[] ~f:(fun tdcl sts ->
      let value_descriptions = derive_getters_setters tdcl ~light in
      List.map ~f:Str.primitive value_descriptions @ sts)

let derive_getters_setters_sig ~light tdcls =
  List.fold_right tdcls ~init:[] ~f:(fun tdcl sts ->
      let value_descriptions = derive_getters_setters ~light tdcl in
      List.map ~f:Sig.value value_descriptions @ sts)

let derive_abstract_str ~light tdcls =
  List.fold_right tdcls ~init:[] ~f:(fun tdcl sts ->
      let cstr_descriptions = derive_js_constructor ~is_deprecated:true tdcl
      and value_descriptions = derive_getters_setters ~light tdcl in
      List.map ~f:Str.primitive (cstr_descriptions @ value_descriptions) @ sts)

let derive_abstract_sig ~light tdcls =
  List.fold_right tdcls ~init:[] ~f:(fun tdcl sts ->
      let cstr_descriptions = derive_js_constructor ~is_deprecated:true tdcl
      and value_descriptions = derive_getters_setters ~light tdcl in
      List.map (cstr_descriptions @ value_descriptions) ~f:Sig.value @ sts)
