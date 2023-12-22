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

let is_single_string (x : payload) =
  match x with
  (* TODO also need detect empty phrase case *)
  | PStr
      [
        {
          pstr_desc =
            Pstr_eval
              ( { pexp_desc = Pexp_constant (Pconst_string (name, _, dec)); _ },
                _ );
          _;
        };
      ] ->
      Some (name, dec)
  | _ -> None

(* TODO also need detect empty phrase case *)
let is_single_int (x : payload) : int option =
  match x with
  | PStr
      [
        {
          pstr_desc =
            Pstr_eval
              ({ pexp_desc = Pexp_constant (Pconst_integer (name, _)); _ }, _);
          _;
        };
      ] ->
      Some (int_of_string name)
  | _ -> None

let as_ident (x : payload) =
  match x with
  | PStr
      [ { pstr_desc = Pstr_eval ({ pexp_desc = Pexp_ident ident; _ }, _); _ } ]
    ->
      Some ident
  | _ -> None

type action = string Asttypes.loc * expression option

(* None means punning is hit
    {[ { x } ]}
    otherwise it comes with a payload
    {[ { x = exp }]}
*)

let ident_or_record_as_config =
  let error more =
    let msg =
      let base =
        "Unsupported attribute payload. Expected a configuration record literal"
      in
      match more with "" -> base | s -> Format.sprintf "%s %s" base s
    in
    Error msg
  in
  fun (x : payload) :
      ((string Location.loc * expression option) list, string) result ->
    match x with
    | PStr
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
            let exception Local in
            try
              Ok
                (List.map
                   ~f:(fun u ->
                     match u with
                     | ( { txt = Lident name; loc },
                         { pexp_desc = Pexp_ident { txt = Lident name2; _ }; _ }
                       )
                       when name2 = name ->
                         ({ Asttypes.txt = name; loc }, None)
                     | { txt = Lident name; loc }, y ->
                         ({ Asttypes.txt = name; loc }, Some y)
                     | _ -> raise Local)
                   label_exprs)
            with Local -> error "(qualified labels aren't supported)")
        | Some _ -> error "(`with' not supported)")
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
        Ok [ ({ Asttypes.txt; loc = lloc }, None) ]
    | PStr [] -> Ok []
    | _ -> error ""

let assert_strings loc (x : payload) : string list =
  let exception Not_str of Location.t in
  match x with
  | PStr
      [ { pstr_desc = Pstr_eval ({ pexp_desc = Pexp_tuple strs; _ }, _); _ } ]
    -> (
      try
        List.map
          ~f:(fun e ->
            match (e : expression) with
            | { pexp_desc = Pexp_constant (Pconst_string (name, _, _)); _ } ->
                name
            | { pexp_loc; _ } -> raise (Not_str pexp_loc))
          strs
      with Not_str loc ->
        Location.raise_errorf ~loc "Expected a tuple of string literals")
  | PStr
      [
        {
          pstr_desc =
            Pstr_eval
              ({ pexp_desc = Pexp_constant (Pconst_string (name, _, _)); _ }, _);
          _;
        };
      ] ->
      [ name ]
  | PStr [] -> []
  | PSig _ | PStr _ | PTyp _ | PPat _ ->
      Location.raise_errorf ~loc "Expected a string or tuple of strings"

let extract_mel_as_ident ~loc x =
  match x with
  | PStr [ { pstr_desc = Pstr_eval ({ pexp_desc; _ }, _); _ } ] -> (
      match pexp_desc with
      | Pexp_constant (Pconst_string (name, _, _))
      | Pexp_construct ({ txt = Lident name; _ }, _)
      | Pexp_ident { txt = Lident name; _ } ->
          name
      | _ ->
          Location.raise_errorf ~loc
            "Invalid `%@mel.as' payload. Expected string or simple ident.")
  | _ -> Location.raise_errorf ~loc "Invalid attribute payload."
