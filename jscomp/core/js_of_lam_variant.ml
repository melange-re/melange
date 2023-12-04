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

(* we need destruct [undefined] when input is optional *)
let eval (arg : J.expression) (dispatches : (string * string) list) : E.t =
  if arg == E.undefined then E.undefined
  else
    match arg.expression_desc with
    | Str (_, s) -> E.str (List.assoc s dispatches)
    | _ ->
        E.of_block
          [
            S.string_switch arg
              (List.map
                 ~f:(fun (i, r) ->
                   ( i,
                     J.
                       {
                         switch_body = [ S.return_stmt (E.str r) ];
                         should_break = false;
                         (* FIXME: if true, still print break*)
                         comment = None;
                       } ))
                 dispatches);
          ]

(* invariant: optional is not allowed in this case *)
(* arg is a polyvar *)
let eval_as_event (arg : J.expression)
    (dispatches : (string * string) list option) =
  match arg.expression_desc with
  | Caml_block ([ { expression_desc = Str (_, s); _ }; cb ], _, _, Blk_poly_var)
    when Js_analyzer.no_side_effect_expression cb ->
      let v =
        match dispatches with
        | Some dispatches -> List.assoc s dispatches
        | None -> s
      in
      Splice2 (E.str v, cb)
  | _ ->
      Splice2
        ( (match dispatches with
          | Some dispatches ->
              E.of_block
                [
                  S.string_switch
                    (E.poly_var_tag_access arg)
                    (List.map
                       ~f:(fun (i, r) ->
                         ( i,
                           J.
                             {
                               switch_body = [ S.return_stmt (E.str r) ];
                               should_break = false;
                               (* FIXME: if true, still print break*)
                               comment = None;
                             } ))
                       dispatches);
                ]
          | None -> E.poly_var_tag_access arg),
          (* TODO: improve, one dispatch later,
             the problem is that we can not create bindings
             due to the
          *)
          E.poly_var_value_access arg )
(* FIXME:
   1. duplicated evaluation of expressions arg
      Solution: calcuate the arg once in the beginning
   2. avoid block for branches <  3
     or always?
     a === 444? "a" : a==222? "b"
*)

(* we need destruct [undefined] when input is optional *)
let eval_as_int (arg : J.expression) (dispatches : (string * int) list) : E.t =
  if arg == E.undefined then E.undefined
  else
    match arg.expression_desc with
    | Str (_, i) -> E.int (Int32.of_int (List.assoc i dispatches))
    | _ ->
        E.of_block
          [
            S.string_switch arg
              (List.map
                 ~f:(fun (i, r) ->
                   ( i,
                     J.
                       {
                         switch_body =
                           [ S.return_stmt (E.int (Int32.of_int r)) ];
                         should_break = false;
                         (* FIXME: if true, still print break*)
                         comment = None;
                       } ))
                 dispatches);
          ]

let eval_as_unwrap (arg : J.expression) : E.t =
  match arg.expression_desc with
  | Caml_block ([ { expression_desc = Number _; _ }; cb ], _, _, _) -> cb
  | _ -> E.poly_var_value_access arg
