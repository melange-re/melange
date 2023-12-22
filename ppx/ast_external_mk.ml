(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
 * Copyright (C) 2017 -  Hongbo Zhang, Authors of ReScript
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

let local_external_apply loc ~(pval_prim : string list) ~(pval_type : core_type)
    ?(local_module_name = "J") ?(local_fun_name = "unsafe_expr")
    (args : expression list) : expression_desc =
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
                      pval_prim;
                      pval_attributes = [];
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
        (List.map ~f:(fun x -> (Asttypes.Nolabel, x)) args)
        ~loc )

let local_external_obj loc ?(pval_attributes = []) ~pval_prim ~pval_type
    ?(local_module_name = "J") ?(local_fun_name = "unsafe_expr") args :
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
                      pval_prim;
                      pval_attributes;
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

let local_extern_cont_to_obj loc ?(pval_attributes = []) ~pval_prim ~pval_type
    ?(local_module_name = "J") ?(local_fun_name = "unsafe_expr")
    (cb : expression -> 'a) : expression_desc =
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
                      pval_prim;
                      pval_attributes;
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

type label_exprs = (Longident.t Asttypes.loc * expression) list

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
    Ast_comb.to_js_type ~loc
      (Typ.object_ ~loc
         (List.map2 ~f:(fun x y -> Of.tag x y) labels tyvars)
         Closed)
  in
  List.fold_right2
    ~f:(fun label (* {loc ; txt = label }*) tyvar acc ->
      Typ.arrow ~loc:label.loc (Labelled label.txt) tyvar acc)
    labels tyvars ~init:result_type

let pval_prim_of_labels (labels : string Asttypes.loc list) =
  let arg_kinds =
    List.fold_right
      ~f:(fun p arg_kinds ->
        let obj_arg_label =
          Melange_ffi.External_arg_spec.obj_label
            (Melange_ffi.Lam_methname.translate p.txt)
        in
        { Melange_ffi.External_arg_spec.obj_arg_type = Nothing; obj_arg_label }
        :: arg_kinds)
      labels ~init:[]
  in
  Melange_ffi.External_ffi_types.ffi_obj_as_prims arg_kinds

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
        { Melange_ffi.External_arg_spec.obj_arg_type = Nothing; obj_arg_label }
        :: arg_kinds)
      labels
      ~init:
        (if ends_with_unit then
           [ Melange_ffi.External_arg_spec.empty_kind Extern_unit ]
         else [])
  in
  Melange_ffi.External_ffi_types.ffi_obj_as_prims arg_kinds

let record_as_js_object loc (label_exprs : label_exprs) : expression_desc =
  let labels, args, arity =
    List.fold_right
      ~f:(fun ({ txt; loc }, e) (labels, args, i) ->
        match txt with
        | Lident x ->
            ({ Asttypes.loc; txt = x } :: labels, (x, e) :: args, i + 1)
        | Ldot _ | Lapply _ ->
            Location.raise_errorf ~loc
              "`%%mel.obj' literals only support simple labels")
      label_exprs ~init:([], [], 0)
  in
  local_external_obj loc
    ~pval_prim:(pval_prim_of_labels labels)
    ~pval_type:(from_labels ~loc arity labels)
    args
