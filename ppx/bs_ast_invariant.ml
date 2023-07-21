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

module Warnings = struct
  type t =
    | Unused_attribute of string
    | Fragile_external of string
    | Redundant_bs_string
    | Deprecated_attribute_namespace

  let kind = function
    | Unused_attribute _ -> "unused"
    | Fragile_external _ -> "fragile"
    | Redundant_bs_string -> "redundant"
    | Deprecated_attribute_namespace -> "deprecated"

  let pp fmt t =
    match t with
    | Unused_attribute s ->
        Format.fprintf fmt
          "Unused attribute [%@%s]@\n\
           This means such annotation is not annotated properly.@\n\
           For example, some annotations are only meaningful in externals\n"
          s
    | Fragile_external s ->
        Format.fprintf fmt
          "%s : the external name is inferred from val name is unsafe from \
           refactoring when changing value name"
          s
    | Redundant_bs_string ->
        Format.fprintf fmt
          "[@bs.string] is redundant here, you can safely remove it"
    | Deprecated_attribute_namespace ->
        Format.fprintf fmt
          "The `bs.*' attribute namespace is deprecated and will be removed in \
           the next release.@\n\
           Use `mel.*' instead."
end

let warn ~loc msg =
  let module Location = Ocaml_common.Location in
  Location.prerr_alert loc
    {
      Ocaml_common.Warnings.kind = Warnings.kind msg;
      message = Format.asprintf "%a" Warnings.pp msg;
      def = Location.none;
      use = loc;
    }

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
    ({ attr_name = { txt; loc } as sloc; _ } : Parsetree.attribute) : unit =
  if
    is_bs_attribute txt && (not loc.loc_ghost)
    && not (Hash_set_poly.mem used_attributes sloc)
  then
    (* #if true *)
    (* (*COMMENT*) *)
    (* dump_used_attributes Format.err_formatter; *)
    (* dump_attribute Format.err_formatter sloc; *)
    (* #endif *)
    warn ~loc (Unused_attribute txt)

let warn_discarded_unused_attributes (attrs : Parsetree.attributes) =
  if attrs <> [] then List.iter warn_unused_attribute attrs

(* Note we only used Bs_ast_iterator here, we can reuse compiler-libs instead
   of rolling our own *)
let emit_external_warnings : Ast_traverse.iter =
  object (_self)
    inherit Ast_traverse.iter as super
    method! attribute attr = warn_unused_attribute attr

    method! label_declaration lbl =
      List.iter
        (fun attr ->
          match attr with
          | { attr_name = { txt = "bs.as" | "as"; _ }; _ } ->
              mark_used_bs_attribute attr
          | _ -> ())
        lbl.pld_attributes;
      super#label_declaration lbl
  end

let emit_external_warnings_on_structure (stru : Parsetree.structure) =
  emit_external_warnings#structure stru

let emit_external_warnings_on_signature (sigi : Parsetree.signature) =
  emit_external_warnings#signature sigi
