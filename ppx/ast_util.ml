(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
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

type args = (Asttypes.arg_label * expression) list

let js_property loc obj (name : string) =
  Pexp_send
    ( [%expr [%e Exp.ident { txt = Ast_literal.unsafe_downgrade; loc }] [%e obj]],
      { loc; txt = name } )

let ocaml_obj_as_js_object loc (mapper : Ast_traverse.map) (self_pat : pattern)
    (clfs : class_field list) =
  (* Attention: we should avoid type variable conflict for each method
      Since the method name is unique, there would be no conflict
      OCaml does not allow duplicate instance variable and duplicate methods,
      but it does allow duplicates between instance variable and method name,
      we should enforce such rules
      {[
        object [@u]
          val x = 3
          method x = 3
        end
      ]} should not compile with a meaningful error message
  *)
  let generate_val_method_pair loc (mapper : Ast_traverse.map)
      (val_name : string Asttypes.loc) is_mutable =
    let result = Typ.var ~loc val_name.txt in

    ( result,
      Of.tag val_name result
      ::
      (if is_mutable then
         [
           Of.tag
             {
               val_name with
               txt =
                 val_name.txt
                 ^ Melange_ffi.External_ffi_types.Literals.setter_suffix;
             }
             (Ast_typ_uncurry.to_method_type loc mapper Nolabel result
                [%type: unit]);
         ]
       else []) )
  in

  (* Note mapper is only for API compatible
   * TODO: we should check label name to avoid conflict
   *)

  (* we need calculate the real object type
      and exposed object type, in some cases there are equivalent

      for public object type its [@meth] it does not depend on itself
      while for label argument it is [@this] which depends internal object
  *)
  let ( (internal_label_attr_types : object_field list),
        (public_label_attr_types : object_field list) ) =
    List.fold_right
      ~f:(fun
          ({ pcf_loc = loc; _ } as x : class_field)
          (label_attr_types, public_label_attr_types)
        ->
        match x.pcf_desc with
        | Pcf_method (label, public_flag, Cfk_concrete (Fresh, e)) -> (
            match e.pexp_desc with
            | Pexp_poly ({ pexp_desc = Pexp_fun (lbl, _, pat, e); _ }, None) ->
                let method_type =
                  Ast_typ_uncurry.generate_arg_type x.pcf_loc mapper label.txt
                    lbl pat e
                in
                ( Of.tag label method_type :: label_attr_types,
                  if public_flag = Public then
                    Of.tag label method_type :: public_label_attr_types
                  else public_label_attr_types )
            | Pexp_poly (_, Some _) ->
                Location.raise_errorf ~loc
                  "polymorphic type annotation not supported yet"
            | Pexp_poly (_, None) ->
                Location.raise_errorf ~loc
                  "Unsupported JS Object syntax. Methods must take at least \
                   one argument"
            | _ -> Location.raise_errorf ~loc "Unsupported syntax in js object")
        | Pcf_val (label, mutable_flag, Cfk_concrete (Fresh, _)) ->
            let _, label_attr =
              generate_val_method_pair x.pcf_loc mapper label
                (mutable_flag = Mutable)
            in
            (List.append label_attr label_attr_types, public_label_attr_types)
        | Pcf_val (_, _, Cfk_concrete (Override, _)) ->
            Location.raise_errorf ~loc "override flag not support currently"
        | Pcf_val (_, _, Cfk_virtual _) ->
            Location.raise_errorf ~loc "virtual flag not support currently"
        | Pcf_method (_, _, Cfk_concrete (Override, _)) ->
            Location.raise_errorf ~loc "override flag not supported"
        | Pcf_method (_, _, Cfk_virtual _) ->
            Location.raise_errorf ~loc "virtural method not supported"
        | Pcf_inherit _ | Pcf_initializer _ | Pcf_attribute _ | Pcf_extension _
        | Pcf_constraint _ ->
            Location.raise_errorf ~loc "Only method support currently")
      clfs ~init:([], [])
  in
  let internal_obj_type =
    Ast_core_type.make_obj ~loc internal_label_attr_types
  in
  let public_obj_type =
    Ast_comb.to_js_type ~loc (Typ.object_ ~loc public_label_attr_types Closed)
  in
  let labels, label_types, exprs, _ =
    List.fold_right
      ~f:(fun (x : class_field) (labels, label_types, exprs, aliased) ->
        match x.pcf_desc with
        | Pcf_method (label, _public_flag, Cfk_concrete (Fresh, e)) -> (
            match e.pexp_desc with
            | Pexp_poly
                (({ pexp_desc = Pexp_fun (ll, None, pat, e); _ } as f), None) ->
                let alias_type =
                  if aliased then None else Some internal_obj_type
                in
                let label_type =
                  Ast_typ_uncurry.generate_method_type ?alias_type x.pcf_loc
                    mapper label.txt ll pat e
                in
                ( label :: labels,
                  label_type :: label_types,
                  {
                    f with
                    pexp_desc =
                      (let f = Ast_pat.is_unit_cont pat ~yes:e ~no:f in
                       Ast_uncurry_gen.to_method_callback loc mapper Nolabel
                         self_pat f)
                      (* the first argument is this*);
                  }
                  :: exprs,
                  true )
            | Pexp_poly (_, Some _) ->
                Location.raise_errorf ~loc
                  "polymorphic type annotation not supported yet"
            | Pexp_poly (_, None) ->
                Location.raise_errorf ~loc
                  "Unsupported syntax, expect syntax like `method x () = x ` "
            | _ -> Location.raise_errorf ~loc "Unsupported syntax in js object")
        | Pcf_val (label, mutable_flag, Cfk_concrete (Fresh, val_exp)) ->
            let label_type, _ =
              generate_val_method_pair x.pcf_loc mapper label
                (mutable_flag = Mutable)
            in
            ( label :: labels,
              label_type :: label_types,
              mapper#expression val_exp :: exprs,
              aliased )
        | Pcf_val (_, _, Cfk_concrete (Override, _)) ->
            Location.raise_errorf ~loc "override flag not support currently"
        | Pcf_val (_, _, Cfk_virtual _) ->
            Location.raise_errorf ~loc "virtual flag not support currently"
        | Pcf_method (_, _, Cfk_concrete (Override, _)) ->
            Location.raise_errorf ~loc "override flag not supported"
        | Pcf_method (_, _, Cfk_virtual _) ->
            Location.raise_errorf ~loc "virtural method not supported"
        | Pcf_inherit _ | Pcf_initializer _ | Pcf_attribute _ | Pcf_extension _
        | Pcf_constraint _ ->
            Location.raise_errorf ~loc "Only method support currently")
      clfs ~init:([], [], [], false)
  in
  let pval_type =
    List.fold_right2
      ~f:(fun label label_type acc ->
        Typ.arrow ~loc:label.Asttypes.loc (Labelled label.Asttypes.txt)
          label_type acc)
      labels label_types ~init:public_obj_type
  in
  Ast_external_mk.local_extern_cont_to_obj loc
    ~pval_prim:(Ast_external_mk.pval_prim_of_labels labels)
    (fun e ->
      Exp.apply ~loc e
        (List.map2 ~f:(fun l expr -> (Labelled l.txt, expr)) labels exprs))
    ~pval_type
