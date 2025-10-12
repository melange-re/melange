(* Copyright (C) 2019 - Present Hongbo Zhang, Authors of ReScript
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

type t = {
  override : override_flag;
  ident : Longident.t Asttypes.loc;
  loc : location;
  attributes : attributes;
}

let destruct =
  let rec inner e acc =
    match e with
    | {
     pexp_desc =
       Pexp_open
         ( {
             popen_override = override;
             popen_expr = { pmod_desc = Pmod_ident ident; _ };
             _;
           },
           cont );
     pexp_attributes = attributes;
     pexp_loc = loc;
     _;
    } ->
        inner cont ({ override; ident; loc; attributes } :: acc)
    | _ -> (e, acc)
  in
  fun e -> inner e []

(** destruct {[ A.B.let open C in (a,b)]} *)
let destruct_open_tuple =
  let rec inner e acc : (t list * expression list * _) option =
    match e with
    | {
     pexp_desc =
       Pexp_open
         ( {
             popen_override = override;
             popen_expr = { pmod_desc = Pmod_ident ident; _ };
             _;
           },
           cont );
     pexp_loc = loc;
     pexp_attributes = attributes;
     _;
    } ->
        inner cont ({ override; ident; loc; attributes } :: acc)
    | { pexp_desc = Pexp_tuple es; pexp_attributes; _ } ->
        Some (acc, es, pexp_attributes)
    | _ -> None
  in
  fun e -> inner e []

let restore_exp xs qualifiers =
  List.fold_left qualifiers ~init:xs
    ~f:(fun x { override; ident; loc; attributes } ->
      Exp.open_ ~loc ~attrs:attributes
        (Ast_helper.Opn.mk ~override (Ast_helper.Mod.ident ident))
        x)
