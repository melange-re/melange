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

(** [arity_of_fun pat e] tells the arity of
    expression [fun pat -> e] *)
let arity_of_fun =
  let rec arity_of_fun =
    let arity_aux params ~init =
      (* FIXME error on optional *)
      List.fold_left ~init
        ~f:(fun acc param ->
          match param with
          | { pparam_desc = Pparam_newtype _; _ } -> acc
          | {
           pparam_desc =
             Pparam_val
               ( _,
                 _,
                 {
                   ppat_desc = Ppat_construct ({ txt = Lident "()"; _ }, None);
                   _;
                 } );
           _;
          }
            when acc = 0 ->
              acc
          | { pparam_desc = Pparam_val (_, _, _); _ } -> acc + 1)
        params
    in
    fun acc params body ->
      let base = arity_aux params ~init:acc in
      match body with
      | { pexp_desc = Pexp_function (params', _, Pfunction_body body); _ } ->
          arity_of_fun base params' body
      | _ -> base
  in
  fun params body -> arity_of_fun 0 params body

let labels_of_fun =
  let rec labels_of_fun =
    let lbls_aux params ~init =
      List.fold_left ~init
        ~f:(fun acc param ->
          match param with
          | { pparam_desc = Pparam_newtype _; _ } -> acc
          | { pparam_desc = Pparam_val (l, _, _); _ } -> l :: acc)
        params
    in
    fun acc params body ->
      let base = lbls_aux params ~init:acc in
      match body with
      | { pexp_desc = Pexp_function (params', _, Pfunction_body body); _ } ->
          labels_of_fun base params' body
      | _ -> List.rev base
  in
  fun params body -> labels_of_fun [] params body
