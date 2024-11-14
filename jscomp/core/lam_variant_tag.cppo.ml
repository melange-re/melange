(* Copyright (C) 2022- Authors of Melange
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

let namespace_error ~loc txt =
  match txt with
  | "bs.as" | "as" ->
      Location.raise_errorf ~loc
        "`[@bs.*]' and non-namespaced attributes have been removed in favor of \
         `[@mel.*]' attributes. Use `[@mel.as]' instead."
  | _ -> ()


let process_tag_name attrs =
  let st = ref None in
  List.iter attrs
    ~f:(fun { Parsetree.attr_name = { txt; loc }; attr_payload; _ } ->
      match txt with
      | "mel.tag" ->
          if !st = None then (
            (match attr_payload with
            | PStr
                [
                  {
                    pstr_desc =
                      Pstr_eval ({ pexp_desc = Pexp_constant const; _ }, _);
                    _;
                  };
                ] -> (
                namespace_error ~loc txt;
                match
#if OCAML_VERSION >= (5, 3, 0)
                  const.pconst_desc
#else
                  const
#endif
                with
                | Pconst_string (s, _, _) -> st := Some s
                | _ -> ())
            | _ -> ());
            if !st = None
            then
              Location.raise_errorf
                ~loc
                 "Variant tag annotation (`[@mel.tag \"..\"]') must be a string")
          else
            Location.raise_errorf
              ~loc
               "Duplicate `[@mel.tag \"..\"]' annotation"
      | _ -> ());
  !st

