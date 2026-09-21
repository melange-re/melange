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
module U = Ast_derive_util

let noloc = Location.none
let ghost loc = { loc with Location.loc_ghost = true }

let ghost_locations =
  object
    inherit Ast_traverse.map
    method! location = ghost
  end

let js_field ~loc o m =
  [%expr
    [%e Exp.ident ~loc { txt = Lident "##"; loc }] [%e o] [%e Exp.ident ~loc m]]

(* [eraseType] will be instrumented, be careful about the name conflict*)
let eraseTypeLit = "_eraseType"
let eraseTypeExp ~loc = Exp.ident ~loc { loc; txt = Lident eraseTypeLit }
let eraseType ~loc x = [%expr [%e eraseTypeExp ~loc] [%e x]]

let eraseTypeStr =
  let loc = noloc in
  Str.primitive
    (Val.mk ~prim:[ "%identity" ]
       { loc = noloc; txt = eraseTypeLit }
       [%type: _ -> _])

let unsafeIndex = "_index"

let unsafeIndexGet =
  let loc = noloc in
  Str.primitive
    (Val.mk ~prim:[ "" ]
       { loc = noloc; txt = unsafeIndex }
       ~attrs:[ Ast_attributes.mel_get_index ]
       [%type: _ -> _ -> _])

let unsafeIndexGetExp ~loc = Exp.ident ~loc { loc; txt = Lident unsafeIndex }

(* JavaScript has allowed trailing commas in array literals since the beginning,
   and later added them to object literals (ECMAScript 5) and most recently (ECMAScript 2017)
   to function parameters. *)
let add_key_value buf key value last =
  Buffer.add_char buf '"';
  Buffer.add_string buf key;
  Buffer.add_string buf "\":\"";
  Buffer.add_string buf value;
  if last then Buffer.add_string buf "\"" else Buffer.add_string buf "\","

let buildMap =
  let rec aux (row_fields : row_field list) buf revbuf has_mel_as =
    match row_fields with
    | [] -> ()
    | tag :: rest ->
        (match tag.prf_desc with
        | Rtag ({ txt; _ }, _, []) ->
            let name : string =
              match
                Ast_attributes.iter_process_mel_string_as tag.prf_attributes
              with
              | Some name ->
                  has_mel_as := true;
                  name
              | None -> txt
            in
            let last = rest = [] in
            add_key_value buf txt name last;
            add_key_value revbuf name txt last
        | _ -> assert false (* checked by [is_enum_polyvar] *));
        aux rest buf revbuf has_mel_as
  in
  fun (row_fields : row_field list) ->
    let has_mel_as = ref false in
    let data, revData =
      let buf = Buffer.create 50 in
      let revbuf = Buffer.create 50 in
      Buffer.add_string buf "{";
      Buffer.add_string revbuf "{";
      aux row_fields buf revbuf has_mel_as;
      Buffer.add_string buf "}";
      Buffer.add_string revbuf "}";
      (Buffer.contents buf, Buffer.contents revbuf)
    in
    (data, revData, !has_mel_as)

let arrow ~loc a b = [%type: [%t a] -> [%t b]]

let raiseWhenNotFound =
  let jsMapperRt = Longident.Lident "Js__Js_mapper_runtime" in
  fun ~loc x ->
    [%expr
      [%e
        Exp.ident ~loc
          { loc; txt = Longident.Ldot (jsMapperRt, "raiseWhenNotFound") }]
        [%e x]]

let derivingName = "jsConverter"

