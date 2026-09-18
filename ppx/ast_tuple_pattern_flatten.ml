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

let ghost_locations =
  object
    inherit Ast_traverse.map
    method! location loc = { loc with loc_ghost = true }
  end

let ghost loc = { loc with loc_ghost = true }

let module_field_bindings ~loc ~module_name lid_pats pvb_expr pvb_constraint =
  (* Constrain and unpack the package once so that all selected fields share
     the same module identity and are limited by the package signature. *)
  let module_name_loc = { loc; txt = Some module_name } in
  let pats, exprs =
    List.split
      (List.map
         ~f:(fun (lid, pat) ->
           match lid.txt with
           | Lident field ->
               ( pat,
                 Ast_helper.Exp.ident ~loc:lid.loc
                   { lid with txt = Ldot (Lident module_name, field) } )
           | _ ->
               Location.raise_errorf ~loc:lid.loc
                 "Pattern matching on modules requires simple labels")
         lid_pats)
  in
  let pvb_expr =
    match pvb_constraint with
    | Pvc_constraint { locally_abstract_univars = []; typ } ->
        Ast_helper.Exp.constraint_ ~loc pvb_expr typ
    | Pvc_coercion { ground; coercion } ->
        Ast_helper.Exp.coerce ~loc pvb_expr ground coercion
    | Pvc_constraint { locally_abstract_univars = _ :: _; typ } ->
        (* The parser only accepts locally abstract binders on variable
           patterns. A preceding PPX can still construct this AST, but its
           abstract field types cannot soundly escape the local unpack. *)
        Location.raise_errorf ~loc:typ.ptyp_loc
          "Locally abstract type constraints are not supported when pattern \
           matching on modules"
  in
  let tuple_or_single make_tuple = function
    | [ x ] -> x
    | xs -> make_tuple ~loc xs
  in
  let pvb_pat =
    tuple_or_single (fun ~loc xs -> Ast_helper.Pat.tuple ~loc xs) pats
  in
  let fields =
    tuple_or_single (fun ~loc xs -> Ast_helper.Exp.tuple ~loc xs) exprs
  in
  let pvb_expr =
    Ast_helper.Exp.letmodule ~loc module_name_loc
      (Ast_helper.Mod.unpack ~loc pvb_expr)
      fields
  in
  (pvb_pat, pvb_expr)

(*
  [let (a,b) = M.N.(c,d) ]
  =>
  [ let a = M.N.c
    and b = M.N.d ]
*)
let flatten_tuple_pattern_vb =
  let rec is_simple_pattern p =
    match p.ppat_desc with
    | Ppat_any | Ppat_var _ -> true
    | Ppat_constraint (p, _) -> is_simple_pattern p
    | _ -> false
  in
  fun (self : Ast_traverse.map)
    (vb : value_binding)
    (acc : value_binding list)
    :
    value_binding list
  ->
    let pvb_pat = self#pattern vb.pvb_pat in
    let pvb_expr = self#expression vb.pvb_expr in
    let pvb_attributes = self#attributes vb.pvb_attributes in
    let pvb_constraint =
      Option.map ~f:self#value_constraint vb.pvb_constraint
    in
    match (pvb_pat.ppat_desc, pvb_expr.pexp_desc, pvb_constraint) with
    | Ppat_tuple xs, _, _ when List.for_all ~f:is_simple_pattern xs -> (
        match Ast_open_cxt.destruct_open_tuple pvb_expr with
        | Some (wholes, es, tuple_attributes) when List.same_length es xs ->
            Mel_ast_invariant.warn_discarded_unused_attributes tuple_attributes;
            (* will be dropped*)
            let binding_loc = { vb.pvb_loc with loc_ghost = true } in
            let ghost_attributes = ghost_locations#attributes pvb_attributes in
            List.fold_right2
              ~f:(fun pat exp (keep_source_attributes, acc) ->
                let pvb_attributes =
                  if keep_source_attributes then pvb_attributes
                  else ghost_attributes
                in
                ( false,
                  {
                    pvb_pat = pat;
                    pvb_expr = Ast_open_cxt.restore_generated_exp exp wholes;
                    pvb_attributes;
                    pvb_loc = binding_loc;
                    pvb_constraint;
                  }
                  :: acc ))
              xs es ~init:(true, acc)
            |> snd
        | _ ->
            {
              pvb_pat;
              pvb_expr;
              pvb_loc = vb.pvb_loc;
              pvb_attributes;
              pvb_constraint;
            }
            :: acc)
    | ( Ppat_record (lid_pats, _),
        Pexp_pack { pmod_desc = Pmod_ident id; _ },
        Some pvb_constraint ) ->
        let loc = ghost vb.pvb_loc in
        let module_name =
          match id.txt with
          | Lident name | Ldot (_, name) -> name
          | Lapply _ -> "Melange_module"
        in
        let pvb_pat, pvb_expr =
          module_field_bindings ~loc ~module_name lid_pats pvb_expr
            pvb_constraint
        in
        {
          pvb_pat;
          pvb_expr;
          pvb_attributes;
          pvb_loc = vb.pvb_loc;
          pvb_constraint = None;
        }
        :: acc
    | ( Ppat_record (lid_pats, _),
        Pexp_pack { pmod_desc = Pmod_ident id; _ },
        None ) ->
        List.map
          ~f:(fun (lid, pat) ->
            match lid.txt with
            | Lident s ->
                {
                  pvb_pat = pat;
                  pvb_expr =
                    Ast_helper.Exp.ident ~loc:lid.loc
                      { lid with txt = Ldot (id.txt, s) };
                  pvb_attributes = [];
                  pvb_loc = pat.ppat_loc;
                  pvb_constraint;
                }
            | _ ->
                Location.raise_errorf ~loc:lid.loc
                  "Pattern matching on modules requires simple labels")
          lid_pats
        @ acc
    | _, _, _ ->
        {
          pvb_pat;
          pvb_expr;
          pvb_loc = vb.pvb_loc;
          pvb_attributes;
          pvb_constraint;
        }
        :: acc

(* XXX(anmonteiro): this one is a little brittle. Because it might introduce
   new value bindings, it must be called at every AST node that has a
   value_binding list. This means that we're one step behind if a new node is
   introduced upstream. *)
let value_bindings_mapper (self : Ast_traverse.map) (vbs : value_binding list) =
  List.fold_right ~f:(flatten_tuple_pattern_vb self) vbs ~init:[]
