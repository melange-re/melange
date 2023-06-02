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

open Ppxlib
open Ast_helper

let core_type_of_type_declaration (tdcl : Parsetree.type_declaration) =
  match tdcl with
  | { ptype_name = { txt; loc }; ptype_params } ->
      Typ.constr { txt = Lident txt; loc } (List.map fst ptype_params)

let new_type_of_type_declaration (tdcl : Parsetree.type_declaration) newName =
  match tdcl with
  | { ptype_name = { loc }; ptype_params } ->
      ( Typ.constr { txt = Lident newName; loc } (List.map fst ptype_params),
        {
          Parsetree.ptype_params = tdcl.ptype_params;
          ptype_name = { txt = newName; loc };
          ptype_kind = Ptype_abstract;
          ptype_attributes = [];
          ptype_loc = tdcl.ptype_loc;
          ptype_cstrs = [];
          ptype_private = Public;
          ptype_manifest = None;
        } )

(* let mk_fun ~loc (typ : Parsetree.core_type)
       (value : string) body
     : Parsetree.expression =
     Ast_compatible.fun_
       (Pat.constraint_ (Pat.var {txt = value ; loc}) typ)
       body

   let destruct_label_declarations ~loc
       (arg_name : string)
       (labels : Parsetree.label_declaration list) :
     (Parsetree.core_type * Parsetree.expression) list * string list
     =
     Ext_list.fold_right labels ([], [])
       (fun {pld_name = {txt}; pld_type}
         (core_type_exps, labels) ->
         ((pld_type,
           Exp.field (Exp.ident {txt = Lident arg_name ; loc})
             {txt = Lident txt ; loc}) :: core_type_exps),
         txt :: labels
       ) *)

let notApplicable derivingName = derivingName ^ " not applicable to this type"

let invalid_config (config : Parsetree.expression) =
  Location.raise_errorf ~loc:config.pexp_loc
    "such configuration is not supported"
