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

open Import

module Warnings = struct
  type t =
    | Unused_attribute of string
    | Fragile_external of string
    | Redundant_mel_string

  let kind = function
    | Unused_attribute _ -> "unused"
    | Fragile_external _ -> "fragile"
    | Redundant_mel_string -> "redundant"

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
    | Redundant_mel_string ->
        Format.fprintf fmt
          "[@mel.string] is redundant here, you can safely remove it"
end

let warn =
  let module Location = Ocaml_common.Location in
  fun ~loc t ->
    Location.prerr_alert loc
      {
        Ocaml_common.Warnings.kind = Warnings.kind t;
        message = Format.asprintf "%a" Warnings.pp t;
        def = Location.none;
        use = loc;
      }

let is_mel_attribute txt =
  let len = String.length txt in
  (len = 1 && String.unsafe_get txt 0 = 'u')
  || len >= 5
     && String.unsafe_get txt 0 = 'm'
     && String.unsafe_get txt 1 = 'e'
     && String.unsafe_get txt 2 = 'l'
     && String.unsafe_get txt 3 = '.'

let used_attributes : string Asttypes.loc Polyvariant.Hash_set.t =
  Polyvariant.Hash_set.create 16

(* only mark non-ghost used mel attribute *)
let mark_used_mel_attribute ({ attr_name = x; _ } : attribute) =
  if not x.loc.loc_ghost then Polyvariant.Hash_set.add used_attributes x

let warn_unused_attribute ({ attr_name = { txt; loc } as sloc; _ } : attribute)
    : unit =
  if
    is_mel_attribute txt && (not loc.loc_ghost)
    && not (Polyvariant.Hash_set.mem used_attributes sloc)
  then warn ~loc (Unused_attribute txt)

let warn_discarded_unused_attributes (attrs : attributes) =
  if attrs <> [] then List.iter ~f:warn_unused_attribute attrs

let emit_external_warnings : Ast_traverse.iter =
  object (_self)
    inherit Ast_traverse.iter as super
    method! attribute attr = warn_unused_attribute attr

    method! label_declaration lbl =
      List.iter
        ~f:(fun attr ->
          match attr with
          | { attr_name = { txt = "mel.as"; _ }; _ } ->
              mark_used_mel_attribute attr
          | _ -> ())
        lbl.pld_attributes;
      super#label_declaration lbl
  end

let emit_external_warnings_on_structure stru =
  emit_external_warnings#structure stru

let emit_external_warnings_on_signature sigi =
  emit_external_warnings#signature sigi
