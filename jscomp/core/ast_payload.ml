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

(* None means punning is hit
    {[ { x } ]}
    otherwise it comes with a payload
    {[ { x = exp }]} *)

let ident_or_record_as_config =
  let exception Local of Location.t in
  let error ?(loc = Location.none) more =
    let msg =
      let base =
        "Unsupported attribute payload. Expected a configuration record literal"
      in
      match more with "" -> base | s -> Format.sprintf "%s %s" base s
    in
    Location.raise_errorf ~loc "%s" msg
  in
  fun ~loc payload ->
    match payload with
    | Parsetree.PStr
        [
          {
            pstr_desc =
              Pstr_eval
                ({ pexp_desc = Pexp_record (label_exprs, with_obj); _ }, _);
            _;
          };
        ] -> (
        match with_obj with
        | None -> (
            try
              List.map
                ~f:(function
                  | ( { Location.txt = Longident.Lident name; loc },
                      {
                        Parsetree.pexp_desc =
                          Pexp_ident { txt = Lident name2; _ };
                        _;
                      } )
                    when name2 = name ->
                      ({ Asttypes.txt = name; loc }, None)
                  | { txt = Lident name; loc }, y ->
                      ({ Asttypes.txt = name; loc }, Some y)
                  | { loc; _ }, _ -> raise (Local loc))
                label_exprs
            with Local loc -> error ~loc "(qualified labels aren't supported)")
        | Some { pexp_loc; _ } ->
            error ~loc:pexp_loc "(`with' is not supported)")
    | PStr
        [
          {
            pstr_desc =
              Pstr_eval
                ( { pexp_desc = Pexp_ident { loc = lloc; txt = Lident txt }; _ },
                  _ );
            _;
          };
        ] ->
        [ ({ Asttypes.txt; loc = lloc }, None) ]
    | PStr [] -> []
    | _ -> error ~loc ""

let assert_bool_lit (e : Parsetree.expression) =
  match e.pexp_desc with
  | Pexp_construct ({ txt = Lident "true"; _ }, None) -> true
  | Pexp_construct ({ txt = Lident "false"; _ }, None) -> false
  | _ ->
      Location.raise_errorf ~loc:e.pexp_loc
        "Expected a boolean literal (`true' or `false')"

let table_dispatch table
    (action : string Asttypes.loc * Parsetree.expression option) =
  match action with
  | { txt = name; loc }, y -> (
      match String.Map.find_exn table name with
      | fn -> Some (fn y)
      | exception Not_found ->
          Location.prerr_warning loc (Mel_unused_attribute name);
          None)
