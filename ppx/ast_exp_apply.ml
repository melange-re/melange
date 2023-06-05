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

open Ppxlib
open Ast_helper

type exp = Parsetree.expression

let rec no_need_bound (exp : exp) =
  match exp.pexp_desc with
  | Pexp_ident { txt = Lident _; _ } -> true
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

let check_and_discard (args : (arg_label * Parsetree.expression) list) =
  List.map
    (fun (label, x) ->
      Error.err_if_label ~loc:x.pexp_loc label;
      x)
    args

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
  | Pexp_apply ({ pexp_desc = Pexp_ident { txt = Lident op; _ }; _ }, args)
    when Ext_list.has_string s op ->
      Some { op; loc = fn.pexp_loc; args = check_and_discard args }
  | _ -> None

let inner_ops = [ "##"; "#@" ]
let infix_ops = [ "|."; "#="; "##" ]

let app_exp_mapper (e : exp)
    ((self, super) :
      Ast_traverse.map * (Parsetree.expression -> Parsetree.expression))
    (fn : exp) (args : Ast_util.args) : exp =
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
  | Some { op; loc; _ } ->
      Location.raise_errorf ~loc "%s expect f%sproperty arg0 arg2 form" op op
  | None -> (
      match view_as_app e infix_ops with
      | Some { op = "|."; args = [ a_; f_ ]; loc } -> (
          (*
        a |. f
        a |. f b c [@bs]  --> f a b c [@bs]
        a |. M.(f b c) --> M.f a M.b M.c
        a |. (g |. b)
        a |. M.Some
        a |. `Variant
        a |. (b |. f c [@bs])
      *)
          let a = self#expression a_ in
          let f = self#expression f_ in
          match f.pexp_desc with
          | Pexp_variant (label, None) ->
              {
                f with
                pexp_desc = Pexp_variant (label, Some a);
                pexp_loc = e.pexp_loc;
              }
          | Pexp_construct (ctor, None) ->
              {
                f with
                pexp_desc = Pexp_construct (ctor, Some a);
                pexp_loc = e.pexp_loc;
              }
          | Pexp_apply (fn1, args) ->
              Bs_ast_invariant.warn_discarded_unused_attributes
                fn1.pexp_attributes;

              {
                pexp_desc =
                  Pexp_apply
                    ( { fn1 with pexp_attributes = fn1.pexp_attributes },
                      (Nolabel, a) :: args );
                pexp_loc = e.pexp_loc;
                pexp_loc_stack = e.pexp_loc_stack;
                pexp_attributes = e.pexp_attributes;
              }
          | _ -> (
              match Ast_open_cxt.destruct f [] with
              | ( { pexp_desc = Pexp_tuple xs; pexp_attributes = tuple_attrs; _ },
                  wholes ) ->
                  Ast_open_cxt.restore_exp
                    (bound a (fun bounded_obj_arg ->
                         {
                           pexp_desc =
                             Pexp_tuple
                               (List.map
                                  (fun fn ->
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
                                              ( { fn with pexp_attributes = [] },
                                                (Nolabel, bounded_obj_arg)
                                                :: args );
                                          pexp_attributes = [];
                                          pexp_loc_stack = fn.pexp_loc_stack;
                                          pexp_loc = fn.pexp_loc;
                                        }
                                    | _ ->
                                        let loc = fn.pexp_loc in
                                        [%expr [%e fn] [%e bounded_obj_arg]])
                                  xs);
                           pexp_attributes = tuple_attrs;
                           pexp_loc = f.pexp_loc;
                           pexp_loc_stack = f.pexp_loc_stack;
                         }))
                    wholes
              | ( { pexp_desc = Pexp_apply (e, args); pexp_attributes; _ },
                  (_ :: _ as wholes) ) ->
                  let fn = Ast_open_cxt.restore_exp e wholes in
                  let args =
                    List.map
                      (fun (lab, exp) ->
                        (lab, Ast_open_cxt.restore_exp exp wholes))
                      args
                  in
                  Bs_ast_invariant.warn_discarded_unused_attributes
                    pexp_attributes;
                  {
                    pexp_desc = Pexp_apply (fn, (Nolabel, a) :: args);
                    pexp_attributes;
                    pexp_loc = loc;
                    pexp_loc_stack = [];
                  }
              | _ -> (
                  match
                    ( Ext_list.exclude_with_val f_.pexp_attributes
                        Ast_attributes.is_bs,
                      f_.pexp_desc )
                  with
                  | Some other_attributes, Pexp_apply (fn1, args) ->
                      (* a |. f b c [@bs]
                         Cannot process uncurried application early as the arity is wip *)
                      let fn1 = self#expression fn1 in
                      let args =
                        args |> List.map (fun (l, e) -> (l, self#expression e))
                      in
                      Bs_ast_invariant.warn_discarded_unused_attributes
                        fn1.pexp_attributes;
                      {
                        pexp_desc =
                          Ast_uncurry_apply.uncurry_fn_apply e.pexp_loc self fn1
                            ((Nolabel, a) :: args);
                        pexp_loc = e.pexp_loc;
                        pexp_loc_stack = e.pexp_loc_stack;
                        pexp_attributes = e.pexp_attributes @ other_attributes;
                      }
                  | _ ->
                      Ast_helper.Exp.apply ~loc ~attrs:e.pexp_attributes f
                        [ (Nolabel, a) ])))
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
           _;
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
           _;
          }
          (* f##paint  *) ->
              sane_property_name_check pexp_loc name;
              {
                e with
                pexp_desc = Ast_util.js_property loc (self#expression obj) name;
              }
          | _ ->
              [%expr
                [%ocaml.error
                  [%e
                    Exp.constant
                      (Pconst_string ("invalid ## syntax", loc, None))]]])
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
                        ( Pexp_ident { txt = Lident name; _ }
                        | Pexp_constant (Pconst_string (name, _, None)) );
                      pexp_loc;
                      _;
                    };
                  ];
                _;
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
                [%type: unit]
          | _ -> assert false)
      | Some { op = "|."; loc; _ } ->
          Location.raise_errorf ~loc
            "invalid |. syntax, it can only be used as binary operator"
      | Some { op = "##"; loc; _ } ->
          Location.raise_errorf ~loc
            "Js object ## expect syntax like obj##(paint (a,b)) "
      | Some { op; _ } -> Location.raise_errorf "invalid %s syntax" op
      | None -> (
          match
            Ext_list.exclude_with_val e.pexp_attributes Ast_attributes.is_bs
          with
          | None -> super e
          | Some pexp_attributes ->
              {
                e with
                pexp_desc =
                  Ast_uncurry_apply.uncurry_fn_apply e.pexp_loc self fn args;
                pexp_attributes;
              }))
