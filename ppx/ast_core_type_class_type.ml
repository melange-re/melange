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
open Ast_helper

exception Local of Location.t * string

let process_getter_setter ~not_getter_setter
    ~(get : core_type -> _ -> attributes -> _) ~set loc name
    (attrs : attribute list) (ty : core_type) (acc : _ list) =
  match Ast_attributes.process_method_attributes_rev attrs with
  | Error (loc, s) -> raise (Local (loc, s))
  | Ok ({ get = None; set = None }, _) -> not_getter_setter ty :: acc
  | Ok (st, pctf_attributes) -> (
      let get_acc =
        match st.set with
        | Some `No_get -> acc
        | None | Some `Get ->
            let lift txt = Typ.constr ~loc { txt; loc } [ ty ] in
            let null, undefined =
              match st with
              | { get = Some (null, undefined); _ } -> (null, undefined)
              | { get = None; _ } -> (false, false)
            in
            let ty =
              match (null, undefined) with
              | false, false -> ty
              | true, false -> lift Ast_literal.js_null
              | false, true -> lift Ast_literal.js_undefined
              | true, true -> lift Ast_literal.js_nullable
            in
            get ty name pctf_attributes :: acc
      in
      match st.set with
      | None -> get_acc
      | Some _ ->
          set ty
            ({
               name with
               txt =
                 name.Asttypes.txt
                 ^ Melange_ffi.External_ffi_types.Literals.setter_suffix;
             }
              : _ Asttypes.loc)
            pctf_attributes
          :: get_acc)

(*
  Attributes are very hard to attribute
  (since ptyp_attributes could happen in so many places),
  and write ppx extensions correctly,
  we can only use it locally
*)

let typ_mapper ((self, super) : Ast_traverse.map * (core_type -> core_type))
    (ty : core_type) =
  match ty with
  | {
   ptyp_attributes;
   ptyp_desc = Ptyp_arrow (label, args, body);
   (* let it go without regard label names,
      it will report error later when the label is not empty
   *)
   ptyp_loc = loc;
   _;
  } -> (
      match fst (Ast_attributes.process_attributes_rev ptyp_attributes) with
      | Uncurry _ -> Ast_typ_uncurry.to_uncurry_type ~loc self label args body
      | Meth_callback _ ->
          Ast_typ_uncurry.to_method_callback_type ~loc self label args body
      | Method _ -> Ast_typ_uncurry.to_method_type ~loc self label args body
      | Nothing -> super ty)
  | { ptyp_desc = Ptyp_object (methods, closed_flag); ptyp_loc = loc; _ } -> (
      let ( +> ) attr (typ : core_type) =
        { typ with ptyp_attributes = attr :: typ.ptyp_attributes }
      in
      try
        let new_methods =
          List.fold_right
            ~f:(fun meth_ acc ->
              match meth_.pof_desc with
              | Oinherit _ -> meth_ :: acc
              | Otag (label, core_type) ->
                  let get ty name attrs =
                    let attrs, core_type =
                      match Ast_attributes.process_attributes_rev attrs with
                      | Nothing, attrs -> (attrs, ty) (* #1678 *)
                      | Uncurry attr, attrs -> (attrs, attr +> ty)
                      | Method _, _ ->
                          Location.raise_errorf ~loc
                            "`%@mel.get' / `%@mel.set' cannot be used with \
                             `%@mel.meth'"
                      | Meth_callback attr, attrs -> (attrs, attr +> ty)
                    in
                    Of.tag name ~attrs (self#core_type core_type)
                  in
                  let set ty name attrs =
                    let attrs, core_type =
                      match Ast_attributes.process_attributes_rev attrs with
                      | Nothing, attrs -> (attrs, ty)
                      | Uncurry attr, attrs -> (attrs, attr +> ty)
                      | Method _, _ ->
                          Location.raise_errorf ~loc
                            "`%@mel.get' / `%@mel.set' cannot be used with \
                             `%@mel.meth'"
                      | Meth_callback attr, attrs -> (attrs, attr +> ty)
                    in
                    Of.tag name ~attrs
                      (Ast_typ_uncurry.to_method_type ~loc self Nolabel
                         core_type [%type: unit])
                  in
                  let not_getter_setter ty =
                    let attrs, core_type =
                      match
                        Ast_attributes.process_attributes_rev
                          meth_.pof_attributes
                      with
                      | Nothing, attrs -> (attrs, ty)
                      | Uncurry attr, attrs -> (attrs, attr +> ty)
                      | Method attr, attrs -> (attrs, attr +> ty)
                      | Meth_callback attr, attrs -> (attrs, attr +> ty)
                    in
                    Of.tag label ~attrs (self#core_type core_type)
                  in
                  process_getter_setter ~not_getter_setter ~get ~set loc label
                    meth_.pof_attributes core_type acc)
            methods ~init:[]
        in
        { ty with ptyp_desc = Ptyp_object (new_methods, closed_flag) }
      with Local (loc, s) ->
        [%type: [%ocaml.error [%e Exp.constant (Pconst_string (s, loc, None))]]]
      )
  | _ -> super ty

let handle_class_type_fields =
  let handle_class_type_field
      ((self, super) :
        Ast_traverse.map * (class_type_field -> class_type_field))
      ({ pctf_loc = loc; _ } as ctf : class_type_field) acc =
    match ctf.pctf_desc with
    | Pctf_method (name, private_flag, virtual_flag, ty) ->
        let not_getter_setter (ty : core_type) =
          let ty =
            match ty.ptyp_desc with
            | Ptyp_arrow (label, args, body) ->
                Ast_typ_uncurry.to_method_type ~loc:ty.ptyp_loc self label args
                  body
            | Ptyp_poly
                ( strs,
                  { ptyp_desc = Ptyp_arrow (label, args, body); ptyp_loc; _ } )
              ->
                {
                  ty with
                  ptyp_desc =
                    Ptyp_poly
                      ( strs,
                        Ast_typ_uncurry.to_method_type ~loc:ptyp_loc self label
                          args body );
                }
            | _ -> self#core_type ty
          in
          {
            ctf with
            pctf_desc = Pctf_method (name, private_flag, virtual_flag, ty);
          }
        in
        let get ty name pctf_attributes =
          {
            ctf with
            pctf_desc =
              Pctf_method (name, private_flag, virtual_flag, self#core_type ty);
            pctf_attributes;
          }
        in
        let set ty name pctf_attributes =
          {
            ctf with
            pctf_desc =
              Pctf_method
                ( name,
                  private_flag,
                  virtual_flag,
                  Ast_typ_uncurry.to_method_type ~loc self Nolabel ty
                    [%type: unit] );
            pctf_attributes;
          }
        in
        process_getter_setter ~not_getter_setter ~get ~set loc name
          ctf.pctf_attributes ty acc
    | Pctf_inherit _ | Pctf_val _ | Pctf_constraint _ | Pctf_attribute _
    | Pctf_extension _ ->
        super ctf :: acc
  in
  fun self fields ->
    try Ok (List.fold_right ~f:(handle_class_type_field self) fields ~init:[])
    with Local (loc, s) -> Error (loc, s)
