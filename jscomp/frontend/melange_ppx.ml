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

(* When we design a ppx, we should keep it simple, and also think about
   how it would work with other tools like merlin and ocamldep *)

(*
   1. extension point
   {[
     [%bs.raw{| blabla |}]
   ]}
   will be desugared into
   {[
     let module Js =
     struct unsafe_js : string -> 'a end
     in Js.unsafe_js {| blabla |}
   ]}
   The major benefit is to better error reporting (with locations).
   Otherwise

   {[

     let f u = Js.unsafe_js u
     let _ = f (1 + 2)
   ]}
   And if it is inlined some where
*)

open Ppxlib

let () =
  Ast_derive_projector.init ();
  Ast_derive_js_mapper.init ()

let succeed attr attrs =
  match attrs with
  | [ _ ] -> ()
  | _ ->
      Bs_ast_invariant.mark_used_bs_attribute attr;
      Bs_ast_invariant.warn_discarded_unused_attributes attrs

let local_module_name =
  let v = ref 0 in
  fun () ->
    incr v;
    "local_" ^ string_of_int !v

let expand_reverse (stru : Ast_structure.t) (acc : Ast_structure.t) :
    Ast_structure.t =
  if stru = [] then acc
  else (
    Typemod_hide.check stru;
    let local_module_name = local_module_name () in
    let last_loc = (List.hd stru).pstr_loc in
    let stru = List.rev stru in
    let first_loc = (List.hd stru).pstr_loc in
    let loc = { first_loc with loc_end = last_loc.loc_end } in
    let open Ast_helper in
    Str.module_ ~loc
      {
        pmb_name = { txt = Some local_module_name; loc };
        pmb_expr =
          {
            pmod_desc = Pmod_structure stru;
            pmod_loc = loc;
            pmod_attributes = [];
          };
        pmb_attributes = Typemod_hide.attrs;
        pmb_loc = loc;
      }
    :: Str.open_ ~loc
         (Opn.mk ~loc ~override:Override
            (Mod.ident ~loc
               { Asttypes.txt = Longident.Lident local_module_name; loc }))
    :: acc)

