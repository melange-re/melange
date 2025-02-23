(* Copyright (C) 2024- Authors of Melange
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

let compile_letrec :
    (Ident.t * Value_rec_types.recursive_binding_kind * Lambda.lambda) list ->
    Lambda.lambda ->
    Lambda.lambda =
 fun input_bindings body ->
  let bindings =
    List.map input_bindings ~f:(fun (id, _kind, lambda) ->
        match lambda with
        | Lambda.Lfunction def -> { Lambda.id; def }
        | _ ->
            let def =
              Lambda.lfunction' ~kind:Curried ~params:[] ~return:Pgenval
                ~body:lambda
                ~attr:
                  {
                    Lambda.default_function_attribute with
                    smuggled_lambda = true;
                  }
                ~loc:Loc_unknown
            in

            { Lambda.id; def })
  in
  Lambda.Lletrec (bindings, body)
