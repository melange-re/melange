(* Copyright (C) 2020 Hongbo Zhang, Authors of ReScript
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

(*
{[
  Js.undefinedToOption
    (if Js.typeof x = "undefined" then undefined
    else x  )

]}
*)
let handle_external loc (x : string) =
  let raw_exp =
    let str_exp =
      Exp.constant ~loc (Pconst_string (x, loc, Some String.empty))
    in
    {
      str_exp with
      pexp_desc =
        Ast_external_mk.local_external_apply loc ~pval_prim:[ "#raw_expr" ]
          ~pval_type:(Typ.arrow Nolabel (Typ.any ()) (Typ.any ()))
          [ str_exp ];
    }
  in
  let empty =
    (* FIXME: the empty delimiter does not make sense*)
    Exp.ident ~loc
      { txt = Ldot (Ldot (Lident "Js", "Undefined"), "empty"); loc }
  in
  let undefined_typeof =
    Exp.ident { loc; txt = Ldot (Lident "Js", "undefinedToOption") }
  in
  let typeof = Exp.ident { loc; txt = Ldot (Lident "Js", "typeof") } in

  [%expr
    [%e undefined_typeof]
      (if Stdlib.( = ) ([%e typeof] [%e raw_exp]) "undefined" then [%e empty]
       else [%e raw_exp])]

let handle_debugger loc payload =
  match payload with
  | PStr [] ->
      Ast_external_mk.local_external_apply loc ~pval_prim:[ "#debugger" ]
        ~pval_type:(Typ.arrow Nolabel (Typ.any ()) [%type: unit])
        [ [%expr ()] ]
  | _ -> Location.raise_errorf ~loc "`%%mel.debugger' doesn't take payload"

let raw_as_string_exp_exn ~(kind : Melange_ffi.Js_raw_info.raw_kind)
    ?is_function (x : payload) =
  match x with
  (* TODO also need detect empty phrase case *)
  | PStr
      [
        {
          pstr_desc =
            Pstr_eval
              ( ({
                   pexp_desc = Pexp_constant (Pconst_string (str, _, deli));
                   pexp_loc = loc;
                   _;
                 } as e),
                _ );
          _;
        };
      ] ->
      Melange_ffi.Flow_ast_utils.check_flow_errors ~loc
        ~offset:(Melange_ffi.Flow_ast_utils.flow_deli_offset deli)
        (match kind with
        | Raw_re | Raw_exp ->
            let ((_loc, e) as prog), errors =
              Js_parser.Parser_flow.parse_expression
                (Js_parser.Parser_env.init_env None str)
                false
            in
            (if kind = Raw_re then
               match e with
               | Literal { value = RegExp _; _ } -> ()
               | _ ->
                   Location.raise_errorf ~loc
                     "`%%mel.re' expects a valid JavaScript regular expression \
                      literal (`/regex/opt-flags')");
            (match is_function with
            | Some is_function -> (
                match Melange_ffi.Classify_function.classify_exp prog with
                | Js_function { arity = _; _ } -> is_function := true
                | _ -> ())
            | None -> ());
            errors
        | Raw_program ->
            snd (Js_parser.Parser_flow.parse_program false None str));
      Some
        {
          e with
          pexp_desc = Pexp_constant (Pconst_string (str, Location.none, None));
        }
  | _ -> None

let handle_raw ~kind loc payload =
  let is_function = ref false in
  match raw_as_string_exp_exn ~kind ~is_function payload with
  | None ->
      let ext =
        match kind with
        | Raw_re -> "mel.re"
        | Raw_program | Raw_exp -> "mel.raw"
      in
      Location.raise_errorf ~loc "`%%%s' can only be applied to a string" ext
  | Some exp ->
      {
        exp with
        pexp_desc =
          Ast_external_mk.local_external_apply loc ~pval_prim:[ "#raw_expr" ]
            ~pval_type:(Typ.arrow Nolabel (Typ.any ()) (Typ.any ()))
            [ exp ];
        pexp_attributes =
          (if !is_function then
             Ast_attributes.internal_expansive :: exp.pexp_attributes
           else exp.pexp_attributes);
      }

let handle_raw_structure loc payload =
  match raw_as_string_exp_exn ~kind:Raw_program payload with
  | Some exp ->
      Ast_helper.Str.eval
        {
          exp with
          pexp_desc =
            Ast_external_mk.local_external_apply loc ~pval_prim:[ "#raw_stmt" ]
              ~pval_type:(Typ.arrow Nolabel (Typ.any ()) (Typ.any ()))
              [ exp ];
        }
  | None -> Location.raise_errorf ~loc "mel.raw can only be applied to a string"

(* module Make = Ast_external_mk *)
