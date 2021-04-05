open! Ext

(* Copyright (C) 2021- Authors of Melange
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



type mapper = Bs_ast_mapper.mapper
let default_mapper = Bs_ast_mapper.default_mapper

let type_declaration_mapper (_self : mapper) (tdcl : Parsetree.type_declaration) =
  let attributes = Ext_list.map tdcl.ptype_attributes
    (fun ({ attr_name = {txt ; loc}; attr_payload = payload}  as attr)  ->
       let txt' = match txt with
       | "deriving" ->
         let deriver = begin match payload with
         (* [@@deriving {abstract = light}] *)
         | PStr [ {pstr_desc = Pstr_eval ({pexp_desc = Pexp_record (label_exprs, with_obj)}, _); _ }] ->
           begin match with_obj with
             | None ->
               Ext_list.filter_map label_exprs
                 (fun u  ->
                    match u with
                    | ({txt = Lident name; _}) ,
                      ({Parsetree.pexp_desc = Pexp_ident{txt = Lident name2}} )
                      when name2 = name -> Some name
                    | ({txt = Lident name; _}), _ -> Some name
                    | _ -> None
                 )
             | Some _ -> []
           end
         (* [@@deriving abstract] *)
         | PStr [ {pstr_desc = Pstr_eval ({
                    pexp_desc =
                      Pexp_ident ({txt = Lident txt; _});
                  }, _) } ] -> [ txt ]
         | _ -> []
       end in
       if Ext_list.exists deriver Ast_derive.is_builtin_deriver then
         "bs.deriving"
       else
         "deriving"
      | x -> x
      in
      { attr with attr_name = {txt=txt' ; loc}})
  in
  { tdcl with ptype_attributes = attributes }


let  mapper : mapper =
  { default_mapper with type_declaration = type_declaration_mapper; }

let structure ast =
  mapper.structure mapper ast
let signature ast =
  mapper.signature mapper ast
