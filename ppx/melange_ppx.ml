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

let succeed attr attrs =
  match attrs with
  | [ _ ] -> ()
  | _ ->
      Bs_ast_invariant.mark_used_bs_attribute attr;
      Bs_ast_invariant.warn_discarded_unused_attributes attrs

module External = struct
  let rule =
    let rule label =
      let context = Extension.Context.expression in
      let extractor = Ast_pattern.(single_expr_payload (pexp_ident __')) in
      let handler ~ctxt:_ ident =
        match ident with
        | { txt = Lident x; loc } ->
            Ast_extensions.handle_external loc x
            |> Melange_ppxlib_ast.To_ppxlib.copy_expression
            (* do we need support [%external gg.xx ]

               {[ Js.Undefined.to_opt (if Js.typeof x == "undefined" then x else Js.Undefined.empty ) ]}
            *)
        | { loc; txt = _ } ->
            Location.raise_errorf ~loc "external expects a single identifier"
      in
      let extender = Extension.V3.declare label context extractor handler in
      Context_free.Rule.extension extender
    in
    rule "bs.external"
end

module Raw = struct
  let stru_rule =
    let rule label =
      let context = Extension.Context.structure_item in
      let extractor = Ast_pattern.(__') in
      let handler ~ctxt:_ { loc; txt = payload } =
        let stru =
          let payload = Melange_ppxlib_ast.Of_ppxlib.copy_payload payload in
          [ Ast_extensions.handle_raw_structure loc payload ]
        in
        Melange_ppxlib_ast.To_ppxlib.copy_structure stru |> List.hd
      in
      let extender = Extension.V3.declare label context extractor handler in
      Context_free.Rule.extension extender
    in
    rule "bs.raw"

  let rule =
    let rule label =
      let context = Extension.Context.expression in
      let extractor = Ast_pattern.(__') in
      let handler ~ctxt:_ { loc; txt = payload } =
        let payload = Melange_ppxlib_ast.Of_ppxlib.copy_payload payload in
        Ast_extensions.handle_raw ~kind:Raw_exp loc payload
        |> Melange_ppxlib_ast.To_ppxlib.copy_expression
      in
      let extender = Extension.V3.declare label context extractor handler in
      Context_free.Rule.extension extender
    in
    rule "bs.raw"

  let rules = [ stru_rule; rule ]
end

module Private = struct
  let expand (stru : Ast_structure.t) =
    Typemod_hide.check stru;
    let last_loc = (List.hd stru).pstr_loc in
    let first_loc = (List.hd stru).pstr_loc in
    let loc = { first_loc with loc_end = last_loc.loc_end } in
    Melange_compiler_libs.Ast_helper.
      [
        Str.open_
          (Opn.mk ~override:Override
             (Mod.structure ~loc ~attrs:Typemod_hide.attrs stru));
      ]
    |> Melange_ppxlib_ast.To_ppxlib.copy_structure |> List.hd

  let rule =
    let rule label =
      let context = Extension.Context.structure_item in
      let extractor = Ast_pattern.(__') in
      let handler ~ctxt:_ { txt = payload; loc } =
        match Melange_ppxlib_ast.Of_ppxlib.copy_payload payload with
        | PStr work -> expand work
        | PSig _ | PTyp _ | PPat _ ->
            Location.raise_errorf ~loc "private extension is not support"
      in

      let extender = Extension.V3.declare label context extractor handler in
      Context_free.Rule.extension extender
    in
    rule "private"
end

module Debugger = struct
  let rule =
    let rule label =
      let context = Extension.Context.expression in
      let extractor = Ast_pattern.(__') in
      let handler ~ctxt:_ { txt = payload; loc } =
        let payload = Melange_ppxlib_ast.Of_ppxlib.copy_payload payload in
        let open Melange_compiler_libs.Ast_helper in
        Exp.mk ~loc (Ast_extensions.handle_debugger loc payload)
        |> Melange_ppxlib_ast.To_ppxlib.copy_expression
      in

      let extender = Extension.V3.declare label context extractor handler in
      Context_free.Rule.extension extender
    in
    rule "bs.debugger"
end

module Re = struct
  let rule =
    let rule label =
      let context = Extension.Context.expression in
      let extractor = Ast_pattern.(__') in
      let handler ~ctxt:_ { txt = payload; loc } =
        let payload = Melange_ppxlib_ast.Of_ppxlib.copy_payload payload in
        let open Melange_compiler_libs.Ast_helper in
        Exp.constraint_ ~loc
          (Ast_extensions.handle_raw ~kind:Raw_re loc payload)
          (Ast_comb.to_js_re_type loc)
        |> Melange_ppxlib_ast.To_ppxlib.copy_expression
      in

      let extender = Extension.V3.declare label context extractor handler in
      Context_free.Rule.extension extender
    in
    rule "bs.re"
end

module Time = struct
  let rule =
    let rule label =
      let context = Extension.Context.expression in
      let extractor = Ast_pattern.(__') in
      let handler ~ctxt:_ { txt = payload; loc } =
        let open Melange_compiler_libs.Ast_helper in
        match Melange_ppxlib_ast.Of_ppxlib.copy_payload payload with
        | PStr [ { pstr_desc = Pstr_eval (e, _) } ] ->
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
            (* let e = self.expr self e in *)
            Exp.sequence ~loc
              (Ast_compatible.app1 ~loc
                 (Exp.ident ~loc
                    {
                      loc;
                      txt = Ldot (Ldot (Lident "Js", "Console"), "timeStart");
                    })
                 (Ast_compatible.const_exp_string ~loc locString))
              (Exp.let_ ~loc Nonrecursive
                 [ Vb.mk ~loc (Pat.var ~loc { loc; txt = "timed" }) e ]
                 (Exp.sequence ~loc
                    (Ast_compatible.app1 ~loc
                       (Exp.ident ~loc
                          {
                            loc;
                            txt = Ldot (Ldot (Lident "Js", "Console"), "timeEnd");
                          })
                       (Ast_compatible.const_exp_string ~loc locString))
                    (Exp.ident ~loc { loc; txt = Lident "timed" })))
            |> Melange_ppxlib_ast.To_ppxlib.copy_expression
        | _ ->
            Location.raise_errorf ~loc
              "expect a boolean expression in the payload"
      in

      let extender = Extension.V3.declare label context extractor handler in
      Context_free.Rule.extension extender
    in
    rule "bs.time"
end

module Node = struct
  let rule =
    let rule label =
      let context = Extension.Context.expression in
      let extractor = Ast_pattern.(__') in
      let handler ~ctxt:_ { txt = payload; loc } =
        let payload = Melange_ppxlib_ast.Of_ppxlib.copy_payload payload in
        let strip s = match s with "_module" -> "module" | x -> x in
        match Ast_payload.as_ident payload with
        | Some
            {
              txt =
                Lident
                  (("__filename" | "__dirname" | "_module" | "require") as name);
              loc;
            } ->
            let open Melange_compiler_libs.Ast_helper in
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
                 else Ast_literal.type_string ~loc ())
            in
            Exp.constraint_ ~loc exp typ
            |> Melange_ppxlib_ast.To_ppxlib.copy_expression
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

      let extender = Extension.V3.declare label context extractor handler in
      Context_free.Rule.extension extender
    in
    rule "bs.node"
end

module Obj = struct
  type label_exprs = (Longident.t Asttypes.loc * Parsetree.expression) list

  let rule =
    let rule label =
      let context = Extension.Context.expression in
      let extractor = Ast_pattern.(__') in
      let handler ~ctxt:_ { txt = payload; loc } =
        match Melange_ppxlib_ast.Of_ppxlib.copy_payload payload with
        | PStr
            [
              {
                pstr_desc =
                  Pstr_eval
                    (({ pexp_desc = Pexp_record (label_exprs, None) } as e), _);
              };
            ] ->
            {
              e with
              pexp_desc =
                Ast_extensions.Make.record_as_js_object e.pexp_loc label_exprs;
            }
            |> Melange_ppxlib_ast.To_ppxlib.copy_expression
        | _ -> Location.raise_errorf ~loc "Expect a record expression here"
      in

      let extender = Extension.V3.declare label context extractor handler in
      Context_free.Rule.extension extender
    in
    rule "bs.obj"
end

module Mapper = struct
  let mapper =
    object (self)
      inherit Ppxlib.Ast_traverse.map as super

      method! expression expr =
        match expr.pexp_desc with
        | Pexp_apply (fn, args) ->
            Ast_exp_apply.app_exp_mapper expr (self, super#expression) fn args
        | _ -> super#expression expr
    end

  (* ~intf:(fun ctxt sig_ -> mapper#signature ctxt sig_) *)
end

let () =
  Driver.add_arg "-unsafe"
    (Unit (fun () -> Ocaml_common.Clflags.unsafe := true))
    ~doc:"Do not compile bounds checking on array and string access";
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
    ~impl:(fun _ctxt str -> Mapper.mapper#structure str)
