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
    let txt = "match" in
    let txt_expr = Exp.ident ~loc { txt = Lident txt; loc } in
    let none = Exp.construct ~loc { txt = Ast_literal.predef_none; loc } None in
    check_cases cases;
    Exp.fun_ ~attrs ~loc Nolabel None
      (Pat.var ~loc { txt; loc })
      (Exp.ifthenelse ~loc
         [%expr
           [%e Exp.ident ~loc { txt = isCamlExceptionOrOpenVariant; loc }]
             [%e txt_expr]]
         (Exp.match_ ~loc
            (Exp.constraint_ ~loc
               [%expr
                 [%e Exp.ident ~loc { txt = obj_magic; loc }] [%e txt_expr]]
               [%type: exn])
            (List.map
               ~f:(fun ({ pc_rhs; _ } as x) ->
                 let loc = pc_rhs.pexp_loc in
                 {
                   x with
                   pc_rhs =
                     Exp.construct ~loc
                       { txt = Ast_literal.predef_some; loc }
                       (Some pc_rhs);
                 })
               (self#cases cases)
            @ [ Exp.case (Pat.any ~loc ()) none ]))
         (Some none))