let derive_structure =
  let single_non_rec_value ~loc name exp =
    Str.value ~loc Nonrecursive [ Vb.mk ~loc (Pat.var ~loc name) exp ]
  in
  let not_applicable ~loc =
    [
      [%stri
        [%%ocaml.error
        [%e
          Exp.constant ~loc
            (Pconst_string (U.notApplicable derivingName, loc, None))]]];
    ]
  in
  let handle_tdcl ~createType (tdcl : type_declaration) =
    let source_loc = tdcl.ptype_name.loc in
    let loc = ghost source_loc in
    let core_type =
      let core_type =
        ghost_locations#core_type (U.core_type_of_type_declaration tdcl)
      in
      { core_type with ptyp_loc = loc }
    in
    let name = tdcl.ptype_name.txt in
    let toJs = name ^ "ToJs" in
    let fromJs = name ^ "FromJs" in
    let patToJs = { Asttypes.loc; txt = toJs } in
    let patFromJs = { Asttypes.loc; txt = fromJs } in
    let param = "param" in

    let exp_param ~loc =
      Exp.ident ~loc { Asttypes.txt = Longident.Lident param; loc }
    in
    let pat_param ~loc = Pat.var ~loc { Asttypes.loc; txt = param } in
    let newType, newTdcl =
      U.new_type_of_type_declaration tdcl ("abs_" ^ name)
    in
    let newType =
      let newType = ghost_locations#core_type newType in
      { newType with ptyp_loc = loc }
    in
    let newTdcl =
      let newTdcl = ghost_locations#type_declaration newTdcl in
      { newTdcl with ptype_loc = loc }
    in
    let newTypeStr =
      (* Abstract type *)
      Str.type_ ~loc Nonrecursive [ newTdcl ]
    in
    let toJsBody body =
      Str.value ~loc Nonrecursive
        [
          Vb.mk ~loc (Pat.var ~loc patToJs)
            (Exp.fun_ ~loc Nolabel None
               (Pat.constraint_ ~loc (pat_param ~loc) core_type)
               body);
        ]
    in
    let ( +> ) a ty = Exp.constraint_ ~loc (eraseType ~loc a) ty in
    let ( +: ) a ty = eraseType ~loc (Exp.constraint_ ~loc a ty) in
    let coerceResultToNewType e = if createType then e +> newType else e in
    match tdcl.ptype_kind with
    | Ptype_record label_declarations ->
        let exp =
          coerceResultToNewType
            (Exp.mk ~loc
               (Ast_object.record_as_js_object ~loc
                  (List.map
                     ~f:(fun { pld_name = { loc; txt }; _ } ->
                       let loc = ghost loc in
                       let label =
                         { Asttypes.loc; txt = Longident.Lident txt }
                       in
                       (label, Exp.field ~loc (exp_param ~loc) label))
                     label_declarations)))
        in
        let toJs = toJsBody exp in
        let obj_exp =
          Exp.record ~loc
            (List.map
               ~f:(fun { pld_name = { loc; txt }; _ } ->
                 let loc = ghost loc in
                 let label = { Asttypes.loc; txt = Longident.Lident txt } in
                 (label, js_field ~loc (exp_param ~loc) label))
               label_declarations)
            None
        in
        let fromJs =
          Str.value ~loc Nonrecursive
            [
              Vb.mk ~loc (Pat.var ~loc patFromJs)
                (Exp.fun_ ~loc Nolabel None (pat_param ~loc)
                   (if createType then
                      Exp.let_ ~loc Nonrecursive
                        [
                          Vb.mk ~loc (pat_param ~loc) (exp_param ~loc +: newType);
                        ]
                        (Exp.constraint_ ~loc obj_exp core_type)
                    else Exp.constraint_ ~loc obj_exp core_type));
            ]
        in
        let rest = [ toJs; fromJs ] in
        if createType then eraseTypeStr :: newTypeStr :: rest else rest
    | Ptype_abstract -> (
        match Ast_polyvar.is_enum_polyvar tdcl with
        | Some row_fields ->
            let map, revMap = ("_map", "_revMap") in
            let expMap () = Exp.ident ~loc { loc; txt = Lident map } in
            let revExpMap () = Exp.ident ~loc { loc; txt = Lident revMap } in
            let data, revData, has_mel_as = buildMap row_fields in

            let v =
              [
                eraseTypeStr;
                unsafeIndexGet;
                single_non_rec_value ~loc { loc; txt = map }
                  (Ast_extensions.handle_raw ~kind:Raw_exp ~loc
                     (PStr
                        [
                          Str.eval ~loc (Exp.constant ~loc (Const.string data));
                        ]));
                single_non_rec_value ~loc { loc; txt = revMap }
                  (if has_mel_as then
                     Ast_extensions.handle_raw ~kind:Raw_exp ~loc
                       (PStr
                          [
                            Str.eval ~loc
                              (Exp.constant ~loc (Const.string revData));
                          ])
                   else expMap ());
                toJsBody
                  (if has_mel_as then
                     [%expr
                       [%e unsafeIndexGetExp ~loc] [%e expMap ()]
                         [%e exp_param ~loc]]
                   else eraseType ~loc (exp_param ~loc));
                single_non_rec_value ~loc patFromJs
                  (Exp.fun_ ~loc Nolabel None (pat_param ~loc)
                     (let result =
                        [%expr
                          [%e unsafeIndexGetExp ~loc] [%e revExpMap ()]
                            [%e exp_param ~loc]]
                      in
                      if createType then raiseWhenNotFound ~loc result
                      else result));
              ]
            in
            if createType then newTypeStr :: v else v
        | None -> not_applicable ~loc:source_loc)
    | Ptype_variant _ | Ptype_open -> not_applicable ~loc:source_loc
  in
  fun ~newType:createType (tdcls : type_declaration list) ->
    List.concat_map ~f:(handle_tdcl ~createType) tdcls

