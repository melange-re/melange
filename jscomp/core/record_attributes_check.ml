(* Copyright (C) 2019- Hongbo Zhang, Authors of ReScript
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

type label = Types.label_description

let find_name (attr : Parsetree.attribute) =
  match attr with
  | {
   attr_name = { txt = "mel.as" | "bs.as" | "as"; _ };
   attr_payload =
     PStr
       [
         {
           pstr_desc =
             Pstr_eval
               ({ pexp_desc = Pexp_constant (Pconst_string (s, _, _)); _ }, _);
           _;
         };
       ];
   _;
  } ->
      Some s
  | _ -> None

let find_name_with_loc (attr : Parsetree.attribute) : string Asttypes.loc option
    =
  match attr with
  | {
   attr_name = { txt = "mel.as" | "bs.as" | "as"; loc };
   attr_payload =
     PStr
       [
         {
           pstr_desc =
             Pstr_eval
               ({ pexp_desc = Pexp_constant (Pconst_string (s, _, _)); _ }, _);
           _;
         };
       ];
   _;
  } ->
      Some { txt = s; loc }
  | _ -> None

let fld_record (lbl : label) =
  Lambda.Fld_record
    {
      name = Ext_list.find_def lbl.lbl_attributes find_name lbl.lbl_name;
      mutable_flag = lbl.Types.lbl_mut;
    }

let fld_record_set (lbl : label) =
  Lambda.Fld_record_set
    (Ext_list.find_def lbl.lbl_attributes find_name lbl.lbl_name)

let fld_record_inline (lbl : label) =
  Lambda.Fld_record_inline
    { name = Ext_list.find_def lbl.lbl_attributes find_name lbl.lbl_name }

let fld_record_inline_set (lbl : label) =
  Lambda.Fld_record_inline_set
    (Ext_list.find_def lbl.lbl_attributes find_name lbl.lbl_name)

let fld_record_extension (lbl : label) =
  Lambda.Fld_record_extension
    { name = Ext_list.find_def lbl.lbl_attributes find_name lbl.lbl_name }

let fld_record_extension_set (lbl : label) =
  Lambda.Fld_record_extension_set
    (Ext_list.find_def lbl.lbl_attributes find_name lbl.lbl_name)

let blk_record fields =
  let all_labels_info =
    Array.map
      (fun ((lbl : label), _) ->
        Ext_list.find_def lbl.Types.lbl_attributes find_name lbl.lbl_name)
      fields
  in
  Lambda.Blk_record all_labels_info

let blk_record_ext fields =
  let all_labels_info =
    Array.map
      (fun ((lbl : label), _) ->
        Ext_list.find_def lbl.Types.lbl_attributes find_name lbl.lbl_name)
      fields
  in
  Lambda.Blk_record_ext all_labels_info

let blk_record_inlined fields name num_nonconst =
  let fields =
    Array.map
      (fun ((lbl : label), _) ->
        Ext_list.find_def lbl.Types.lbl_attributes find_name lbl.lbl_name)
      fields
  in
  Lambda.Blk_record_inlined { fields; name; num_nonconst }

let check_bs_attributes_inclusion (attrs1 : Parsetree.attributes)
    (attrs2 : Parsetree.attributes) lbl_name =
  let a = Ext_list.find_def attrs1 find_name lbl_name in
  let b = Ext_list.find_def attrs2 find_name lbl_name in
  if a = b then None else Some (a, b)

let rec check_duplicated_labels_aux (lbls : Parsetree.label_declaration list)
    (coll : Set_string.t) =
  match lbls with
  | [] -> None
  | { pld_name = { txt; _ } as pld_name; pld_attributes; _ } :: rest -> (
      if Set_string.mem coll txt then Some pld_name
      else
        let coll_with_lbl = Set_string.add coll txt in
        match Ext_list.find_opt pld_attributes find_name_with_loc with
        | None -> check_duplicated_labels_aux rest coll_with_lbl
        | Some ({ txt = s; _ } as l) ->
            if
              Set_string.mem coll s
              (*use coll to make check a bit looser
                allow cases like [ x : int [@as "x"]]
              *)
            then Some l
            else
              check_duplicated_labels_aux rest (Set_string.add coll_with_lbl s))

let check_duplicated_labels lbls =
  check_duplicated_labels_aux lbls Set_string.empty
