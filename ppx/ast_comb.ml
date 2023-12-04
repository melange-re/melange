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

(* let fun_no_label ?loc ?attrs  pat body =
   Ast_compatible.fun_ ?loc ?attrs  pat body *)

(* let discard_exp_as_unit loc e =
   Ast_compatible.apply_simple ~loc
     (Exp.ident ~loc {txt = Ast_literal.Lid.ignore_id; loc})
     [Exp.constraint_ ~loc e
        (Ast_literal.type_unit ~loc ())] *)

let tuple_type_pair ?loc kind arity =
  let prefix = "a" in
  if arity = 0 then
    let ty = Typ.var ?loc (prefix ^ "0") in
    match kind with
    | `Run -> (ty, [], ty)
    | `Make ->
        let loc = Option.value ~default:Location.none loc in
        ([%type: unit -> [%t ty]], [], ty)
  else
    let number = arity + 1 in
    let tys =
      List.init ~len:number ~f:(fun i ->
          Typ.var ?loc (prefix ^ string_of_int (number - i - 1)))
    in
    match tys with
    | result :: rest ->
        ( List.fold_left
            ~f:(fun r arg ->
              let loc = Option.value ~default:Location.none loc in
              [%type: [%t arg] -> [%t r]])
            ~init:result rest,
          List.rev rest,
          result )
    | [] -> assert false

let to_js_type ~loc x = Typ.constr ~loc { txt = Ast_literal.js_obj; loc } [ x ]
let to_js_re_type ~loc = Typ.constr ~loc { txt = Ast_literal.js_re_id; loc } []

let to_undefined_type ~loc x =
  Typ.constr ~loc { txt = Ast_literal.js_undefined; loc } [ x ]

let single_non_rec_value name exp =
  Str.value Nonrecursive [ Vb.mk (Pat.var name) exp ]

let single_non_rec_val name ty = Sig.value (Val.mk name ty)
