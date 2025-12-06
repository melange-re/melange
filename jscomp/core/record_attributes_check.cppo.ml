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

open Import

let rec find_mel_as_name_exn: Parsetree.attributes -> Lambda.as_modifier = function
  | { attr_name = { txt = "mel.as"; loc = _ }; attr_payload; _ } :: xs -> (
      match attr_payload with
      | PStr
          [
            {
              pstr_desc = Pstr_eval (exp, _);
              _;
            };
          ] -> (
          match exp.pexp_desc with
          | Pexp_constant const -> (
            match
  #if OCAML_VERSION >= (5, 3, 0)
            const.pconst_desc
  #else
            const
  #endif
            with
            | Pconst_string (s, _, _) -> Lambda.String s
            | Pconst_integer (s, None) -> Int (int_of_string s)
            | _ -> find_mel_as_name_exn xs)
          | Pexp_ident { loc = _; txt = Lident "null" } -> Null
          | Pexp_ident { loc = _; txt = Lident "undefined" } -> Undefined
          | Pexp_construct ({ loc = _; txt = Lident "false" }, _) -> Bool false
          | Pexp_construct ({ loc = _; txt = Lident "true" }, _) -> Bool true
          | _ -> find_mel_as_name_exn xs)
      | _ -> find_mel_as_name_exn xs)
  | _ :: xs -> find_mel_as_name_exn xs
  | [] -> raise_notrace Not_found

let find_mel_as_name attributes =
  match find_mel_as_name_exn attributes with
  | name -> Some name
  | exception Not_found -> None

let find_name_with_loc (attr : Parsetree.attribute) : string Asttypes.loc option
    =
  match attr with
  | {
   attr_name = { txt = "mel.as"; loc };
   attr_payload =
     PStr
       [
         {
           pstr_desc =
             Pstr_eval
               ( {
                   pexp_desc =
#if OCAML_VERSION >= (5, 3, 0)
                     Pexp_constant { pconst_desc = Pconst_string (s, _, _); _ };
#else
                     Pexp_constant (Pconst_string (s, _, _));
#endif
                   _;
                 },
                 _ );
           _;
         };
       ];
   _;
  } ->
      Some { txt = s; loc }
  | _ -> None

let find_with_default xs ~default =
  match xs with
  | [] -> default
  | xs -> (
      match find_mel_as_name_exn xs with
      | String v -> v
      | Int _ | Bool _ | Null | Undefined -> assert false
      | exception Not_found -> default)

#if OCAML_VERSION >= (5, 4, 0)
module Types = Data_types
#endif

let fld_record (lbl : Types.label_description) =
  Lambda.Fld_record
    {
      name = find_with_default lbl.lbl_attributes ~default:lbl.lbl_name;
      mutable_flag = lbl.lbl_mut;
    }

let fld_record_set (lbl : Types.label_description) =
  Lambda.Fld_record_set
    (find_with_default lbl.lbl_attributes ~default:lbl.lbl_name)

let fld_record_inline (lbl : Types.label_description) =
  Lambda.Fld_record_inline
    { name = find_with_default lbl.lbl_attributes ~default:lbl.lbl_name }

let fld_record_inline_set (lbl : Types.label_description) =
  Lambda.Fld_record_inline_set
    (find_with_default lbl.lbl_attributes ~default:lbl.lbl_name)

let fld_record_extension (lbl : Types.label_description) =
  Lambda.Fld_record_extension
    { name = find_with_default lbl.lbl_attributes ~default:lbl.lbl_name }

let fld_record_extension_set (lbl : Types.label_description) =
  Lambda.Fld_record_extension_set
    (find_with_default lbl.lbl_attributes ~default:lbl.lbl_name)

let blk_record fields =
  let all_labels_info =
    Array.map
      ~f:(fun (lbl, _) ->
        find_with_default lbl.Types.lbl_attributes ~default:lbl.lbl_name)
      fields
  in
  Lambda.Blk_record all_labels_info

let blk_record_ext ~is_exn fields =
  let all_labels_info =
    Array.map
      ~f:(fun ((lbl : Types.label_description), _) ->
        find_with_default lbl.Types.lbl_attributes ~default:lbl.lbl_name)
      fields
  in
  Lambda.Blk_record_ext { fields = all_labels_info; exn = is_exn }

let blk_record_inlined fields name num_nonconst attrs =
  let fields =
    Array.map
      ~f:(fun ((lbl : Types.label_description), _) ->
        find_with_default lbl.Types.lbl_attributes ~default:lbl.lbl_name)
      fields
  in
  Lambda.Blk_record_inlined { fields; name; num_nonconst; attributes = attrs }

let check_mel_attributes_inclusion (attrs1 : Parsetree.attributes)
    (attrs2 : Parsetree.attributes) lbl_name =
  let a = find_with_default attrs1 ~default:lbl_name in
  let b = find_with_default attrs2 ~default:lbl_name in
  if a = b then None else Some (a, b)

let check_duplicated_labels =
  let rec check_duplicated_labels_aux (lbls : Parsetree.label_declaration list)
      (coll : String.Set.t) =
    match lbls with
    | [] -> raise_notrace Not_found
    | { pld_name = { txt; _ } as pld_name; pld_attributes; _ } :: rest -> (
        if String.Set.mem txt coll then pld_name
        else
          let coll_with_lbl = String.Set.add txt coll in
          match List.find_map ~f:find_name_with_loc pld_attributes with
          | None -> check_duplicated_labels_aux rest coll_with_lbl
          | Some ({ txt = s; _ } as l) ->
              if
                String.Set.mem s coll
                (* use coll to make check a bit looser
                   allow cases like [ x : int [@as "x"]] *)
              then l
              else
                check_duplicated_labels_aux rest
                  (String.Set.add s coll_with_lbl))
  in
  fun lbls ->
    match check_duplicated_labels_aux lbls String.Set.empty with
    | l -> Some l
    | exception Not_found -> None
