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

open Import

type action_table = (Parsetree.expression option -> unit) String.Map.t

let structural_config_table : action_table ref =
  let assert_bool_lit (e : Parsetree.expression) =
    match e.pexp_desc with
    | Pexp_construct ({ txt = Lident "true"; _ }, None) -> true
    | Pexp_construct ({ txt = Lident "false"; _ }, None) -> false
    | _ ->
        Location.raise_errorf ~loc:e.pexp_loc
          "Expected a boolean literal (`true' or `false')"
  in
  ref
    (String.Map.singleton "no_export" (fun x ->
         Js_config.no_export :=
           match x with Some e -> assert_bool_lit e | None -> true))

let add_structure key data =
  structural_config_table := String.Map.add ~key ~data !structural_config_table

let signature_config_table : action_table ref = ref String.Map.empty

let add_signature key data =
  signature_config_table := String.Map.add ~key ~data !signature_config_table

let rec iter_on_mel_config_stru = function
  | [] -> ()
  | {
      Parsetree.pstr_desc =
        Pstr_attribute
          { attr_name = { txt = "mel.config"; loc }; attr_payload = payload; _ };
      _;
    }
    :: _ ->
      List.iter
        ~f:(fun x ->
          Ast_payload.table_dispatch !structural_config_table x |> ignore)
        (Ast_payload.ident_or_record_as_config ~loc payload)
  (* [ppxlib] adds a wrapper like:

     [@@@ocaml.ppx.context ...]
     include (struct
       [@@@mel.config ..]
     end)
  *)
  | { pstr_desc = Pstr_attribute _; _ }
    :: {
         pstr_desc =
           Pstr_include
             {
               pincl_mod =
                 {
                   pmod_desc =
                     Pmod_constraint ({ pmod_desc = Pmod_structure stru; _ }, _);
                   _;
                 };
               _;
             };
         _;
       }
    :: _ ->
      iter_on_mel_config_stru stru
  | { pstr_desc = Pstr_attribute _; _ } :: rest -> iter_on_mel_config_stru rest
  | _ :: _ -> ()

let rec iter_on_mel_config_sigi = function
  | [] -> ()
  | {
      Parsetree.psig_desc =
        Psig_attribute
          { attr_name = { txt = "mel.config"; loc }; attr_payload = payload; _ };
      _;
    }
    :: _ ->
      List.iter
        ~f:(fun x ->
          Ast_payload.table_dispatch !signature_config_table x |> ignore)
        (Ast_payload.ident_or_record_as_config ~loc payload)
  | { psig_desc = Psig_attribute _; _ } :: rest -> iter_on_mel_config_sigi rest
  | _ :: _ -> ()
