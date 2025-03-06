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

let ffi_of_labels labels =
  Melange_ffi.External_ffi_types.ffi_obj_create
    (List.fold_right labels ~init:[] ~f:(fun (p : string with_loc) arg_kinds ->
         {
           Melange_ffi.External_arg_spec.arg_type = Nothing;
           arg_label =
             Melange_ffi.External_arg_spec.Obj_label.obj
               (Melange_ffi.Lam_methname.translate p.txt);
         }
         :: arg_kinds))

let ocaml_object_as_js_object =
  let local_extern_cont_to_obj loc ~ffi ~pval_type ?(local_module_name = "J")
      ?(local_fun_name = "unsafe_expr") (cb : expression -> 'a) :
      expression_desc =
    Pexp_letmodule
      ( { txt = Some local_module_name; loc },
        {
          pmod_desc =
            Pmod_structure
              [
                {
                  pstr_desc =
                    Pstr_primitive
                      {
                        pval_name = { txt = local_fun_name; loc };
                        pval_type;
                        pval_loc = loc;
                        pval_prim = Ast_external.pval_prim_default;
                        pval_attributes = [ Ast_attributes.mel_ffi ffi ];
                      };
                  pstr_loc = loc;
                };
              ];
          pmod_loc = loc;
          pmod_attributes = [];
        },
        cb
          {
            pexp_desc =
              Pexp_ident
                { txt = Ldot (Lident local_module_name, local_fun_name); loc };
            pexp_attributes = [];
            pexp_loc = loc;
            pexp_loc_stack = [ loc ];
          } )
  in
  fun loc (mapper : Ast_traverse.map) (self_pat : pattern)
      (clfs : class_field list) ->
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
              | Pexp_poly
                  ( { pexp_desc = Pexp_function (_, _, Pfunction_cases _); _ },
                    None ) ->
                  assert false
              | Pexp_poly
                  ( {
                      pexp_desc =
                        Pexp_function
                          ( {
                              pparam_desc = Pparam_val (lbl, None, pat);
                              pparam_loc = _loc;
                            }
                              (* TODO(anmonteiro): Check if this can be multiple args *)
                            :: _,
                            _,
                            Pfunction_body e );
                      _;
                    },
                    None ) ->
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
              | _ ->
                  Location.raise_errorf ~loc "Unsupported syntax in js object")
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
          | Pcf_inherit _ | Pcf_initializer _ | Pcf_attribute _
          | Pcf_extension _ | Pcf_constraint _ ->
              Location.raise_errorf ~loc "Only method support currently")
        clfs ~init:([], [])
    in
    let internal_obj_type =
      Ast_core_type.make_obj ~loc internal_label_attr_types
    in
    let public_obj_type =
      Ast_core_type.to_js_type ~loc
        (Typ.object_ ~loc public_label_attr_types Closed)
    in
    let labels, label_types, exprs, _ =
      List.fold_right
        ~f:(fun (x : class_field) (labels, label_types, exprs, aliased) ->
          match x.pcf_desc with
          | Pcf_method (label, _public_flag, Cfk_concrete (Fresh, e)) -> (
              match e.pexp_desc with
              | Pexp_poly
                  ( { pexp_desc = Pexp_function (_, _, Pfunction_cases _); _ },
                    None ) ->
                  assert false
              | Pexp_poly
                  ( ({
                       pexp_desc =
                         Pexp_function
                           ( {
                               pparam_desc = Pparam_val (ll, None, pat);
                               pparam_loc = _loc;
                             }
                               (* TODO(anmonteiro): Check if this can be multiple args *)
                             :: _,
                             _,
                             Pfunction_body e );
                       _;
                     } as f),
                    None ) ->
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
              | _ ->
                  Location.raise_errorf ~loc "Unsupported syntax in js object")
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
          | Pcf_inherit _ | Pcf_initializer _ | Pcf_attribute _
          | Pcf_extension _ | Pcf_constraint _ ->
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
    local_extern_cont_to_obj loc ~ffi:(ffi_of_labels labels)
      (fun e ->
        Exp.apply ~loc e
          (List.map2 ~f:(fun l expr -> (Labelled l.txt, expr)) labels exprs))
      ~pval_type

let record_as_js_object =
  let local_external_obj loc ~ffi ~pval_type ?(local_module_name = "J")
      ?(local_fun_name = "unsafe_expr") args : expression_desc =
    Pexp_letmodule
      ( { txt = Some local_module_name; loc },
        {
          pmod_desc =
            Pmod_structure
              [
                {
                  pstr_desc =
                    Pstr_primitive
                      {
                        pval_name = { txt = local_fun_name; loc };
                        pval_type;
                        pval_loc = loc;
                        pval_prim = [ ""; "" ];
                        pval_attributes = [ Ast_attributes.mel_ffi ffi ];
                      };
                  pstr_loc = loc;
                };
              ];
          pmod_loc = loc;
          pmod_attributes = [];
        },
        Exp.apply
          ({
             pexp_desc =
               Pexp_ident
                 { txt = Ldot (Lident local_module_name, local_fun_name); loc };
             pexp_attributes = [];
             pexp_loc = loc;
             pexp_loc_stack = [ loc ];
           }
            : expression)
          (List.map ~f:(fun (l, a) -> (Asttypes.Labelled l, a)) args)
          ~loc )
  in
  (* Note that OCaml type checker will not allow arbitrary
   name as type variables, for example:
   {[
     '_x'_
   ]}
   will be recognized as a invalid program
*)
  let from_labels ~loc arity labels : core_type =
    let tyvars =
      List.init ~len:arity ~f:(fun i -> Typ.var ~loc ("a" ^ string_of_int i))
    in
    let result_type =
      Ast_core_type.to_js_type ~loc
        (Typ.object_ ~loc
           (List.map2 ~f:(fun x y -> Of.tag x y) labels tyvars)
           Closed)
    in
    List.fold_right2
      ~f:(fun label (* {loc ; txt = label } *) tyvar acc ->
        Typ.arrow ~loc:label.loc (Labelled label.txt) tyvar acc)
      labels tyvars ~init:result_type
  in
  fun ~loc (label_exprs : (Longident.t Asttypes.loc * expression) list) :
      expression_desc ->
    let labels, args, arity =
      List.fold_right
        ~f:(fun ({ txt; loc }, e) (labels, args, i) ->
          match txt with
          | Lident obj_label ->
              let obj_label =
                Ast_attributes.iter_process_mel_string_as e.pexp_attributes
                |> Option.value ~default:obj_label
              in
              ( { Asttypes.loc; txt = obj_label } :: labels,
                (obj_label, e) :: args,
                i + 1 )
          | Ldot _ | Lapply _ ->
              Location.raise_errorf ~loc
                "`%%mel.obj' literals only support simple labels")
        label_exprs ~init:([], [], 0)
    in
    local_external_obj loc ~ffi:(ffi_of_labels labels)
      ~pval_type:(from_labels ~loc arity labels)
      args
