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

type local_primitive = Raw_expr | Raw_stmt | Debugger

let ghost_expression =
  let mapper =
    object
      inherit Ast_traverse.map
      method! location loc = { loc with loc_ghost = true }
    end
  in
  fun exp -> mapper#expression exp

let local_external_apply =
  let local_module_name = "J" in
  let local_fun_name = "unsafe_expr" in
  let any_to_any ~loc =
    Typ.arrow ~loc Nolabel (Typ.any ~loc ()) (Typ.any ~loc ())
  in
  fun ~loc (primitive : local_primitive) (arg : expression) ->
    let ghost_loc = { loc with loc_ghost = true } in
    let primitive_name, pval_type =
      match primitive with
      | Raw_expr -> ("#raw_expr", any_to_any ~loc:ghost_loc)
      | Raw_stmt -> ("#raw_stmt", any_to_any ~loc:ghost_loc)
      | Debugger ->
          ( "#debugger",
            Typ.arrow ~loc:ghost_loc Nolabel
              (Typ.any ~loc:ghost_loc ())
              (Typ.constr ~loc:ghost_loc
                 { txt = Lident "unit"; loc = ghost_loc }
                 []) )
    in
    Pexp_letmodule
      ( { txt = Some local_module_name; loc = ghost_loc },
        Mod.structure ~loc:ghost_loc
          [
            Str.primitive ~loc:ghost_loc
              (Val.mk ~loc:ghost_loc ~prim:[ primitive_name ]
                 { txt = local_fun_name; loc = ghost_loc }
                 pval_type);
          ],
        Exp.apply ~loc:ghost_loc
          (Exp.ident ~loc:ghost_loc
             {
               txt = Ldot (Lident local_module_name, local_fun_name);
               loc = ghost_loc;
             })
          [ (Asttypes.Nolabel, arg) ] )

(*
{[
  Js.undefinedToOption
    (if Js.typeof x = "undefined" then undefined
    else x  )

]}
*)
let handle_external ~loc x =
  let ghost_loc = { loc with loc_ghost = true } in
  let raw_exp =
    let str_exp =
      Exp.constant ~loc (Pconst_string (x, loc, Some String.empty))
    in
    { str_exp with pexp_desc = local_external_apply ~loc Raw_expr str_exp }
  in
  let empty =
    (* FIXME: the empty delimiter does not make sense*)
    Exp.ident ~loc
      { txt = Ldot (Ldot (Lident "Js", "Undefined"), "empty"); loc }
  in
  let undefined_typeof =
    Exp.ident ~loc:ghost_loc
      { loc = ghost_loc; txt = Ldot (Lident "Js", "undefinedToOption") }
  in
  let typeof =
    Exp.ident ~loc:ghost_loc
      { loc = ghost_loc; txt = Ldot (Lident "Js", "typeof") }
  in
  let exp =
    [%expr
      [%e undefined_typeof]
        (if Stdlib.( = ) ([%e typeof] [%e raw_exp]) "undefined" then [%e empty]
         else [%e raw_exp])]
  in
  { (ghost_expression exp) with pexp_loc = loc }

let handle_debugger ~loc payload =
  match payload with
  | PStr [] -> local_external_apply ~loc Debugger [%expr ()]
  | _ -> Location.raise_errorf ~loc "`%%mel.debugger' doesn't take payload"

let raw_as_string_exp_exn ~(kind : Melange_ffi.Js_raw_info.raw_kind)
    ?is_function (x : payload) =
  match Ast_payload.as_expression x with
  | Some
      ({
         pexp_desc = Pexp_constant (Pconst_string (str, _, delimiter));
         pexp_loc = loc;
         _;
       } as e) ->
      let () =
        let check_errors = Melange_ffi.Flow_ast_utils.Check { delimiter } in
        match kind with
        | Raw_re | Raw_exp ->
            let { Melange_ffi.Flow_ast_utils.prog; error = _ } =
              Melange_ffi.Flow_ast_utils.parse_expression ~loc ~check_errors str
            in
            (match (kind, prog) with
            | Raw_re, RegExpLiteral _ -> ()
            | Raw_re, _ ->
                Location.raise_errorf ~loc
                  "`%%mel.re' expects a valid JavaScript regular expression \
                   literal (`/regex/opt-flags')"
            | _, _ -> ());
            Option.iter
              ~f:(fun is_function ->
                match Melange_ffi.Classify_function.classify_exp prog with
                | Js_function { arity = _; _ } -> is_function := true
                | _ -> ())
              is_function
        | Raw_program ->
            let { Melange_ffi.Flow_ast_utils.prog = _; error = _ } =
              Melange_ffi.Flow_ast_utils.parse_program ~loc ~check_errors str
            in
            ()
      in
      Some
        {
          e with
          pexp_desc = Pexp_constant (Pconst_string (str, Location.none, None));
        }
  | _ -> None

let handle_raw ~kind ~loc payload =
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
        pexp_loc = loc;
        pexp_desc = local_external_apply ~loc Raw_expr exp;
        pexp_attributes =
          (if !is_function then
             Ast_attributes.internal_expansive :: exp.pexp_attributes
           else exp.pexp_attributes);
      }

let handle_raw_structure ~loc payload =
  match raw_as_string_exp_exn ~kind:Raw_program payload with
  | Some exp ->
      Ast_helper.Str.eval ~loc
        { exp with pexp_desc = local_external_apply ~loc Raw_stmt exp }
  | None -> Location.raise_errorf ~loc "mel.raw can only be applied to a string"
