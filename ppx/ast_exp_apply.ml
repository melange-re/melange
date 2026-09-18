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

open Import
open Ast_helper
module Operator = Melange_ffi.External_ffi_types.Operator

let ghost_loc loc = { loc with loc_ghost = true }

let ghost_locations =
  object
    inherit Ast_traverse.map
    method! location = ghost_loc
  end

let bound =
  let ocaml_obj_id = "__ocaml_internal_obj" in
  let rec needs_bound exp =
    match exp.pexp_desc with
    | Pexp_ident { txt = Lident _; _ } -> false
    | Pexp_constraint (e, _) -> needs_bound e
    | _ -> true
  in
  fun e ~loc ~opens ~f:(cb : expression -> expression) ->
    let generated_loc = ghost_loc loc in
    let body bounded_obj_arg =
      Ast_open_cxt.restore_exp ~loc:generated_loc (cb bounded_obj_arg) opens
    in
    let always_bind = match opens with [] -> false | _ :: _ -> true in
    match (always_bind, needs_bound e) with
    | false, false -> body (ghost_locations#expression e)
    | _ ->
        let binding_loc = ghost_loc e.pexp_loc in
        Exp.let_ ~loc:generated_loc Nonrecursive
          [
            Vb.mk ~loc:binding_loc
              (Pat.var ~loc:binding_loc
                 { txt = ocaml_obj_id; loc = binding_loc })
              e;
          ]
          (body
             (Exp.ident ~loc:binding_loc
                { txt = Lident ocaml_obj_id; loc = binding_loc }))

type app_pattern = {
  op : Operator.t;
  loc : Location.t; (* locatoin is the location of whole expression #4451 *)
  args : expression list;
}

let view_as_app =
  let check_and_discard (args : (arg_label * expression) list) =
    List.map args ~f:(fun (label, x) ->
        Error.err_if_label ~loc:x.pexp_loc label;
        x)
  in
  fun fn ~is_operator ->
    match fn.pexp_desc with
    | Pexp_apply
        ({ pexp_desc = Pexp_ident { txt = Lident operator; _ }; _ }, args) -> (
        match Operator.of_string operator with
        | Some op when is_operator op ->
            Some { op; loc = fn.pexp_loc; args = check_and_discard args }
        | Some _ | None -> None)
    | _ -> None

let is_inner_operator = function
  | Operator.Method | Operator.Property -> true
  | Operator.Pipe | Operator.Setter -> false

let app_exp_mapper =
  let rec exclude_with_val =
    let rec exclude (xs : 'a list) (p : 'a -> bool) : 'a list =
      match xs with
      | [] -> []
      | x :: xs -> if p x then exclude xs p else x :: exclude xs p
    in
    fun l p ->
      match l with
      | [] -> None
      | a0 :: xs -> (
          if p a0 then Some (exclude xs p)
          else
            match xs with
            | [] -> None
            | a1 :: rest -> (
                if p a1 then Some (a0 :: exclude rest p)
                else
                  match exclude_with_val rest p with
                  | None -> None
                  | Some rest -> Some (a0 :: a1 :: rest)))
  in
  let sane_property_name_check loc s =
    if String.contains s '#' then
      Location.raise_errorf ~loc
        "property name (`%s') cannot contain special character `#'" s
  in
  fun e
    ((self, super) : Ast_traverse.map * (expression -> expression))
    fn
    args
  ->
    (* - (f##paint) 1 2
     - (f#@paint) 1 2 *)
    match view_as_app fn ~is_operator:is_inner_operator with
    | Some
        {
          op;
          loc;
          args = [ obj; { pexp_desc = Pexp_ident { txt = Lident name; _ }; _ } ];
        } ->
        {
          e with
          pexp_desc =
            (match op with
            | Operator.Method ->
                Ast_uncurry_apply.method_apply ~loc self obj name args
            | Operator.Property ->
                Ast_uncurry_apply.property_apply ~loc self obj name args
            | Operator.Pipe | Operator.Setter -> assert false);
        }
    | Some { op; loc; _ } ->
        let operator = Operator.to_string op in
        Location.raise_errorf ~loc "%s expect f%sproperty arg0 arg2 form"
          operator operator
    | None -> (
        match view_as_app e ~is_operator:Operator.is_infix with
        | Some { op = Operator.Pipe; args = [ a_; f_ ]; loc } -> (
            (*
        a |. f
        a |. f b c [@u]  --> f a b c [@u]
        a |. M.(f b c) --> M.f a M.b M.c
        a |. (g |. b)
        a |. M.Some
        a |. `Variant
        a |. (b |. f c [@u]) *)
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
                Mel_ast_invariant.warn_discarded_unused_attributes
                  fn1.pexp_attributes;

                {
                  e with
                  pexp_desc =
                    Pexp_apply
                      ( { fn1 with pexp_attributes = fn1.pexp_attributes },
                        (Nolabel, a) :: args );
                }
            | _ -> (
                match Ast_open_cxt.destruct f with
                | ( {
                      pexp_desc = Pexp_tuple xs;
                      pexp_attributes = tuple_attrs;
                      _;
                    },
                    wholes ) ->
                    let generated_loc = ghost_loc loc in
                    let transformed =
                      bound a ~loc ~opens:wholes ~f:(fun bounded_obj_arg ->
                          {
                            f with
                            pexp_desc =
                              Pexp_tuple
                                (List.map
                                   ~f:(fun fn ->
                                     match fn.pexp_desc with
                                     | Pexp_construct (ctor, None) ->
                                         {
                                           fn with
                                           pexp_desc =
                                             Pexp_construct
                                               (ctor, Some bounded_obj_arg);
                                           pexp_loc = generated_loc;
                                         }
                                     | Pexp_apply (fn, args) ->
                                         Mel_ast_invariant
                                         .warn_discarded_unused_attributes
                                           fn.pexp_attributes;
                                         {
                                           pexp_desc =
                                             Pexp_apply
                                               ( { fn with pexp_attributes = [] },
                                                 (Nolabel, bounded_obj_arg)
                                                 :: args );
                                           pexp_attributes = [];
                                           pexp_loc_stack = fn.pexp_loc_stack;
                                           pexp_loc = generated_loc;
                                         }
                                     | _ ->
                                         Exp.apply ~loc:generated_loc fn
                                           [ (Nolabel, bounded_obj_arg) ])
                                   xs);
                            pexp_attributes = tuple_attrs;
                            pexp_loc = generated_loc;
                          })
                    in
                    { transformed with pexp_loc = loc }
                | ( { pexp_desc = Pexp_apply (e, args); pexp_attributes; _ },
                    (_ :: _ as wholes) ) ->
                    let fn = Ast_open_cxt.restore_exp e wholes in
                    let args =
                      List.map
                        ~f:(fun (lab, exp) ->
                          (lab, Ast_open_cxt.restore_exp exp wholes))
                        args
                    in
                    Mel_ast_invariant.warn_discarded_unused_attributes
                      pexp_attributes;
                    Exp.apply ~loc ~attrs:pexp_attributes fn
                      ((Nolabel, a) :: args)
                | _ -> (
                    match
                      ( exclude_with_val f_.pexp_attributes
                          Ast_attributes.is_uncurried,
                        f_.pexp_desc )
                    with
                    | Some other_attributes, Pexp_apply (fn1, args) ->
                        (* a |. f b c [@u]
                         Cannot process uncurried application early as the arity is wip *)
                        let fn1 = self#expression fn1 in
                        let args =
                          args
                          |> List.map ~f:(fun (l, e) -> (l, self#expression e))
                        in
                        Mel_ast_invariant.warn_discarded_unused_attributes
                          fn1.pexp_attributes;
                        {
                          e with
                          pexp_desc =
                            Ast_uncurry_apply.uncurry_fn_apply ~loc:e.pexp_loc
                              self fn1 ((Nolabel, a) :: args);
                          pexp_attributes = e.pexp_attributes @ other_attributes;
                        }
                    | _ ->
                        Ast_helper.Exp.apply ~loc ~attrs:e.pexp_attributes f
                          [ (Nolabel, a) ])))
        | Some { op = Operator.Method; loc; args = [ obj; rest ] } -> (
            (* - obj##property
             - obj#(method a b )
             we should warn when we discard attributes
             gpr#1063 foo##(bar##baz) we should rewrite (bar##baz)
                 first  before pattern match.
                 currently the pattern match is written in a top down style.
                 Another corner case: f##(g a b [@u])
          *)
            match rest with
            | {
             pexp_desc =
               Pexp_apply
                 ({ pexp_desc = Pexp_ident { txt = Lident name; _ }; _ }, args);
             pexp_attributes = attrs;
             _;
            } ->
                Mel_ast_invariant.warn_discarded_unused_attributes attrs;
                {
                  e with
                  pexp_desc =
                    Ast_uncurry_apply.method_apply ~loc self obj name args;
                }
            | {
             pexp_desc =
               ( Pexp_ident { txt = Lident name; _ }
               | Pexp_constant (Pconst_string (name, _, None)) );
             pexp_loc;
             _;
            } ->
                (* f##paint  *)
                sane_property_name_check pexp_loc name;
                {
                  e with
                  pexp_desc =
                    Ast_uncurry_apply.js_property loc (self#expression obj) name;
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
        | Some { op = Operator.Setter; loc; args = [ obj; arg ] } -> (
            match
              view_as_app obj ~is_operator:(fun op -> op = Operator.Method)
            with
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
                      Ast_uncurry_apply.method_apply ~loc self obj
                        (name
                       ^ Melange_ffi.External_ffi_types.Literals.setter_suffix)
                        [ (Nolabel, arg) ];
                  }
                  [%type: unit]
            | _ -> assert false)
        | Some { op = Operator.Pipe; loc; _ } ->
            Location.raise_errorf ~loc
              "invalid |. syntax, it can only be used as binary operator"
        | Some { op = Operator.Method; loc; _ } ->
            Location.raise_errorf ~loc
              "Js object ## expect syntax like obj##(paint (a,b)) "
        | Some { op; _ } ->
            Location.raise_errorf "invalid %s syntax" (Operator.to_string op)
        | None -> (
            match
              exclude_with_val e.pexp_attributes Ast_attributes.is_uncurried
            with
            | None -> super e
            | Some pexp_attributes ->
                {
                  e with
                  pexp_desc =
                    Ast_uncurry_apply.uncurry_fn_apply ~loc:e.pexp_loc self fn
                      args;
                  pexp_attributes;
                }))
