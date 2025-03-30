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

let lift_option_type ({ ptyp_loc; _ } as ty) =
  {
    ptyp_desc =
      Ptyp_constr
        ( {
            txt = Lident "option" (* Ast_literal.predef_option *);
            loc = ptyp_loc;
          },
          [ ty ] );
    ptyp_loc;
    ptyp_loc_stack = [];
    ptyp_attributes = [];
  }

let is_unit ty =
  match ty.ptyp_desc with
  | Ptyp_constr ({ txt = Lident "unit"; _ }, []) -> true
  | _ -> false

let to_js_type ~loc x = Typ.constr ~loc { txt = Ast_literal.js_obj; loc } [ x ]
let make_obj ~loc xs = to_js_type ~loc (Typ.object_ ~loc xs Closed)

(**

{[ 'a . 'a -> 'b ]}
OCaml does not support such syntax yet
{[ 'a -> ('a. 'a -> 'b) ]}

*)
let rec get_uncurry_arity_aux ty acc =
  match ty.ptyp_desc with
  | Ptyp_arrow (_, _, new_ty) -> get_uncurry_arity_aux new_ty (succ acc)
  | Ptyp_poly (_, ty) -> get_uncurry_arity_aux ty acc
  | _ -> acc

(**
   {[ unit -> 'b ]} return arity 0
   {[ unit -> 'a1 -> a2']} arity 2
   {[ 'a1 -> 'a2 -> ... 'aN -> 'b ]} return arity N
*)
let get_uncurry_arity ty =
  match ty.ptyp_desc with
  | Ptyp_arrow
      ( Nolabel,
        { ptyp_desc = Ptyp_constr ({ txt = Lident "unit"; _ }, []); _ },
        rest ) -> (
      match rest with
      | { ptyp_desc = Ptyp_arrow _; _ } -> Some (get_uncurry_arity_aux rest 1)
      | _ -> Some 0)
  | Ptyp_arrow (_, _, rest) -> Some (get_uncurry_arity_aux rest 1)
  | _ -> None
