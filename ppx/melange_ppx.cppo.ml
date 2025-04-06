(* Copyright (C) 2018 Hongbo Zhang, Authors of ReScript
 * Copyright (C) 2023 Antonio Nuno Monteiro
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

(*
   1. extension point
   {[
     [%mel.raw{| blabla |}]
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

open Import
open Ast_helper

module External = struct
  let rule =
    let rule label =
      let extractor = Ast_pattern.(single_expr_payload (pexp_ident __')) in
      let handler ~ctxt:_ ident =
        match ident with
        | { txt = Lident x; loc } ->
            Ast_extensions.handle_external loc x
            (* do we need support [%external gg.xx ]

               {[ Js.Undefined.to_opt (if Js.typeof x == "undefined" then x else Js.Undefined.empty ) ]}
            *)
        | { loc; txt = _ } ->
            Location.raise_errorf ~loc "external expects a single identifier"
      in
      let extender = Extension.V3.declare label Expression extractor handler in
      Context_free.Rule.extension extender
    in
    rule "mel.external"
end

module Raw = struct
  let rules =
    let stru_rule =
      let rule label =
        let extractor = Ast_pattern.__' in
        let handler ~ctxt:_ { loc; txt = payload } =
          Ast_extensions.handle_raw_structure loc payload
        in
        let extender =
          Extension.V3.declare label Structure_item extractor handler
        in
        Context_free.Rule.extension extender
      in
      rule "mel.raw"
    and rule =
      let rule label =
        let extractor = Ast_pattern.__' in
        let handler ~ctxt:_ { loc; txt = payload } =
          Ast_extensions.handle_raw ~kind:Raw_exp loc payload
        in
        let extender =
          Extension.V3.declare label Expression extractor handler
        in
        Context_free.Rule.extension extender
      in
      rule "mel.raw"
    in
    [ stru_rule; rule ]
end

module Private = struct
  module Typemod_hide = struct
    let no_type_defined (x : structure_item) =
      match x.pstr_desc with
      | Pstr_eval _ | Pstr_value _ | Pstr_primitive _ | Pstr_typext _
      | Pstr_exception _
      (* | Pstr_module {pmb_expr = {pmod_desc = Pmod_ident _} }  *) ->
          true
      | Pstr_include
          {
            pincl_mod =
              {
                pmod_desc =
                  Pmod_constraint
                    ( {
                        pmod_desc =
                          Pmod_structure [ { pstr_desc = Pstr_primitive _; _ } ];
                        _;
                      },
                      _ );
                _;
              };
            _;
          } ->
          true
          (* FIX #4881
             generated code from:
             {[
               external %private x : int -> int =  "x"
               [@@mel.module "./x"]
             ]}
          *)
      | _ -> false

    let check (x : structure) =
      List.iter
        ~f:(fun x ->
          if not (no_type_defined x) then
            Location.raise_errorf ~loc:x.pstr_loc
              "the structure is not supported in local extension")
        x

    let attrs : attributes =
      [
        Attr.mk
          { txt = "internal.local"; loc = Location.none }
          (PStr [])
      ]
  end

  let rule =
    let expand (stru : structure) =
      Typemod_hide.check stru;
      let last_loc = (List.hd stru).pstr_loc in
      let first_loc = (List.hd stru).pstr_loc in
      let loc = { first_loc with loc_end = last_loc.loc_end } in
      Str.open_
        (Opn.mk ~override:Override
           (Mod.structure ~loc ~attrs:Typemod_hide.attrs stru))
    in
    let rule label =
      let extractor = Ast_pattern.__' in
      let handler ~ctxt:_ { txt = payload; loc } =
        match payload with
        | PStr work -> expand work
        | PSig _ | PTyp _ | PPat _ ->
            Location.raise_errorf ~loc "private extension is not support"
      in

      let extender =
        Extension.V3.declare label Structure_item extractor handler
      in
      Context_free.Rule.extension extender
    in
    rule "private"
end

module Debugger = struct
  let rule =
    let rule label =
      let extractor = Ast_pattern.__' in
      let handler ~ctxt:_ { txt = payload; loc } =
        Exp.mk ~loc (Ast_extensions.handle_debugger loc payload)
      in

      let extender = Extension.V3.declare label Expression extractor handler in
      Context_free.Rule.extension extender
    in
    rule "mel.debugger"
end

module Re = struct
  let rule =
    let rule label =
      let extractor = Ast_pattern.__' in
      let handler ~ctxt:_ { txt = payload; loc } =
        Exp.constraint_ ~loc
          (Ast_extensions.handle_raw ~kind:Raw_re loc payload)
          (Typ.constr ~loc { txt = Ast_literal.js_re_id; loc } [])
      in

      let extender = Extension.V3.declare label Expression extractor handler in
      Context_free.Rule.extension extender
    in
    rule "mel.re"
end

module Time = struct
  let rule =
    let rule label =
      let extractor = Ast_pattern.__' in
      let handler ~ctxt:_ { txt = payload; loc } =
        match payload with
        | PStr [ { pstr_desc = Pstr_eval (e, _); _ } ] ->
            let locString =
              if loc.loc_ghost then "GHOST LOC"
              else
                let loc_start = loc.loc_start in
                let file, lnum, __ =
                  ( loc_start.pos_fname,
                    loc_start.pos_lnum,
                    loc_start.pos_cnum - loc_start.pos_bol )
                in
                Printf.sprintf "%s %d" (Filename.basename file) lnum
            in
            Exp.sequence ~loc
              [%expr
                [%e
                  Exp.ident ~loc
                    {
                      loc;
                      txt = Ldot (Ldot (Lident "Js", "Console"), "timeStart");
                    }]
                  [%e Exp.constant (Pconst_string (locString, loc, None))]]
              (Exp.let_ ~loc Nonrecursive
                 [ Vb.mk ~loc (Pat.var ~loc { loc; txt = "timed" }) e ]
                 (Exp.sequence ~loc
                    [%expr
                      [%e
                        Exp.ident ~loc
                          {
                            loc;
                            txt = Ldot (Ldot (Lident "Js", "Console"), "timeEnd");
                          }]
                        [%e Exp.constant (Pconst_string (locString, loc, None))]]
                    (Exp.ident ~loc { loc; txt = Lident "timed" })))
        | _ ->
            Location.raise_errorf ~loc
              "expect a boolean expression in the payload"
      in
      let extender = Extension.V3.declare label Expression extractor handler in
      Context_free.Rule.extension extender
    in
    rule "mel.time"
end

module Node = struct
  let rule =
    let rule label =
      let extractor = Ast_pattern.__' in
      let handler ~ctxt:_ ({ txt = payload; loc } : payload Location.loc) =
        let strip s = match s with "_module" -> "module" | x -> x in
        match Ast_payload.as_ident payload with
        | Some
            {
              txt =
                Lident
                  (("__filename" | "__dirname" | "_module" | "require") as name);
              loc;
            } ->
            let exp = Ast_extensions.handle_external loc (strip name) in
            let typ =
              Ast_core_type.lift_option_type
                (if name = "_module" then
                   Typ.constr ~loc
                     { txt = Ldot (Lident "Node", "node_module"); loc }
                     []
                 else if name = "require" then
                   Typ.constr ~loc
                     { txt = Ldot (Lident "Node", "node_require"); loc }
                     []
                 else [%type: string])
            in
            Exp.constraint_ ~loc exp typ
        | Some _ | None -> (
            match payload with
            | PTyp _ ->
                Location.raise_errorf ~loc
                  "Illegal payload, expect an expression payload instead of \
                   type payload"
            | PPat _ ->
                Location.raise_errorf ~loc
                  "Illegal payload, expect an expression payload instead of \
                   pattern  payload"
            | _ -> Location.raise_errorf ~loc "Illegal payload")
      in
      let extender = Extension.V3.declare label Expression extractor handler in
      Context_free.Rule.extension extender
    in
    rule "mel.node"
end

module Obj = struct
  let rule =
    let rule label =
      let extractor = Ast_pattern.__' in
      let handler ~ctxt:_ { txt = payload; loc } =
        match payload with
        | PStr
            [
              {
                pstr_desc =
                  Pstr_eval
                    ( ({ pexp_desc = Pexp_record (label_exprs, None); _ } as e),
                      _ );
                _;
              };
            ] ->
            {
              e with
              pexp_desc =
                Ast_object.record_as_js_object ~loc:e.pexp_loc label_exprs;
            }
        | _ -> Location.raise_errorf ~loc "%%mel.obj requires a record literal"
      in

      let extender = Extension.V3.declare label Expression extractor handler in
      Context_free.Rule.extension extender
    in
    rule "mel.obj"
end

module Mapper = struct
  let mapper =
    let pval_ffi ~pval_name ~pval_type ~pval_loc ffi =
      {
        pval_name;
        pval_type;
        pval_loc;
        pval_prim = Ast_external.pval_prim_default;
        pval_attributes = [ Ast_attributes.mel_ffi ffi ];
      };
    in
    let succeed attr attrs =
      match attrs with
      | [ _ ] -> ()
      | _ ->
          Mel_ast_invariant.mark_used_mel_attribute attr;
          Mel_ast_invariant.warn_discarded_unused_attributes attrs
    in
    object (self)
      inherit Ppxlib.Ast_traverse.map as super
      (* [Expansion_context.Base.t] Ppxlib.Ast_traverse.map_with_context as super *)

      method! class_type ({ pcty_attributes; pcty_loc; _ } as ctd : class_type)
          =
        (* {[class x : int -> object
                     end [@u]
                   ]}

           Actually this is not going to happpen as below is an invalid syntax

             {[class type x = int -> object
                 end[@u]]}
        *)
        match Ast_attributes.process_uncurried pcty_attributes with
        | false, _ -> super#class_type ctd
        | true, pcty_attributes -> (
            match ctd.pcty_desc with
            | Pcty_signature { pcsig_self; pcsig_fields } ->
                let pcty_desc =
                  let pcsig_self = self#core_type pcsig_self in
                  match
                    Ast_core_type_class_type.handle_class_type_fields
                      (self, super#class_type_field)
                      pcsig_fields
                  with
                  | Ok pcsig_fields ->
                    Pcty_signature { pcsig_self; pcsig_fields }
                  | Error (loc, s) ->
                    let pcsig_self =
                      [%type:
                        [%ocaml.error
                          [%e Exp.constant (Pconst_string (s, loc, None))]]]
                    in
                    Pcty_signature { pcsig_self; pcsig_fields = [] }
                in
                { ctd with pcty_desc; pcty_attributes }
            | Pcty_open _ (* let open M in CT *) | Pcty_constr _
            | Pcty_extension _ | Pcty_arrow _ ->
                Location.raise_errorf ~loc:pcty_loc
                  "invalid or unused attribute `[@u]")

      method! core_type typ =
        Ast_core_type_class_type.typ_mapper (self, super#core_type) typ

      method! expression e =
        match e.pexp_desc with
        | Pexp_apply (fn, args) ->
            Ast_exp_apply.app_exp_mapper e (self, super#expression) fn args
        | Pexp_constant (Pconst_string (s, loc, Some delim)) ->
            String_interp.transform e s ~loc ~delim
        | Pexp_function (_, _, Pfunction_cases (cases, _, _)) -> (
            (* {[ function [@mel.open]
                  | Not_found -> 0
                  | Invalid_argument -> 1
                ]} *)
            match
              Ast_attributes.process_pexp_fun_attributes_rev e.pexp_attributes
            with
            | false, _ -> super#expression e
            | true, pexp_attributes ->
                Ast_mel_open.convert_mel_error_function ~loc:e.pexp_loc self
                  pexp_attributes cases)
        | Pexp_function (args, _, Pfunction_body body) -> (
            match Ast_attributes.process_attributes_rev e.pexp_attributes with
            | Nothing, _ -> super#expression e
            | Uncurry _, pexp_attributes ->
                {
                  e with
                  pexp_desc =
                    Ast_uncurry_gen.to_uncurry_fn ~loc:e.pexp_loc self args body;
                  pexp_attributes;
                }
            | Method _, _ ->
                let loc = e.pexp_loc in
                [%expr
                  [%ocaml.error
                    [%e
                      Exp.constant
                        (Pconst_string
                           ( "%@meth is not supported in function expression",
                             loc,
                             None ))]]]
            | Meth_callback _, pexp_attributes ->
                (* FIXME: does it make sense to have a label for [this] ? *)
                {
                  e with
                  pexp_desc =
                    Ast_uncurry_gen.to_method_callback ~loc:e.pexp_loc self args
                      body;
                  pexp_attributes;
                })
        | Pexp_object { pcstr_self; pcstr_fields } -> (
            match Ast_attributes.process_uncurried e.pexp_attributes with
            | true, pexp_attributes ->
                {
                  e with
                  pexp_desc =
                    Ast_object.ocaml_object_as_js_object ~loc:e.pexp_loc self
                      pcstr_self pcstr_fields;
                  pexp_attributes;
                }
            | false, _ -> super#expression e)
        | Pexp_match
            ( b,
              [
                {
                  pc_lhs =
                    {
                      ppat_desc =
                        Ppat_construct ({ txt = Lident "true"; _ }, None);
                      _;
                    };
                  pc_guard = None;
                  pc_rhs = t_exp;
                };
                {
                  pc_lhs =
                    {
                      ppat_desc =
                        Ppat_construct ({ txt = Lident "false"; _ }, None);
                      _;
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
                      ppat_desc =
                        Ppat_construct ({ txt = Lident "false"; _ }, None);
                      _;
                    };
                  pc_guard = None;
                  pc_rhs = f_exp;
                };
                {
                  pc_lhs =
                    {
                      ppat_desc =
                        Ppat_construct ({ txt = Lident "true"; _ }, None);
                      _;
                    };
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

      method! class_expr ce =
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

      method! label_declaration lbl =
        (* Ad-hoc way to internalize stuff *)
        let lbl = super#label_declaration lbl in
        match lbl.pld_attributes with
        | [ { attr_name = { txt = "internal"; _ }; _ } ] ->
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

      method! structure_item str =
        match str.pstr_desc with
        | Pstr_primitive prim ->
            if Ast_attributes.rs_externals prim.pval_attributes prim.pval_prim
            then Ast_external.handleExternalInStru self prim str
            else
              super#structure_item
                {
                  str with
                  pstr_desc =
                    Pstr_primitive
                      {
                        prim with
                        pval_attributes =
                          Ast_attributes.unboxable_type_in_prim_decl
                          :: prim.pval_attributes;
                      };
                }
        | Pstr_value
            ( Nonrecursive,
              [
                {
                  pvb_pat =
                    { ppat_desc = Ppat_var pval_name_orig; _ } as pvb_pat_orig;
                  pvb_expr;
                  pvb_attributes;
                  pvb_loc;
                  pvb_constraint
                };
              ] ) -> (
            let attrs, found =
              Ast_attributes.has_mel_as_payload pvb_attributes
            in
            let pvb_pat, pval_name =
              match found with
              | Some ({ attr_payload; _ } as attr) ->
                  Mel_ast_invariant.mark_used_mel_attribute attr;
                  let pval_name =
                    {
                      txt =
                        Ast_payload.extract_mel_as_ident ~loc:pvb_loc
                          attr_payload;
                      loc = pval_name_orig.loc;
                    }
                  in
                  ( { pvb_pat_orig with ppat_desc = Ppat_var pval_name },
                    pval_name )
              | None -> (pvb_pat_orig, pval_name_orig)
            in
            let pvb_expr = self#expression pvb_expr in
            let pvb_attributes = self#attributes attrs in
            match
              ( Ast_attributes.has_inline_payload pvb_attributes,
                pvb_expr.pexp_desc )
            with
            | Some attr, Pexp_constant (Pconst_string (s, _, None)) ->
                succeed attr pvb_attributes;
                let loc = pvb_loc in
                {
                  str with
                  pstr_desc =
                    Pstr_primitive
                      (pval_ffi
                        ~pval_name
                        ~pval_type:[%type: string]
                        ~pval_loc:loc
                        (Melange_ffi.External_ffi_types.inline_string_primitive s));
                }
            | Some attr, Pexp_constant (Pconst_string (s, loc, Some dec)) -> (
                match
                  Melange_ffi.Utf8_string.transform ~loc ~delim:dec
                    (Ocaml_common.Ast_helper.Exp.constant
#if OCAML_VERSION >= (5, 3, 0)
                       {
                         pconst_desc = Pconst_string (s, loc, Some dec);
                         pconst_loc = loc;
                       }
#else
                       (Pconst_string (s, loc, Some dec))
#endif
                         )
                    s
                with
                | {
                 pexp_desc =
#if OCAML_VERSION >= (5, 3, 0)
                   Pexp_constant { pconst_desc = Pconst_string (s, _, dec); _ };
#else
                   Pexp_constant (Pconst_string (s, _, dec));
#endif
                 _;
                } ->
                    succeed attr pvb_attributes;
                    {
                      str with
                      pstr_desc =
                        Pstr_primitive
                          (pval_ffi
                            ~pval_name
                            ~pval_type:[%type: string]
                            ~pval_loc:pvb_loc
                            (Melange_ffi.External_ffi_types.inline_string_primitive s ?op:dec)
                   );
                    }
                | _ -> str)
            | Some attr, Pexp_constant (Pconst_integer (s, None)) ->
                let s = Int32.of_string s in
                succeed attr pvb_attributes;
                let loc = pvb_loc in
                {
                  str with
                  pstr_desc =
                    Pstr_primitive
                      (pval_ffi
                       ~pval_name
                       ~pval_type:[%type: int]
                       ~pval_loc:loc
                       (Melange_ffi.External_ffi_types.inline_int_primitive s))
                }
            | Some attr, Pexp_constant (Pconst_integer (s, Some 'L')) ->
                let s = Int64.of_string s in
                succeed attr pvb_attributes;
                let loc = pvb_loc in
                {
                  str with
                  pstr_desc =
                    Pstr_primitive
                      (pval_ffi
                        ~pval_name
                        ~pval_type:[%type: int64]
                        ~pval_loc:loc
                        (Melange_ffi.External_ffi_types.inline_int64_primitive s))
                }
            | Some attr, Pexp_constant (Pconst_float (s, None)) ->
                succeed attr pvb_attributes;
                let loc = pvb_loc in
                {
                  str with
                  pstr_desc =
                    Pstr_primitive
                      (pval_ffi
                        ~pval_name
                        ~pval_type:[%type: float]
                        ~pval_loc:loc
                        (Melange_ffi.External_ffi_types.inline_float_primitive s));
                }
            | ( Some attr,
                Pexp_construct
                  ({ txt = Lident (("true" | "false") as bool); _ }, None) ) ->
                succeed attr pvb_attributes;
                let loc = pvb_loc in
                {
                  str with
                  pstr_desc =
                    Pstr_primitive
                      (pval_ffi
                        ~pval_name
                        ~pval_type:[%type: bool]
                        ~pval_loc:loc
                        (Melange_ffi.External_ffi_types.inline_bool_primitive (bool = "true")));
                }
            | _ ->
                {
                  str with
                  pstr_desc =
                    Pstr_value
                      ( Nonrecursive,
                        Ast_tuple_pattern_flatten.value_bindings_mapper self
                          [ { pvb_pat; pvb_expr; pvb_attributes; pvb_loc; pvb_constraint } ] );
                })
        | Pstr_value (r, vbs) ->
            {
              str with
              pstr_desc =
                Pstr_value
                  (r, Ast_tuple_pattern_flatten.value_bindings_mapper self vbs);
            }
        | Pstr_attribute
            ({
               attr_name =
                 { txt = "mel.config"; loc = _ };
               _;
             } as attr) ->
            Mel_ast_invariant.mark_used_mel_attribute attr;
            str
        | Pstr_module
            ({
               pmb_name = { txt = Some _; loc = pmb_name_loc } as pmb_name_orig;
               pmb_attributes;
               pmb_loc;
               _;
             } as mb) ->
            let attrs, found =
              Ast_attributes.has_mel_as_payload pmb_attributes
            in
            let pmb_name =
              match found with
              | Some ({ attr_payload; _ } as attr) ->
                  Mel_ast_invariant.mark_used_mel_attribute attr;
                  {
                    txt =
                      Some
                        (Ast_payload.extract_mel_as_ident ~loc:pmb_loc
                           attr_payload);
                    loc = pmb_name_loc;
                  }
              | None -> pmb_name_orig
            in
            super#structure_item
              {
                str with
                pstr_desc =
                  Pstr_module { mb with pmb_name; pmb_attributes = attrs };
              }
        | Pstr_type (_r, tdcls) ->
            List.iter
              ~f:(fun (tdcl : type_declaration) ->
                match tdcl.ptype_kind with
                | Ptype_variant cstrs ->
                    List.iter
                      ~f:(function
                          | ({ attr_name= { txt = "mel.tag"; _ }; _ } as attr) ->
                            Mel_ast_invariant.mark_used_mel_attribute attr
                          | _ -> ())
                    tdcl.ptype_attributes;
                    List.iter
                      ~f:(fun
                          ({ pcd_attributes; _ } : constructor_declaration) ->
                        List.iter
                          ~f:(fun ({ attr_payload; _ } as attr) ->
                            match attr_payload with
                            | PStr
                                [
                                  {
                                    pstr_desc = Pstr_eval ({ pexp_desc; _ }, _);
                                    _;
                                  };
                                ] -> (
                                match pexp_desc with
                                | Pexp_constant
                                    (Pconst_string _ | Pconst_integer _) ->
                                    Mel_ast_invariant.mark_used_mel_attribute
                                      attr
                                | _ -> ())
                            | _ -> ())
                          pcd_attributes)
                      cstrs
                | _ -> ())
              tdcls;
            super#structure_item str
        | _ -> super#structure_item str

      method! signature_item sigi =
        match sigi.psig_desc with
        | Psig_value
            ({
               pval_attributes;
               pval_prim;
               pval_name = pval_name_orig;
               pval_loc;
               _;
             } as value_desc_orig) -> (
            let attrs, found =
              Ast_attributes.has_mel_as_payload pval_attributes
            in
            let value_desc =
              match found with
              | Some ({ attr_payload; _ } as attr) ->
                  Mel_ast_invariant.mark_used_mel_attribute attr;
                  {
                    value_desc_orig with
                    pval_name =
                      {
                        txt =
                          Ast_payload.extract_mel_as_ident ~loc:pval_loc
                            attr_payload;
                        loc = pval_name_orig.loc;
                      };
                  }
              | None -> value_desc_orig
            in
            let pval_attributes = self#attributes attrs in
            if Ast_attributes.rs_externals pval_attributes pval_prim then
              Ast_external.handleExternalInSig self value_desc sigi
            else
              match Ast_attributes.has_inline_payload pval_attributes with
              | Some
                  ({
                     attr_payload =
                       PStr
                         [ { pstr_desc = Pstr_eval ({ pexp_desc; _ }, _); _ } ];
                     _;
                   } as attr) -> (
                  match pexp_desc with
                  | Pexp_constant (Pconst_string (s, _, None)) ->
                      succeed attr pval_attributes;
                      {
                        sigi with
                        psig_desc =
                          Psig_value
                            {
                              value_desc with
                              pval_prim = Ast_external.pval_prim_default;
                              pval_attributes = [
                                Ast_attributes.mel_ffi
                                  (Melange_ffi.External_ffi_types.inline_string_primitive s);
                              ]
                            };
                      }
                  | Pexp_constant (Pconst_string (s, loc, Some dec)) -> (
                      match
                        Melange_ffi.Utf8_string.transform ~loc ~delim:dec
                          (Ocaml_common.Ast_helper.Exp.constant
#if OCAML_VERSION >= (5, 3, 0)
                             {
                               pconst_desc = Pconst_string (s, loc, Some dec);
                               pconst_loc = loc;
                             }
#else
                             (Pconst_string (s, loc, Some dec))
#endif
                               )
                          s
                      with
                      | {
                       pexp_desc =
                         Pexp_constant
#if OCAML_VERSION >= (5, 3, 0)
                           { pconst_desc = Pconst_string (s, _, dec); _ };
#else
                           (Pconst_string (s, _, dec));
#endif
                       _;
                      } ->
                          succeed attr pval_attributes;
                          {
                            sigi with
                            psig_desc =
                              Psig_value
                                {
                                  value_desc with
                                  pval_attributes = [
                                    Ast_attributes.mel_ffi
                                      (Melange_ffi.External_ffi_types.inline_string_primitive s ?op:dec)
                                  ];
                                  pval_prim = Ast_external.pval_prim_default;
                                };
                          }
                      | _ -> sigi)
                  | Pexp_constant (Pconst_integer (s, None)) ->
                      succeed attr pval_attributes;
                      let s = Int32.of_string s in
                      {
                        sigi with
                        psig_desc =
                          Psig_value
                            {
                              value_desc with
                              pval_attributes = [
                                Ast_attributes.mel_ffi
                                  (Melange_ffi.External_ffi_types.inline_int_primitive s)
                              ];
                              pval_prim = Ast_external.pval_prim_default;
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
                              pval_attributes = [
                                Ast_attributes.mel_ffi
                                  (Melange_ffi.External_ffi_types.inline_int64_primitive s)
                              ];
                              pval_prim = Ast_external.pval_prim_default;
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
                              pval_attributes = [
                                  Ast_attributes.mel_ffi
                                    (Melange_ffi.External_ffi_types.inline_float_primitive s)
                              ];
                              pval_prim = Ast_external.pval_prim_default;
                            };
                      }
                  | Pexp_construct
                      ({ txt = Lident (("true" | "false") as txt); _ }, None) ->
                      succeed attr pval_attributes;
                      {
                        sigi with
                        psig_desc =
                          Psig_value
                            {
                              value_desc with
                              pval_attributes = [
                                Ast_attributes.mel_ffi
                                  (Melange_ffi.External_ffi_types.inline_bool_primitive
                                    (txt = "true"))];
                              pval_prim = Ast_external.pval_prim_default;
                            };
                      }
                  | _ ->
                      super#signature_item
                        {
                          sigi with
                          psig_desc =
                            Psig_value
                              {
                                value_desc with
                                pval_attributes =
                                  Ast_attributes.unboxable_type_in_prim_decl
                                  :: pval_attributes;
                              };
                        })
              | Some _ | None ->
                  super#signature_item
                    {
                      sigi with
                      psig_desc =
                        Psig_value
                          {
                            value_desc with
                            pval_attributes =
                              Ast_attributes.unboxable_type_in_prim_decl
                              :: pval_attributes;
                          };
                    })
        | Psig_attribute
            ({
               attr_name =
                 { txt = "mel.config"; loc = _ };
               _;
             } as attr) ->
            Mel_ast_invariant.mark_used_mel_attribute attr;
            sigi
        | Psig_module
            ({
               pmd_name = { txt = Some _; loc = pmd_name_loc } as pmd_name_orig;
               pmd_attributes;
               pmd_loc;
               _;
             } as md) ->
            let attrs, found =
              Ast_attributes.has_mel_as_payload pmd_attributes
            in
            let pmd_name =
              match found with
              | Some ({ attr_payload; _ } as attr) ->
                  Mel_ast_invariant.mark_used_mel_attribute attr;
                  {
                    txt =
                      Some
                        (Ast_payload.extract_mel_as_ident ~loc:pmd_loc
                           attr_payload);
                    loc = pmd_name_loc;
                  }
              | None -> pmd_name_orig
            in
            super#signature_item
              {
                sigi with
                psig_desc =
                  Psig_module { md with pmd_name; pmd_attributes = attrs };
              }
        | _ -> super#signature_item sigi
    end
end

module Derivers = struct
  let _abstract =
    let args () = Deriving.Args.(empty +> flag "light") in
    let str_type_decl =
      Deriving.Generator.V2.make (args ()) (fun ~ctxt:_ (_, tdcls) light ->
          Ast_derive_abstract.derive_abstract_str ~light tdcls)
    and sig_type_decl =
      Deriving.Generator.V2.make (args ()) (fun ~ctxt:_ (_, tdcls) light ->
          Ast_derive_abstract.derive_abstract_sig ~light tdcls)
    in
    Deriving.add ~str_type_decl ~sig_type_decl "abstract"

  let _record_constructor =
    let args () = Deriving.Args.empty in
    let str_type_decl =
      Deriving.Generator.V2.make (args ()) (fun ~ctxt:_ (_, tdcls) ->
          Ast_derive_abstract.derive_js_constructor_str tdcls)
    and sig_type_decl =
      Deriving.Generator.V2.make (args ()) (fun ~ctxt:_ (_, tdcls) ->
          Ast_derive_abstract.derive_js_constructor_sig tdcls)
    in
    Deriving.add ~str_type_decl ~sig_type_decl "jsProperties"

  let _record_getters_setters =
    let args () = Deriving.Args.(empty +> flag "light") in
    let str_type_decl =
      Deriving.Generator.V2.make (args ()) (fun ~ctxt:_ (_, tdcls) light ->
          Ast_derive_abstract.derive_getters_setters_str ~light tdcls)
    and sig_type_decl =
      Deriving.Generator.V2.make (args ()) (fun ~ctxt:_ (_, tdcls) light ->
          Ast_derive_abstract.derive_getters_setters_sig ~light tdcls)
    in
    Deriving.add ~str_type_decl ~sig_type_decl "getSet"

  let gen_structure_signature loc (tdcls : type_declaration list) ~str ~sig_ =
    Ast_helper.
      [
        Str.include_ ~loc
          (Incl.mk ~loc
             (Mod.constraint_ ~loc
                (Mod.structure ~loc (str tdcls))
                (Mty.signature ~loc (sig_ tdcls))));
      ]

  let _jsConverter =
    let args () = Deriving.Args.(empty +> flag "newType") in
    let str_type_decl =
      Deriving.Generator.V2.make (args ()) (fun ~ctxt (_, tdcls) newType ->
          let loc = Expansion_context.Deriver.derived_item_loc ctxt in
          let str = Ast_derive_js_mapper.derive_structure ~newType
          and sig_ = Ast_derive_js_mapper.derive_signature ~newType in
          gen_structure_signature loc tdcls ~str ~sig_)
    and sig_type_decl =
      Deriving.Generator.V2.make (args ()) (fun ~ctxt:_ (_, tdcls) newType ->
          Ast_derive_js_mapper.derive_signature ~newType tdcls)
    in
    Deriving.add ~str_type_decl ~sig_type_decl "jsConverter"

  let _accessors =
    let str_type_decl =
      Deriving.Generator.V2.make Deriving.Args.empty (fun ~ctxt (_, tdcls) ->
          let loc = Expansion_context.Deriver.derived_item_loc ctxt in
          let str = Ast_derive_projector.derive_structure
          and sig_ = Ast_derive_projector.derive_signature in
          gen_structure_signature loc tdcls ~str ~sig_)
    and sig_type_decl =
      Deriving.Generator.V2.make Deriving.Args.empty (fun ~ctxt:_ (_, tdcls) ->
          Ast_derive_projector.derive_signature tdcls)
    in
    Deriving.add ~str_type_decl ~sig_type_decl "accessors"
end

let () =
  Ocaml_common.Location.(
    register_error_of_exn (fun exn ->
        match Melange_compiler_libs.Location.error_of_exn exn with
        | Some (`Ok report) -> Some report
        | None | Some `Already_displayed -> None))

let () =
  Driver.add_arg "-unsafe"
    (Unit (fun () -> Ocaml_common.Clflags.unsafe := true))
    ~doc:" Do not compile bounds checking on array and string access";
  Driver.add_arg "-alert" (String Ocaml_common.Warnings.parse_alert_option)
    ~doc:"[unused|fragile|redundant|deprecated] Turn off alerting from the PPX";
  Driver.V2.register_transformation "melange"
    ~rules:
      (Raw.rules
      @ [
          External.rule;
          Private.rule;
          Debugger.rule;
          Re.rule;
          Time.rule;
          Node.rule;
          Obj.rule;
        ])
    ~impl:(fun ctxt str ->
      let input_name = Expansion_context.Base.input_name ctxt in
      Ocaml_common.Location.input_name := input_name;
      let ast = Mapper.mapper#structure str in
      Mel_ast_invariant.emit_external_warnings_on_structure ast;
      ast)
    ~intf:(fun ctxt sig_ ->
      let input_name = Expansion_context.Base.input_name ctxt in
      Ocaml_common.Location.input_name := input_name;
      let ast = Mapper.mapper#signature sig_ in
      Mel_ast_invariant.emit_external_warnings_on_signature ast;
      ast)
