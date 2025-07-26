(* Copyright (C) 2020- Hongbo Zhang, Authors of ReScript
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

let add_use =
  let add_or_update (h : 'a Ident.Hashtbl.t) (key : Ident.Hashtbl.key)
      ~update:modf ~default =
    match Ident.Hashtbl.find h key with
    | v -> Ident.Hashtbl.replace h key (modf v)
    | exception Not_found -> Ident.Hashtbl.add h key default
  in
  fun stats id -> add_or_update stats id ~update:succ ~default:1

let post_process_stats my_export_set
    (defined_idents : J.variable_declaration Ident.Hashtbl.t) stats =
  Ident.Hashtbl.iter
    (fun ident (v : J.variable_declaration) ->
      if Ident.Set.mem ident my_export_set then
        Js_op.update_used_stats v.ident_info Exported
      else
        let pure =
          match v.value with
          | None -> false (* can not happen *)
          | Some x -> Js_analyzer.no_side_effect_expression x
        in
        match Ident.Hashtbl.find stats ident with
        | exception Not_found ->
            Js_op.update_used_stats v.ident_info
              (if pure then Dead_pure else Dead_non_pure)
        | num ->
            if num = 1 then
              Js_op.update_used_stats v.ident_info
                (if pure then Once_pure else Used))
    defined_idents;
  defined_idents

(* Update ident info use cases, it is a non pure function,
    it will annotate [program] with some meta data
    TODO: Ident Hash could be improved,
    since in this case it can not be global?
*)
let super = Js_record_iter.super

let count_collects (* collect used status*) (stats : int Ident.Hashtbl.t)
    (* collect all def sites *)
      (defined_idents : J.variable_declaration Ident.Hashtbl.t) =
  {
    super with
    variable_declaration =
      (fun self ({ ident; value; property = _; ident_info = _ } as v) ->
        Ident.Hashtbl.add defined_idents ident v;
        match value with None -> () | Some x -> self.expression self x);
    ident = (fun _ id -> add_use stats id);
  }

let get_stats (program : J.program) : J.variable_declaration Ident.Hashtbl.t =
  let stats : int Ident.Hashtbl.t = Ident.Hashtbl.create 83 in
  let defined_idents : J.variable_declaration Ident.Hashtbl.t =
    Ident.Hashtbl.create 83
  in
  let my_export_set = program.export_set in
  let obj = count_collects stats defined_idents in
  obj.program obj program;
  post_process_stats my_export_set defined_idents stats
