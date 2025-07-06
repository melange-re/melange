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

type arg_expression = Splice0 | Splice1 of E.t | Splice2 of E.t * E.t

let dispatch_with_default dispatches s =
  match List.assoc_opt s dispatches with
  | Some r -> Lam_compile_const.translate_arg_cst r
  | None -> E.str s

(* we need destruct [undefined] when input is optional *)
let eval (arg : J.expression)
    (dispatches : (string * Melange_ffi.External_arg_spec.Arg_cst.t) list) : E.t
    =
  if arg == E.undefined then arg
  else
    match arg.expression_desc with
    | Caml_block
        {
          fields = { expression_desc = Str s; _ } :: payload;
          tag_info = Blk_poly_var;
          tag;
          mutable_flag;
        } ->
        {
          arg with
          expression_desc =
            Caml_block
              {
                fields = dispatch_with_default dispatches s :: payload;
                tag_info = Blk_poly_var;
                tag;
                mutable_flag;
              };
        }
    | Str s -> dispatch_with_default dispatches s
    | _ ->
        E.of_block
          [
            S.string_switch arg
              (List.map
                 ~f:(fun (i, r) ->
                   ( Lambda.String i,
                     {
                       J.switch_body =
                         [
                           S.return_stmt (Lam_compile_const.translate_arg_cst r);
                         ];
                       should_break = false;
                       (* FIXME: if true, still print break*)
                       comment = None;
                     } ))
                 dispatches);
          ]

let eval_descr (arg : J.expression)
    (dispatches : (string * Melange_ffi.External_arg_spec.Arg_cst.t) list) =
  match arg.expression_desc with
  | Caml_block
      {
        fields = [ { expression_desc = Str s; _ }; cb ];
        tag_info = Blk_poly_var;
        _;
      }
    when Js_analyzer.no_side_effect_expression cb ->
      Splice2 (dispatch_with_default dispatches s, cb)
  | _ -> (
      match dispatches with
      | [] -> Splice2 (E.poly_var_tag_access arg, E.poly_var_value_access arg)
      | dispatches ->
          let k =
            E.of_block
              [
                S.string_switch
                  (E.poly_var_tag_access arg)
                  (List.map
                     ~f:(fun (i, r) ->
                       let r = Lam_compile_const.translate_arg_cst r in
                       ( Lambda.String i,
                         J.
                           {
                             switch_body = [ S.return_stmt r ];
                             should_break = false;
                             (* FIXME: if true, still print break*)
                             comment = None;
                           } ))
                     dispatches);
              ]
          in
          Splice2 (k, E.poly_var_value_access arg))

(* FIXME:
   1. duplicated evaluation of expressions arg
      Solution: calcuate the arg once in the beginning
   2. avoid block for branches <  3
     or always?
     a === 444? "a" : a==222? "b"
*)

let eval_as_unwrap (arg : J.expression) : E.t =
  match arg.expression_desc with
  | Caml_block { fields = [ { expression_desc = Number _; _ }; cb ]; _ } -> cb
  | Str _ | Unicode _ -> arg
  | _ -> E.poly_var_value_access arg
