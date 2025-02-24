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
module E = Js_exp_make
module S = Js_stmt_make

(* Note: can potentially be inconsistent, sometimes
   {[
     { x : 3 , y : undefined}
   ]}
   and
   {[
     {x : 3 }
   ]}
   But the default to be undefined  seems reasonable
*)

(* TODO: check stackoverflow *)
let assemble_obj_args
    (labels :
      Melange_ffi.External_arg_spec.Obj_label.t
      Melange_ffi.External_arg_spec.param
      list) (args : J.expression list) : J.block * J.expression =
  let rec aux
      (labels :
        Melange_ffi.External_arg_spec.Obj_label.t
        Melange_ffi.External_arg_spec.param
        list) args : (string * E.t) list * J.expression list * _ =
    match (labels, args) with
    | [], [] -> ([], [], [])
    | ( { arg_label = Obj_label { name = label }; arg_type = Arg_cst cst }
        :: labels,
        args ) ->
        let accs, eff, assign = aux labels args in
        ((label, Lam_compile_const.translate_arg_cst cst) :: accs, eff, assign)
    (* | {obj_arg_label = EmptyCst _ } :: rest  , args -> assert false  *)
    | { arg_label = Obj_empty; _ } :: labels, arg :: args ->
        (* unit type*)
        let ((accs, eff, assign) as r) = aux labels args in
        if Js_analyzer.no_side_effect_expression arg then r
        else (accs, arg :: eff, assign)
    | ( ({ arg_label = Obj_label { name = label }; _ } as arg_kind) :: labels,
        arg :: args ) -> (
        let accs, eff, assign = aux labels args in
        let acc, new_eff =
          Lam_compile_external_call.ocaml_to_js_eff ~arg_label:Arg_label
            ~arg_type:arg_kind.arg_type arg
        in
        match acc with
        | Splice2 _ | Splice0 -> assert false
        | Splice1 x -> ((label, x) :: accs, List.append new_eff eff, assign)
        (* evaluation order is undefined *))
    | ( ({ arg_label = Obj_optional { name = label; _ }; arg_type } as arg_kind)
        :: labels,
        arg :: args ) ->
        let ((accs, eff, assign) as r) = aux labels args in
        Js_of_lam_option.destruct_optional arg ~for_sure_none:r
          ~for_sure_some:(fun x ->
            let acc, new_eff =
              Lam_compile_external_call.ocaml_to_js_eff ~arg_label:Arg_label
                ~arg_type x
            in
            match acc with
            | Splice2 _ | Splice0 -> assert false
            | Splice1 x -> ((label, x) :: accs, List.append new_eff eff, assign))
          ~not_sure:(fun _ -> (accs, eff, (arg_kind, arg) :: assign))
    | { arg_label = Obj_empty | Obj_label _ | Obj_optional _; _ } :: _, [] ->
        assert false
    | [], _ :: _ -> assert false
  in
  let map, eff, assignment = aux labels args in
  match assignment with
  | [] ->
      ( [],
        match eff with
        | [] -> E.obj map
        | x :: xs -> E.seq (E.fuse_to_seq x xs) (E.obj map) )
  | _ ->
      let v = Ident.create_tmp () in
      let var_v = E.var v in
      ( S.define_variable ~kind:Variable v
          (match eff with
          | [] -> E.obj map
          | x :: xs -> E.seq (E.fuse_to_seq x xs) (E.obj map))
        :: List.concat_map
             ~f:(fun
                 ( (xlabel :
                     Melange_ffi.External_arg_spec.Obj_label.t
                     Melange_ffi.External_arg_spec.param),
                   (arg : J.expression) )
               ->
               match xlabel with
               | {
                arg_label =
                  Obj_optional { name = label; for_sure_no_nested_option };
                _;
               } -> (
                   (* Need make sure whether assignment is effectful or not
                      to avoid code duplication
                   *)
                   let st, arg =
                     match S.named_expression arg with
                     | None -> ([], arg)
                     | Some (st, id) -> ([ st ], E.var id)
                   in
                   (* FIXME: see #2503 *)
                   let acc, new_eff =
                     Lam_compile_external_call.ocaml_to_js_eff
                       ~arg_label:Arg_empty ~arg_type:xlabel.arg_type
                       (if for_sure_no_nested_option then arg
                        else Js_of_lam_option.val_from_option arg)
                   in
                   match acc with
                   | Splice1 v ->
                       st
                       @ [
                           S.if_
                             (Js_of_lam_option.is_not_none arg)
                             [
                               S.exp
                                 (E.assign (E.dot var_v label)
                                    (match new_eff with
                                    | [] -> v
                                    | x :: xs -> E.seq (E.fuse_to_seq x xs) v));
                             ];
                         ]
                   | Splice0 | Splice2 _ -> assert false)
               | _ -> assert false)
             assignment,
        var_v )
