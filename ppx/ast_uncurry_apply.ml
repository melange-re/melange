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
open Ast_helper

(* TODO:
   have a final checking for property arities
     [#=],
*)
let jsInternal = Ast_literal.js_internal

(* we use the trick
   [( opaque e : _) ] to avoid it being inspected,
   the type constraint is avoid some syntactic transformation, e.g ` e |. (f g [@bs])`
   `opaque` is to avoid it being inspected in the type level
*)
let opaque_full_apply ~loc e =
  Pexp_constraint
    ( Exp.apply ~loc
        ~attrs:
          [
            (* Ignore warning 20 (`ignored-extra-argument`) on expressions such
             * as:
             *
             *   external x : < .. > Js.t = ""
             *   let () = x##fn "hello"
             *
             * OCaml thinks the extra argument is unused because we're
             * producing * an uncurried call to a JS function whose arity isn't
             * known at compile time. *)
            Ast_attributes.ignored_extra_argument;
          ]
        (Exp.ident { txt = Ast_literal.js_internal_full_apply; loc })
        [ (Nolabel, e) ],
      Typ.any ~loc () )

let generic_apply loc (self : Ast_traverse.map) obj args
    (cb : loc -> expression -> expression) =
  let obj = self#expression obj in
  let args =
    List.map
      ~f:(fun (lbl, e) ->
        Error.optional_err ~loc lbl;
        (lbl, self#expression e))
      args
  in
  let fn = cb loc obj in
  let args =
    match args with
    | [
     ( Nolabel,
       { pexp_desc = Pexp_construct ({ txt = Lident "()"; _ }, None); _ } );
    ] ->
        []
    | _ -> args
  in
  let arity = List.length args in
  if arity = 0 then
    Pexp_apply
      (Exp.ident { txt = Ldot (jsInternal, "run"); loc }, [ (Nolabel, fn) ])
  else
    let arity_s = string_of_int arity in
    opaque_full_apply ~loc
      (Exp.apply ~loc
         (Exp.apply ~loc
            (Exp.ident ~loc { txt = Ast_literal.opaque; loc })
            [
              ( Nolabel,
                Exp.field ~loc
                  (Exp.constraint_ ~loc fn
                     (Typ.constr ~loc
                        {
                          txt = Ldot (Ast_literal.js_fn, "arity" ^ arity_s);
                          loc;
                        }
                        [ Typ.any ~loc () ]))
                  { txt = Ast_literal.hidden_field arity_s; loc } );
            ])
         args)

let method_apply loc (self : Ast_traverse.map) obj name args =
  let obj = self#expression obj in
  let args =
    List.map
      ~f:(fun (lbl, e) ->
        Error.optional_err ~loc lbl;
        (lbl, self#expression e))
      args
  in
  let fn = Exp.mk ~loc (Ast_util.js_property loc obj name) in
  let args =
    match args with
    | [
     ( Nolabel,
       { pexp_desc = Pexp_construct ({ txt = Lident "()"; _ }, None); _ } );
    ] ->
        []
    | _ -> args
  in
  let arity = List.length args in
  if arity = 0 then
    Pexp_apply
      ( Exp.ident
          { txt = Ldot (Ldot (Ast_literal.js_oo, "Internal"), "run"); loc },
        [ (Nolabel, fn) ] )
  else
    let arity_s = string_of_int arity in
    opaque_full_apply ~loc
      (Exp.apply ~loc
         (Exp.apply ~loc
            (Exp.ident ~loc { txt = Ast_literal.opaque; loc })
            [
              ( Nolabel,
                Exp.field ~loc
                  (Exp.constraint_ ~loc fn
                     (Typ.constr ~loc
                        {
                          txt = Ldot (Ast_literal.js_meth, "arity" ^ arity_s);
                          loc;
                        }
                        [ Typ.any ~loc () ]))
                  { loc; txt = Ast_literal.hidden_field arity_s } );
            ])
         args)

let uncurry_fn_apply loc self fn args =
  generic_apply loc self fn args (fun _ obj -> obj)

let property_apply loc self obj name args =
  generic_apply loc self obj args (fun loc obj ->
      Exp.mk ~loc (Ast_util.js_property loc obj name))
