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

(** we also need make it complete *)
let get_initial_exports count_non_variable_declaration_statement
    (export_set : Ident.Set.t) (block : J.block) =
  let result =
    List.fold_left
      ~f:(fun acc (st : J.statement) ->
        match st.statement_desc with
        | Variable { ident; value; _ } -> (
            if Ident.Set.mem ident acc then
              match value with
              | None -> acc
              | Some x ->
                  (* If not a function, we have to calcuate again and again
                      TODO: add hashtbl for a cache
                  *)
                  Ident.Set.(
                    union (Js_analyzer.free_variables_of_expression x) acc)
            else
              match value with
              | None -> acc
              | Some x ->
                  if Js_analyzer.no_side_effect_expression x then acc
                  else
                    Ident.Set.(
                      union
                        (Js_analyzer.free_variables_of_expression x)
                        (add ident acc)))
        | _ ->
            (* recalcuate again and again ... *)
            if
              Js_analyzer.no_side_effect_statement st
              || not count_non_variable_declaration_statement
            then acc
            else
              Ident.Set.(union (Js_analyzer.free_variables_of_statement st) acc))
      ~init:export_set block
  in
  (result, Ident.Set.(diff result export_set))

let shake_program (program : J.program) =
  let shake_block block export_set =
    let block = List.rev @@ Js_analyzer.rev_toplevel_flatten block in
    let loop block export_set : Ident.Set.t =
      let rec aux acc block =
        let result, diff = get_initial_exports false acc block in
        if Ident.Set.is_empty diff then result else aux result block
      in
      let first_iteration, delta = get_initial_exports true export_set block in
      if not @@ Ident.Set.is_empty delta then aux first_iteration block
      else first_iteration
    in

    let really_set = loop block export_set in
    List.fold_right
      ~f:(fun (st : J.statement) acc ->
        match st.statement_desc with
        | Variable { ident; value; _ } -> (
            if Ident.Set.mem ident really_set then st :: acc
            else
              match value with
              | None -> acc
              | Some x ->
                  if Js_analyzer.no_side_effect_expression x then acc
                  else st :: acc)
        | _ ->
            if Js_analyzer.no_side_effect_statement st then acc else st :: acc)
      block ~init:[]
  in
  { program with block = shake_block program.block program.export_set }
