(* Copyright (C) 2018 Hongbo Zhang, Authors of ReScript
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

open Ast_helper

type exp = Parsetree.expression

let rec no_need_bound (exp : exp) =
  match exp.pexp_desc with
  | Pexp_ident { txt = Lident _ } -> true
  | Pexp_constraint (e, _) -> no_need_bound e
  | _ -> false

let ocaml_obj_id = "__ocaml_internal_obj"

let bound (e : exp) (cb : exp -> _) =
  if no_need_bound e then cb e
  else
    let loc = e.pexp_loc in
    Exp.let_ ~loc Nonrecursive
      [ Vb.mk ~loc (Pat.var ~loc { txt = ocaml_obj_id; loc }) e ]
      (cb (Exp.ident ~loc { txt = Lident ocaml_obj_id; loc }))

let default_expr_mapper = Bs_ast_mapper.default_mapper.expr

let check_and_discard (args : Ast_compatible.args) =
  Ext_list.map args (fun (label, x) ->
      Bs_syntaxerr.err_if_label x.pexp_loc label;
      x)

type app_pattern = {
  op : string;
  loc : Location.t; (* locatoin is the location of whole expression #4451 *)
  args : Parsetree.expression list;
}

let sane_property_name_check loc s =
  if String.contains s '#' then
    Location.raise_errorf ~loc
      "property name (%s) can not contain speical character #" s

(* match fn as *)
let view_as_app (fn : exp) (s : string list) : app_pattern option =
  match fn.pexp_desc with
  | Pexp_apply ({ pexp_desc = Pexp_ident { txt = Lident op; _ } }, args)
    when Ext_list.has_string s op ->
      Some { op; loc = fn.pexp_loc; args = check_and_discard args }
  | _ -> None

let inner_ops = [ "##"; "#@" ]
let infix_ops = [ "|."; "#="; "##" ]

let app_exp_mapper (e : exp) (self : Bs_ast_mapper.mapper) (fn : exp)
    (args : Ast_compatible.args) : exp =
  (* - (f##paint) 1 2
     - (f#@paint) 1 2
  *)
  match view_as_app fn inner_ops with
  | Some
      {
        op;
        loc;
        args = [ obj; { pexp_desc = Pexp_ident { txt = Lident name; _ }; _ } ];
      } ->
      {
        e with
        pexp_desc =
          (if op = "##" then
           Ast_uncurry_apply.method_apply loc self obj name args
          else Ast_uncurry_apply.property_apply loc self obj name args);
      }
  | Some { op; loc } ->
      Location.raise_errorf ~loc "%s expect f%sproperty arg0 arg2 form" op op
  | None -> (
      match view_as_app e infix_ops with
      | Some { op = "|."; args = [ obj_arg; fn ]; loc } -> (
          (*
        a |. f
        a |. f b c [@bs]  --> f a b c [@bs]
        a |. M.(f b c) --> M.f a M.b M.c
        a |. (g |. b)
        a |. M.Some
        a |. `Variant
        a |. (b |. f c [@bs])
      *)
          let new_obj_arg = self.expr self obj_arg in
          let fn = self.expr self fn in
          match fn.pexp_desc with
          | Pexp_variant (label, None) ->
              { fn with pexp_desc = Pexp_variant (label, Some new_obj_arg) }
          | Pexp_construct (ctor, None) ->
              { fn with pexp_desc = Pexp_construct (ctor, Some new_obj_arg) }
          | Pexp_apply (fn, args) ->
              Bs_ast_invariant.warn_discarded_unused_attributes
                fn.pexp_attributes;
              {
                pexp_desc = Pexp_apply (fn, (Nolabel, new_obj_arg) :: args);
                pexp_attributes = [];
                pexp_loc_stack = fn.pexp_loc_stack;
                pexp_loc = fn.pexp_loc;
              }
          | _ -> (
              match Ast_open_cxt.destruct fn [] with
              | ( { pexp_desc = Pexp_tuple xs; pexp_attributes = tuple_attrs },
                  wholes ) ->
                  Ast_open_cxt.restore_exp
                    (bound new_obj_arg (fun bounded_obj_arg ->
                         {
                           pexp_desc =
                             Pexp_tuple
                               (Ext_list.map xs (fun fn ->
                                    match fn.pexp_desc with
                                    | Pexp_construct (ctor, None) ->
                                        {
                                          fn with
                                          pexp_desc =
                                            Pexp_construct
                                              (ctor, Some bounded_obj_arg);
                                        }
                                    | Pexp_apply (fn, args) ->
                                        Bs_ast_invariant
                                        .warn_discarded_unused_attributes
                                          fn.pexp_attributes;
                                        {
                                          Parsetree.pexp_desc =
                                            Pexp_apply
                                              ( fn,
                                                (Nolabel, bounded_obj_arg)
                                                :: args );
                                          pexp_attributes = [];
                                          pexp_loc_stack = fn.pexp_loc_stack;
                                          pexp_loc = fn.pexp_loc;
                                        }
                                    | _ ->
                                        Ast_compatible.app1 ~loc:fn.pexp_loc fn
                                          bounded_obj_arg));
                           pexp_attributes = tuple_attrs;
                           pexp_loc = fn.pexp_loc;
                           pexp_loc_stack = fn.pexp_loc_stack;
                         }))
                    wholes
              | ( { pexp_desc = Pexp_apply (e, args); pexp_attributes },
                  (_ :: _ as wholes) ) ->
                  let fn = Ast_open_cxt.restore_exp e wholes in
                  let args =
                    Ext_list.map args (fun (lab, exp) ->
                        (lab, Ast_open_cxt.restore_exp exp wholes))
                  in
                  Bs_ast_invariant.warn_discarded_unused_attributes
                    pexp_attributes;
                  {
                    pexp_desc = Pexp_apply (fn, (Nolabel, new_obj_arg) :: args);
                    pexp_attributes = [];
                    pexp_loc = loc;
                    pexp_loc_stack = [ loc ];
                  }
              | _ -> Ast_compatible.app1 ~loc fn new_obj_arg))
      | Some { op = "##"; loc; args = [ obj; rest ] } -> (
          (* - obj##property
             - obj#(method a b )
             we should warn when we discard attributes
             gpr#1063 foo##(bar##baz) we should rewrite (bar##baz)
                 first  before pattern match.
                 currently the pattern match is written in a top down style.
                 Another corner case: f##(g a b [@bs])
          *)
          match rest with
          | {
           pexp_desc =
             Pexp_apply
               ({ pexp_desc = Pexp_ident { txt = Lident name; _ }; _ }, args);
           pexp_attributes = attrs;
          } ->
              Bs_ast_invariant.warn_discarded_unused_attributes attrs;
              {
                e with
                pexp_desc =
                  Ast_uncurry_apply.method_apply loc self obj name args;
              }
          | {
           pexp_desc =
             ( Pexp_ident { txt = Lident name; _ }
             | Pexp_constant (Pconst_string (name, _, None)) );
           pexp_loc;
          }
          (* f##paint  *) ->
              sane_property_name_check pexp_loc name;
              {
                e with
                pexp_desc = Ast_util.js_property loc (self.expr self obj) name;
              }
          | _ -> Location.raise_errorf ~loc "invalid ## syntax")
      (* we can not use [:=] for precedece cases
         like {[i @@ x##length := 3 ]}
         is parsed as {[ (i @@ x##length) := 3]}
         since we allow user to create Js objects in OCaml, it can be of
         ref type
         {[
           let u = object (self)
             val x = ref 3
             method setX x = self##x := 32
             method getX () = !self##x
           end
         ]}
      *)
      | Some { op = "#="; loc; args = [ obj; arg ] } -> (
          match view_as_app obj [ "##" ] with
          | Some
              {
                args =
                  [
                    obj;
                    {
                      pexp_desc =
                        ( Pexp_ident { txt = Lident name }
                        | Pexp_constant (Pconst_string (name, _, None)) );
                      pexp_loc;
                    };
                  ];
              } ->
              sane_property_name_check pexp_loc name;
              Exp.constraint_ ~loc
                {
                  e with
                  pexp_desc =
                    Ast_uncurry_apply.method_apply loc self obj
                      (name ^ Literals.setter_suffix)
                      [ (Nolabel, arg) ];
                }
                (Ast_literal.type_unit ~loc ())
          | _ -> assert false)
      | Some { op = "|."; loc } ->
          Location.raise_errorf ~loc
            "invalid |. syntax, it can only be used as binary operator"
      | Some { op = "##"; loc } ->
          Location.raise_errorf ~loc
            "Js object ## expect syntax like obj##(paint (a,b)) "
      | Some { op } -> Location.raise_errorf "invalid %s syntax" op
      | None -> (
          match
            Ext_list.exclude_with_val e.pexp_attributes Ast_attributes.is_bs
          with
          | None -> default_expr_mapper self e
          | Some pexp_attributes ->
              {
                e with
                pexp_desc =
                  Ast_uncurry_apply.uncurry_fn_apply e.pexp_loc self fn args;
                pexp_attributes;
              }))