let derive_signature =
  let not_applicable ~loc =
    [
      [%sigi:
        [%%ocaml.error
        [%e
          Exp.constant ~loc
            (Pconst_string (U.notApplicable derivingName, loc, None))]]];
    ]
  in
  let handle_tdcl ~createType tdcl =
    let source_loc = tdcl.ptype_name.loc in
    let loc = ghost source_loc in
    let core_type =
      let core_type =
        ghost_locations#core_type (U.core_type_of_type_declaration tdcl)
      in
      { core_type with ptyp_loc = loc }
    in
    let name = tdcl.ptype_name.txt in
    let toJs = name ^ "ToJs" in
    let fromJs = name ^ "FromJs" in
    let patToJs = { Asttypes.loc; txt = toJs } in
    let patFromJs = { Asttypes.loc; txt = fromJs } in
    let toJsType result =
      Sig.value ~loc (Val.mk ~loc patToJs (arrow ~loc core_type result))
    in
    let newType, newTdcl =
      U.new_type_of_type_declaration tdcl ("abs_" ^ name)
    in
    let newType =
      let newType = ghost_locations#core_type newType in
      { newType with ptyp_loc = loc }
    in
    let newTdcl =
      let newTdcl = ghost_locations#type_declaration newTdcl in
      { newTdcl with ptype_loc = loc }
    in
    let newTypeStr = Sig.type_ ~loc Nonrecursive [ newTdcl ] in
    let ( +? ) v rest = if createType then v :: rest else rest in
    match tdcl.ptype_kind with
    | Ptype_record label_declarations ->
        let objType flag =
          Ast_core_type.to_js_type ~loc
            (Typ.object_ ~loc
               (List.map
                  ~f:(fun { pld_name; pld_type; _ } ->
                    let field_loc = ghost pld_name.loc in
                    let pld_name = { pld_name with loc = field_loc } in
                    let pld_type = ghost_locations#core_type pld_type in
                    Of.tag ~loc:field_loc pld_name pld_type)
                  label_declarations)
               flag)
        in
        newTypeStr
        +? [
             toJsType (if createType then newType else objType Closed);
             Sig.value ~loc
               (Val.mk ~loc patFromJs
                  (arrow ~loc
                     (if createType then newType else objType Open)
                     core_type));
           ]
    | Ptype_abstract -> (
        match Ast_polyvar.is_enum_polyvar tdcl with
        | Some _ ->
            let ty1 = if createType then newType else [%type: string] in
            let ty2 =
              if createType then core_type
              else Ast_core_type.lift_option_type core_type
            in
            newTypeStr
            +? [
                 toJsType ty1;
                 Sig.value ~loc (Val.mk ~loc patFromJs (arrow ~loc ty1 ty2));
               ]
        | None -> not_applicable ~loc:source_loc)
    | Ptype_variant _ | Ptype_open -> not_applicable ~loc:source_loc
  in
  fun ~newType:createType tdcls ->
    List.concat_map ~f:(handle_tdcl ~createType) tdcls
