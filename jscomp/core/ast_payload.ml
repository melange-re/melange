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
module Parser_flow = Js_parser.Parser_flow
module Parser_env = Js_parser.Parser_env

type t = Parsetree.payload
type action = string Asttypes.loc * Parsetree.expression option
(* None means punning is hit
    {[ { x } ]}
    otherwise it comes with a payload
    {[ { x = exp }]}
*)

let unrecognizedConfigRecord loc text =
  Location.prerr_warning loc (Warnings.Mel_derive_warning text)

let ident_or_record_as_config loc (x : t) :
    (string Location.loc * Parsetree.expression option) list =
  match x with
  | PStr
      [
        {
          pstr_desc =
            Pstr_eval
              ( {
                  pexp_desc = Pexp_record (label_exprs, with_obj);
                  pexp_loc = loc;
                  _;
                },
                _ );
          _;
        };
      ] -> (
      match with_obj with
      | None ->
          List.map
            ~f:(fun u ->
              match u with
              | ( { Asttypes.txt = Longident.Lident name; loc },
                  {
                    Parsetree.pexp_desc = Pexp_ident { txt = Lident name2; _ };
                    _;
                  } )
                when name2 = name ->
                  ({ Asttypes.txt = name; loc }, None)
              | { txt = Lident name; loc }, y ->
                  ({ Asttypes.txt = name; loc }, Some y)
              | _ -> Location.raise_errorf ~loc "Qualified label is not allowed")
            label_exprs
      | Some _ ->
          unrecognizedConfigRecord loc "`with` is not supported, discarding";
          [])
  | PStr
      [
        {
          pstr_desc =
            Pstr_eval
              ({ pexp_desc = Pexp_ident { loc = lloc; txt = Lident txt }; _ }, _);
          _;
        };
      ] ->
      [ ({ Asttypes.txt; loc = lloc }, None) ]
  | PStr [] -> []
  | _ ->
      unrecognizedConfigRecord loc "invalid attribute config-record, ignoring";
      []

let assert_bool_lit (e : Parsetree.expression) =
  match e.pexp_desc with
  | Pexp_construct ({ txt = Lident "true"; _ }, None) -> true
  | Pexp_construct ({ txt = Lident "false"; _ }, None) -> false
  | _ ->
      Location.raise_errorf ~loc:e.pexp_loc
        "expect `true` or `false` in this field"

let table_dispatch table (action : action) =
  match action with
  | { txt = name; loc }, y -> (
      match String.Map.find_exn table name with
      | fn -> Some (fn y)
      | exception _ ->
          Location.prerr_warning loc (Mel_unused_attribute name);
          None (* Location.raise_errorf ~loc "%s is not supported" name *))
