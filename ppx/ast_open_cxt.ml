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

type whole = {
  override_flag : override_flag;
  ident : Longident.t Asttypes.loc;
  loc : location;
  attributes : attributes;
}

type t = whole list

let rec destruct (e : expression) (acc : t) =
  match e.pexp_desc with
  | Pexp_open
      ( {
          popen_override = override_flag;
          popen_expr = { pmod_desc = Pmod_ident lid; _ };
          _;
        },
        cont ) ->
      destruct cont
        ({
           override_flag;
           ident = lid;
           loc = e.pexp_loc;
           attributes = e.pexp_attributes;
         }
        :: acc)
  | _ -> (e, acc)

(**
   destruct such pattern
   {[ A.B.let open C in (a,b)]}
*)
let rec destruct_open_tuple (e : expression) (acc : t) :
    (t * expression list * _) option =
  match e.pexp_desc with
  | Pexp_open
      ( {
          popen_override = override_flag;
          popen_expr = { pmod_desc = Pmod_ident lid; _ };
          _;
        },
        cont ) ->
      destruct_open_tuple cont
        ({
           override_flag;
           ident = lid;
           loc = e.pexp_loc;
           attributes = e.pexp_attributes;
         }
        :: acc)
  | Pexp_tuple es -> Some (acc, es, e.pexp_attributes)
  | _ -> None

let restore_exp (xs : expression) (qualifiers : t) =
  List.fold_left
    ~f:(fun x { override_flag = flag; ident = lid; loc; attributes = attrs } ->
      {
        pexp_desc =
          Pexp_open
            (Ast_helper.Opn.mk ~override:flag (Ast_helper.Mod.ident lid), x);
        pexp_attributes = attrs;
        pexp_loc = loc;
        pexp_loc_stack = [ loc ];
      })
    ~init:xs qualifiers
