(* Copyright (C) 2020 Hongbo Zhang, Authors of ReScript
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

type action_table = (Parsetree.expression option -> unit) Map_string.t

let structural_config_table : action_table ref =
  ref
    (Map_string.singleton "no_export" (fun x ->
         Js_config.no_export :=
           match x with Some e -> Ast_payload.assert_bool_lit e | None -> true))

let add_structure k v =
  structural_config_table := Map_string.add !structural_config_table k v

let signature_config_table : action_table ref = ref Map_string.empty

let add_signature k v =
  signature_config_table := Map_string.add !signature_config_table k v

let rec iter_on_bs_config_stru (x : Parsetree.structure) =
  match x with
  | [] -> ()
  | {
      Parsetree.pstr_desc =
        Pstr_attribute
          {
            attr_name = { txt = "bs.config" | "config"; loc };
            attr_payload = payload;
          };
    }
    :: _ ->
      Ext_list.iter (Ast_payload.ident_or_record_as_config loc payload)
        (fun x ->
          Ast_payload.table_dispatch !structural_config_table x |> ignore)
  (* [ppxlib] adds a wrapper like:

     [@@@ocaml.ppx.context ...]
     include (struct
       [@@@bs.config ..]
     end)
  *)
  | { pstr_desc = Pstr_attribute _ }
    :: {
         pstr_desc =
           Pstr_include
             {
               pincl_mod =
                 {
                   pmod_desc =
                     Pmod_constraint ({ pmod_desc = Pmod_structure stru }, _);
                 };
               _;
             };
       }
    :: _ ->
      iter_on_bs_config_stru stru
  | { pstr_desc = Pstr_attribute _ } :: rest -> iter_on_bs_config_stru rest
  | _ :: _ -> ()

let rec iter_on_bs_config_sigi (x : Parsetree.signature) =
  match x with
  | [] -> ()
  | {
      psig_desc =
        Psig_attribute
          {
            attr_name = { txt = "bs.config" | "config"; loc };
            attr_payload = payload;
          };
    }
    :: _ ->
      Ext_list.iter (Ast_payload.ident_or_record_as_config loc payload)
        (fun x ->
          Ast_payload.table_dispatch !signature_config_table x |> ignore)
  | { psig_desc = Psig_attribute _ } :: rest -> iter_on_bs_config_sigi rest
  | _ :: _ -> ()
