(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
 * Copyright (C) 2017- Hongbo Zhang, Authors of ReScript
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

open Ppxlib

module Warns = struct
  type t =
    | Bs_unused_attribute of string (* 101 *)
    | Bs_polymorphic_comparison (* 102 *)
    | Bs_ffi_warning of string (* 103 *)
    | Bs_derive_warning of string (* 104 *)
    | Bs_fragile_external of string (* 105 *)
    | Bs_unimplemented_primitive of string (* 106 *)
    | Bs_integer_literal_overflow (* 107 *)
    | Bs_uninterpreted_delimiters of string (* 108 *)
    | Bs_toplevel_expression_unit (* 109 *)
  [@@warning "-37"]

  let message = function
    | Bs_unused_attribute s ->
        "Unused attribute: " ^ s
        ^ "\n\
           This means such annotation is not annotated properly.\n\
           for example, some annotations is only meaningful in externals\n"
    | Bs_polymorphic_comparison ->
        "Polymorphic comparison introduced (maybe unsafe)"
    | Bs_ffi_warning s -> "FFI warning: " ^ s
    | Bs_derive_warning s -> "bs.deriving warning: " ^ s
    | Bs_fragile_external s ->
        s
        ^ " : the external name is inferred from val name is unsafe from \
           refactoring when changing value name"
    | Bs_unimplemented_primitive s -> "Unimplemented primitive used:" ^ s
    | Bs_integer_literal_overflow ->
        "Integer literal exceeds the range of representable integers of type \
         int"
    | Bs_uninterpreted_delimiters s -> "Uninterpreted delimiters " ^ s
    | Bs_toplevel_expression_unit ->
        "Toplevel expression is expected to have unit type."

  let str ~loc w =
    [%stri
      [%%ocaml.error
      [%e Ast_helper.Exp.constant (Pconst_string (message w, loc, None))]]]

  let expr ~f ~loc w =
    [%expr
      [%ocaml.error
        [%e Ast_helper.Exp.constant (Pconst_string (f w, loc, None))]]]

  let pat ~f ~loc w =
    [%pat?
      [%ocaml.error
        [%e Ast_helper.Exp.constant (Pconst_string (f w, loc, None))]]]
end

(** Warning unused bs attributes
    Note if we warn `deriving` too,
    it may fail third party ppxes
*)
let is_bs_attribute txt =
  let len = String.length txt in
  len >= 2
  (*TODO: check the stringing padding rule, this preciate may not be needed *)
  && String.unsafe_get txt 0 = 'b'
  && String.unsafe_get txt 1 = 's'
  && (len = 2 || String.unsafe_get txt 2 = '.')

let used_attributes : string Asttypes.loc Hash_set_poly.t =
  Hash_set_poly.create 16

(* #if true *)
(* let dump_attribute fmt = (fun (sloc : string Asttypes.loc) -> *)
(* Format.fprintf fmt "@[%s @]" sloc.txt (* (Printast.payload 0 ) payload *) *)
(* ) *)

(* let dump_used_attributes fmt = *)
(* Format.fprintf fmt "Used attributes Listing Start:@."; *)
(* Hash_set_poly.iter  used_attributes (fun attr -> dump_attribute fmt attr) ; *)
(* Format.fprintf fmt "Used attributes Listing End:@." *)
(* #endif *)

(* only mark non-ghost used bs attribute *)
let mark_used_bs_attribute ({ attr_name = x; _ } : Parsetree.attribute) =
  if not x.loc.loc_ghost then Hash_set_poly.add used_attributes x

let warn_unused_attribute
    ({ attr_name = { txt; loc } as sloc } as attr : Parsetree.attribute) =
  if
    is_bs_attribute txt && (not loc.loc_ghost)
    && not (Hash_set_poly.mem used_attributes sloc)
  then
    (* #if true *)
    (* (*COMMENT*) *)
    (* dump_used_attributes Format.err_formatter; *)
    (* dump_attribute Format.err_formatter sloc; *)
    (* #endif *)
    {
      attr with
      attr_payload = PStr [ Warns.str ~loc (Bs_unused_attribute txt) ];
    }
  else attr

let warn_discarded_unused_attributes (attrs : Parsetree.attributes) =
  List.map warn_unused_attribute attrs

let check_constant_pat pat (const : Parsetree.constant) : Parsetree.pattern =
  let loc = pat.ppat_loc in
  match const with
  | Pconst_string (_, _, Some s) ->
      if s = "j" then
        Warns.pat ~loc ~f:Fun.id
          "Unicode string is not allowed in pattern match"
      else pat
  | Pconst_integer (s, None) -> (
      (* range check using int32
         It is better to give a warning instead of error to avoid make people unhappy.
         It also has restrictions in which platform bsc is running on since it will
         affect int ranges
      *)
      try
        ignore (Int32.of_string s);
        pat
      with _ -> Warns.pat ~f:Warns.message ~loc Bs_integer_literal_overflow)
  | Pconst_integer (_, Some 'n') ->
      Warns.pat ~loc ~f:Fun.id "literal with `n` suffix is not supported"
  | _ -> pat

let check_constant_expr expr (const : Parsetree.constant) : Parsetree.expression
    =
  let loc = expr.pexp_loc in
  match const with
  | Pconst_string (_, _, Some s) ->
      if Ast_utf8_string_interp.is_unescaped s then
        Warns.expr ~loc ~f:Warns.message (Bs_uninterpreted_delimiters s)
      else expr
  | Pconst_integer (s, None) -> (
      (* range check using int32
         It is better to give a warning instead of error to avoid make people unhappy.
         It also has restrictions in which platform bsc is running on since it will
         affect int ranges
      *)
      try
        ignore (Int32.of_string s);
        expr
      with _ -> Warns.expr ~f:Warns.message ~loc Bs_integer_literal_overflow)
  | Pconst_integer (_, Some 'n') ->
      Warns.expr ~loc ~f:Fun.id "literal with `n` suffix is not supported"
  | _ -> expr

(* Note we only used Bs_ast_iterator here, we can reuse compiler-libs instead
   of rolling our own *)
let emit_external_warnings : Ast_traverse.map =
  object (_self)
    inherit Ast_traverse.map as super
    method! attribute attr = warn_unused_attribute attr

    method! expression a =
      match a.pexp_desc with
      | Pexp_constant const -> check_constant_expr a const
      | _ -> super#expression a

    method! label_declaration lbl =
      Ext_list.iter lbl.pld_attributes (fun attr ->
          match attr with
          | { attr_name = { txt = "bs.as" | "as" }; _ } ->
              mark_used_bs_attribute attr
          | _ -> ());
      super#label_declaration lbl

    method! value_description v =
      match v with
      | ({ pval_loc; pval_prim = "%identity" :: _; pval_type } :
          Parsetree.value_description)
        when not (Ast_core_type.is_arity_one pval_type) ->
          Location.raise_errorf ~loc:pval_loc
            "%%identity expect its type to be of form 'a -> 'b (arity 1)"
      | _ -> super#value_description v

    method! pattern pat =
      match pat.ppat_desc with
      | Ppat_constant constant -> check_constant_pat pat constant
      | Ppat_record ([], _) ->
          Location.raise_errorf ~loc:pat.ppat_loc
            "Empty record pattern is not supported"
      | _ -> super#pattern pat
  end

let emit_external_warnings_on_structure (stru : Parsetree.structure) =
  emit_external_warnings#structure stru

let emit_external_warnings_on_signature (sigi : Parsetree.signature) =
  emit_external_warnings#signature sigi
