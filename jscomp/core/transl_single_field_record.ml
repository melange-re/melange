(* Copyright (C) 2020 - Hongbo Zhang, Authors of ReScript
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
open Typedtree

(* Once typing has selected arity0, recover its original [#run] lowering.
   Keeping the synthetic unit argument until JavaScript printing would inhibit
   optimizations that depend on the argument count, including tail calls. *)
let zero_arity_callee expression =
  match expression.exp_desc with
  | Texp_apply
      ( {
          exp_desc =
            Texp_apply
              ( {
                  exp_desc =
                    Texp_ident (_, _, { val_kind = Val_prim primitive; _ });
                  _;
                },
                [
                  (Nolabel, Arg { exp_desc = Texp_field (callee, _, label); _ });
                ] );
          _;
        },
        [ (Nolabel, Arg { exp_desc = Texp_construct (_, constructor, []); _ }) ]
      )
    when primitive.prim_name = "%opaque"
         && label.lbl_name = "Call"
         && constructor.cstr_name = "()" -> (
      match Types.get_desc label.lbl_res with
      | Tconstr (Pdot (_, "arity0"), _, _) -> Some callee
      | _ -> None)
  | _ -> None

(* Keep the shared field name throughout typing, including the saved typedtree.
   Immediately before translation, restore the construction marker consumed by
   [wrap_single_field_record]. Record construction stays non-expansive and can
   still occur on the right-hand side of a recursive binding. *)
let prepare_for_translation structure =
  let callees = ref Ident.Map.empty in
  let rewrite expression =
    match expression.Typedtree.exp_desc with
    | Texp_record
        ({
           fields = [| (label, definition) |];
           representation = Record_unboxed _;
           extended_expression = None;
         } as record) -> (
        let name =
          List.find_map expression.exp_attributes ~f:(fun attribute ->
              match attribute.Parsetree.attr_name.txt with
              | "mel.internal.arity0" -> Some "I0"
              | "mel.internal.arity1" -> Some "I1"
              | _ -> None)
        in
        match name with
        | None -> expression
        | Some lbl_name ->
            {
              expression with
              exp_desc =
                Texp_record
                  {
                    record with
                    fields = [| ({ label with lbl_name }, definition) |];
                  };
            })
    | Texp_apply
        ( ({
             exp_desc =
               Texp_ident
                 (path, name, ({ val_kind = Val_prim primitive; _ } as value));
             _;
           } as fn),
          [ (Nolabel, Arg argument) ] )
      when primitive.prim_name = "#full_apply" -> (
        match zero_arity_callee argument with
        | None -> expression
        | Some callee ->
            let value =
              {
                value with
                val_kind =
                  Val_prim (Primitive.simple ~name:"#run" ~arity:1 ~alloc:true);
              }
            in
            let fn = { fn with exp_desc = Texp_ident (path, name, value) } in
            {
              expression with
              exp_desc = Texp_apply (fn, [ (Nolabel, Arg callee) ]);
            })
    | _ -> expression
  in
  let expr self expression =
    match expression.exp_desc with
    | Texp_let
        ( Nonrecursive,
          [
            {
              vb_pat =
                { pat_desc = Tpat_var (id, { txt = "melange$fn"; _ }, _); _ };
              vb_expr = callee;
              _;
            };
          ],
          body ) ->
        (* The temporary isolates warnings during typing. Inline its single use
           before translation to preserve FFI receivers and evaluation order. *)
        let callee = self.Tast_mapper.expr self callee in
        let previous = !callees in
        callees := Ident.Map.add ~key:id ~data:callee !callees;
        let body = self.expr self body in
        callees := previous;
        body
    | Texp_ident (Pident id, _, _) ->
        Ident.Map.find_default id !callees ~default:expression
    | _ -> rewrite (Tast_mapper.default.expr self expression)
  in
  let mapper = { Tast_mapper.default with expr } in
  mapper.structure mapper structure

let wrap_single_field_record loc lbl_name (lambda : Lambda.lambda) =
  match String.length lbl_name with
  | 0 -> lambda
  | len -> (
      match String.unsafe_get lbl_name 0 with
      | 'I' ->
          let arity_s = String.sub lbl_name ~pos:1 ~len:(len - 1) in
          Lambda.Lprim
            ( Pccall
                (Primitive.make ~name:"#fn_mk" ~alloc:true ~native_name:arity_s
                   ~native_repr_args:[ Same_as_ocaml_repr ]
                   ~native_repr_res:Same_as_ocaml_repr),
              [ lambda ],
              Debuginfo.Scoped_location.(of_location ~scopes:empty_scopes loc)
            )
      | _ -> lambda)
