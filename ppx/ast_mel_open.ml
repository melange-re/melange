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

open Import

let ghost_loc loc = { loc with Location.loc_ghost = true }

let convert_mel_error_function =
  let isCamlExceptionOrOpenVariant : Longident.t =
    Ldot (Ldot (Lident "Js", "Exn"), "isCamlExceptionOrOpenVariant")
  in
  let obj_magic : Longident.t = Ldot (Lident "Obj", "magic") in
  let check_cases =
    let rec check_pat pat =
      match pat.ppat_desc with
      | Ppat_construct _ -> ()
      | Ppat_or (l, r) ->
          check_pat l;
          check_pat r
      | _ ->
          Location.raise_errorf ~loc:pat.ppat_loc
            "Unsupported pattern. `[@mel.open]' requires patterns to be \
             (exception) constructors"
    in
    fun cases -> List.iter cases ~f:(fun { pc_lhs; _ } -> check_pat pc_lhs)
  in
  fun ~loc (self : Ast_traverse.map) attrs (cases : case list) ->
    let open Ast_helper in
    let generated_loc = ghost_loc loc in
    let txt = "match" in
    let txt_expr =
      Exp.ident ~loc:generated_loc { txt = Lident txt; loc = generated_loc }
    in
    let none =
      Exp.construct ~loc:generated_loc
        { txt = Ast_literal.predef_none; loc = generated_loc }
        None
    in
    check_cases cases;
    Exp.fun_ ~attrs ~loc Nolabel None
      (Pat.var ~loc:generated_loc { txt; loc = generated_loc })
      (Exp.ifthenelse ~loc:generated_loc
         (Exp.apply ~loc:generated_loc
            (Exp.ident ~loc:generated_loc
               { txt = isCamlExceptionOrOpenVariant; loc = generated_loc })
            [ (Nolabel, txt_expr) ])
         (Exp.match_ ~loc:generated_loc
            (Exp.constraint_ ~loc:generated_loc
               (Exp.apply ~loc:generated_loc
                  (Exp.ident ~loc:generated_loc
                     { txt = obj_magic; loc = generated_loc })
                  [ (Nolabel, txt_expr) ])
               (Typ.constr ~loc:generated_loc
                  { txt = Lident "exn"; loc = generated_loc }
                  []))
            (List.map
               ~f:(fun ({ pc_rhs; _ } as x) ->
                 let loc = ghost_loc pc_rhs.pexp_loc in
                 {
                   x with
                   pc_rhs =
                     Exp.construct ~loc
                       { txt = Ast_literal.predef_some; loc }
                       (Some pc_rhs);
                 })
               (self#cases cases)
            @ [ Exp.case (Pat.any ~loc:generated_loc ()) none ]))
         (Some none))