let mapper =
  object (self)
    inherit Ppxlib.Ast_traverse.map as super

    method! expression (e : Parsetree.expression) =
      match e.pexp_desc with
      (* Its output should not be rewritten anymore *)
      | Pexp_extension extension ->
          Ast_exp_extension.handle_extension e self extension
      | Pexp_constant (Pconst_string (s, loc, Some delim)) ->
          Ast_utf8_string_interp.transform e s loc delim
      (* End rewriting *)
      | Pexp_function cases -> (
          (* {[ function [@bs.exn]
                | Not_found -> 0
                | Invalid_argument -> 1
              ]}*)
          match
            Ast_attributes.process_pexp_fun_attributes_rev e.pexp_attributes
          with
          | false, _ -> super#expression e
          | true, pexp_attributes ->
              Ast_bs_open.convertBsErrorFunction e.pexp_loc self pexp_attributes
                cases)
      | Pexp_fun (label, _, pat, body) -> (
          match Ast_attributes.process_attributes_rev e.pexp_attributes with
          | Nothing, _ -> super#expression e
          | Uncurry _, pexp_attributes ->
              {
                e with
                pexp_desc =
                  Ast_uncurry_gen.to_uncurry_fn e.pexp_loc self label pat body;
                pexp_attributes;
              }
          | Method _, _ ->
              Location.raise_errorf ~loc:e.pexp_loc
                "%@meth is not supported in function expression"
          | Meth_callback _, pexp_attributes ->
              (* FIXME: does it make sense to have a label for [this] ? *)
              {
                e with
                pexp_desc =
                  Ast_uncurry_gen.to_method_callback e.pexp_loc self label pat
                    body;
                pexp_attributes;
              })
      | Pexp_apply (fn, args) ->
          Ast_exp_apply.app_exp_mapper e (self, super#expression) fn args
      | Pexp_object { pcstr_self; pcstr_fields } -> (
          match Ast_attributes.process_bs e.pexp_attributes with
          | true, pexp_attributes ->
              {
                e with
                pexp_desc =
                  Ast_util.ocaml_obj_as_js_object e.pexp_loc self pcstr_self
                    pcstr_fields;
                pexp_attributes;
              }
          | false, _ -> super#expression e)
      | Pexp_match
          ( b,
            [
              {
                pc_lhs =
                  { ppat_desc = Ppat_construct ({ txt = Lident "true" }, None) };
                pc_guard = None;
                pc_rhs = t_exp;
              };
              {
                pc_lhs =
                  {
                    ppat_desc = Ppat_construct ({ txt = Lident "false" }, None);
                  };
                pc_guard = None;
                pc_rhs = f_exp;
              };
            ] )
      | Pexp_match
          ( b,
            [
              {
                pc_lhs =
                  {
                    ppat_desc = Ppat_construct ({ txt = Lident "false" }, None);
                  };
                pc_guard = None;
                pc_rhs = f_exp;
              };
              {
                pc_lhs =
                  { ppat_desc = Ppat_construct ({ txt = Lident "true" }, None) };
                pc_guard = None;
                pc_rhs = t_exp;
              };
            ] ) ->
          super#expression
            { e with pexp_desc = Pexp_ifthenelse (b, t_exp, Some f_exp) }
      | Pexp_let (r, vbs, sub_expr) ->
          {
            e with
            pexp_desc =
              Pexp_let
                ( r,
                  Ast_tuple_pattern_flatten.value_bindings_mapper self vbs,
                  self#expression sub_expr );
          }
      | _ -> super#expression e

    method! core_type (typ : Parsetree.core_type) =
      Ast_core_type_class_type.typ_mapper (self, super#core_type) typ

    method! class_type
        ({ pcty_attributes; pcty_loc } as ctd : Parsetree.class_type) =
      match Ast_attributes.process_bs pcty_attributes with
      | false, _ -> super#class_type ctd
      | true, pcty_attributes -> (
          match ctd.pcty_desc with
          | Pcty_signature { pcsig_self; pcsig_fields } ->
              let pcsig_self = self#core_type pcsig_self in
              {
                ctd with
                pcty_desc =
                  Pcty_signature
                    {
                      pcsig_self;
                      pcsig_fields =
                        Ast_core_type_class_type.handle_class_type_fields
                          (self, super#class_type_field)
                          pcsig_fields;
                    };
                pcty_attributes;
              }
          | Pcty_open _ (* let open M in CT *) | Pcty_constr _
          | Pcty_extension _ | Pcty_arrow _ ->
              Location.raise_errorf ~loc:pcty_loc
                "invalid or unused attribute `bs`")
    (* {[class x : int -> object
                 end [@bs]
               ]}
               Actually this is not going to happpen as below is an invalid syntax
               {[class type x = int -> object
                   end[@bs]]}
    *)

    method! class_expr (ce : Parsetree.class_expr) =
      match ce.pcl_desc with
      | Pcl_let (r, vbs, sub_ce) ->
          {
            ce with
            pcl_desc =
              Pcl_let
                ( r,
                  Ast_tuple_pattern_flatten.value_bindings_mapper self vbs,
                  self#class_expr sub_ce );
          }
      | _ -> super#class_expr ce

    method! signature_item (sigi : Parsetree.signature_item) =
      match sigi.psig_desc with
      | Psig_type (rf, tdcls) ->
          Ast_tdcls.handleTdclsInSigi (self, super#signature_item) sigi rf tdcls
      | Psig_value ({ pval_attributes; pval_prim } as value_desc) -> (
          let pval_attributes = self#attributes pval_attributes in
          if Ast_attributes.rs_externals pval_attributes pval_prim then
            Ast_external.handleExternalInSig self value_desc sigi
          else
            match Ast_attributes.has_inline_payload pval_attributes with
            | Some
                ({
                   attr_payload =
                     PStr [ { pstr_desc = Pstr_eval ({ pexp_desc }, _) } ];
                   _;
                 } as attr) -> (
                match pexp_desc with
                | Pexp_constant (Pconst_string (s, _, dec)) ->
                    succeed attr pval_attributes;
                    {
                      sigi with
                      psig_desc =
                        Psig_value
                          {
                            value_desc with
                            pval_prim =
                              External_ffi_types.inline_string_primitive s dec;
                            pval_attributes = [];
                          };
                    }
                | Pexp_constant (Pconst_integer (s, None)) ->
                    succeed attr pval_attributes;
                    let s = Int32.of_string s in
                    {
                      sigi with
                      psig_desc =
                        Psig_value
                          {
                            value_desc with
                            pval_prim =
                              External_ffi_types.inline_int_primitive s;
                            pval_attributes = [];
                          };
                    }
                | Pexp_constant (Pconst_integer (s, Some 'L')) ->
                    let s = Int64.of_string s in
                    succeed attr pval_attributes;
                    {
                      sigi with
                      psig_desc =
                        Psig_value
                          {
                            value_desc with
                            pval_prim =
                              External_ffi_types.inline_int64_primitive s;
                            pval_attributes = [];
                          };
                    }
                | Pexp_constant (Pconst_float (s, None)) ->
                    succeed attr pval_attributes;
                    {
                      sigi with
                      psig_desc =
                        Psig_value
                          {
                            value_desc with
                            pval_prim =
                              External_ffi_types.inline_float_primitive s;
                            pval_attributes = [];
                          };
                    }
                | Pexp_construct
                    ({ txt = Lident (("true" | "false") as txt) }, None) ->
                    succeed attr pval_attributes;
                    {
                      sigi with
                      psig_desc =
                        Psig_value
                          {
                            value_desc with
                            pval_prim =
                              External_ffi_types.inline_bool_primitive
                                (txt = "true");
                            pval_attributes = [];
                          };
                    }
                | _ -> super#signature_item sigi)
            | Some _ | None -> super#signature_item sigi)
      | _ -> super#signature_item sigi

    method! structure_item (str : Parsetree.structure_item) =
      match str.pstr_desc with
      | Pstr_type (rf, tdcls) (* [ {ptype_attributes} as tdcl ] *) ->
          Ast_tdcls.handleTdclsInStru (self, super#structure_item) str rf tdcls
      | Pstr_primitive prim
        when Ast_attributes.rs_externals prim.pval_attributes prim.pval_prim ->
          Ast_external.handleExternalInStru self prim str
      | Pstr_value
          ( Nonrecursive,
            [
              {
                pvb_pat = { ppat_desc = Ppat_var pval_name } as pvb_pat;
                pvb_expr;
                pvb_attributes;
                pvb_loc;
              };
            ] ) -> (
          let pvb_expr = self#expression pvb_expr in
          let pvb_attributes = self#attributes pvb_attributes in
          let has_inline_property =
            Ast_attributes.has_inline_payload pvb_attributes
          in
          match (has_inline_property, pvb_expr.pexp_desc) with
          | Some attr, Pexp_constant (Pconst_string (s, _, dec)) ->
              succeed attr pvb_attributes;
              {
                str with
                pstr_desc =
                  Pstr_primitive
                    {
                      pval_name;
                      pval_type = Ast_literal.type_string ();
                      pval_loc = pvb_loc;
                      pval_attributes = [];
                      pval_prim =
                        External_ffi_types.inline_string_primitive s dec;
                    };
              }
          | Some attr, Pexp_constant (Pconst_integer (s, None)) ->
              let s = Int32.of_string s in
              succeed attr pvb_attributes;
              {
                str with
                pstr_desc =
                  Pstr_primitive
                    {
                      pval_name;
                      pval_type = Ast_literal.type_int ();
                      pval_loc = pvb_loc;
                      pval_attributes = [];
                      pval_prim = External_ffi_types.inline_int_primitive s;
                    };
              }
          | Some attr, Pexp_constant (Pconst_integer (s, Some 'L')) ->
              let s = Int64.of_string s in
              succeed attr pvb_attributes;
              {
                str with
                pstr_desc =
                  Pstr_primitive
                    {
                      pval_name;
                      pval_type = Ast_literal.type_int64;
                      pval_loc = pvb_loc;
                      pval_attributes = [];
                      pval_prim = External_ffi_types.inline_int64_primitive s;
                    };
              }
          | Some attr, Pexp_constant (Pconst_float (s, None)) ->
              succeed attr pvb_attributes;
              {
                str with
                pstr_desc =
                  Pstr_primitive
                    {
                      pval_name;
                      pval_type = Ast_literal.type_float;
                      pval_loc = pvb_loc;
                      pval_attributes = [];
                      pval_prim = External_ffi_types.inline_float_primitive s;
                    };
              }
          | ( Some attr,
              Pexp_construct ({ txt = Lident (("true" | "false") as txt) }, None)
            ) ->
              succeed attr pvb_attributes;
              {
                str with
                pstr_desc =
                  Pstr_primitive
                    {
                      pval_name;
                      pval_type = Ast_literal.type_bool ();
                      pval_loc = pvb_loc;
                      pval_attributes = [];
                      pval_prim =
                        External_ffi_types.inline_bool_primitive (txt = "true");
                    };
              }
          | _ ->
              {
                str with
                pstr_desc =
                  Pstr_value
                    ( Nonrecursive,
                      Ast_tuple_pattern_flatten.value_bindings_mapper self
                        [ { pvb_pat; pvb_expr; pvb_attributes; pvb_loc } ] );
              })
      | Pstr_value (r, vbs) ->
          {
            str with
            pstr_desc =
              Pstr_value
                (r, Ast_tuple_pattern_flatten.value_bindings_mapper self vbs);
          }
      | Pstr_attribute { attr_name = { txt = "bs.config" | "config" }; _ } ->
          str
      | _ -> super#structure_item str

    method! structure (stru : Ast_structure.t) =
      match stru with
      | [] -> []
      | item :: rest -> (
          match item.pstr_desc with
          | Pstr_extension (({ txt = "bs.raw" | "raw"; loc }, payload), _attrs)
            ->
              Ast_exp_handle_external.handle_raw_structure loc payload
              :: self#structure rest
          | Pstr_extension (({ txt = "private" }, _), _) ->
              let rec aux acc (rest : Ast_structure.t) =
                match rest with
                | {
                    pstr_desc =
                      Pstr_extension (({ txt = "private"; loc }, payload), _);
                  }
                  :: next -> (
                    match payload with
                    | PStr work ->
                        aux
                          (Ext_list.rev_map_append work acc (fun x ->
                               self#structure_item x))
                          next
                    | PSig _ | PTyp _ | PPat _ ->
                        Location.raise_errorf ~loc
                          "private extension is not support")
                | _ -> expand_reverse acc (self#structure rest)
              in
              aux [] stru
          | _ -> self#structure_item item :: self#structure rest)

    method! label_declaration lbl =
      let lbl = super#label_declaration lbl in
      match lbl.pld_attributes with
      | [ { attr_name = { txt = "internal" }; _ } ] ->
          {
            lbl with
            pld_name =
              {
                lbl.pld_name with
                txt = String.capitalize_ascii lbl.pld_name.txt;
              };
            pld_attributes = [];
          }
      | _ -> lbl
  end

let () =
  Driver.V2.register_transformation "melange"
    ~impl:(fun _ctxt str ->
      Melange_compiler_libs.Location.set_input_name
        !Ocaml_common.Location.input_name;
      mapper#structure str)
    ~intf:(fun _ctxt sig_ ->
      Melange_compiler_libs.Location.set_input_name
        !Ocaml_common.Location.input_name;
      mapper#signature sig_)
