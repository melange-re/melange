(* Copyright (C) 2017 Hongbo Zhang, Authors of ReScript
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
module External_arg_spec = Melange_ffi.External_arg_spec

let is_enum_polyvar =
  let is_enum row_fields =
    List.for_all row_fields ~f:(function
      | { prf_desc = Rtag (_, true, []); _ } -> true
      | { prf_desc = Rtag _ | Rinherit _; _ } -> false)
  in
  function
  | {
      ptype_manifest =
        Some { ptyp_desc = Ptyp_variant (row_fields, Closed, None); _ };
      _;
    }
    when is_enum row_fields ->
      Some row_fields
  | { ptype_manifest = Some _ | None; _ } -> None

let map_row_fields_into_ints =
  let process_mel_as ~attrs i =
    Option.value (Ast_attributes.iter_process_mel_int_as attrs) ~default:i
  in
  fun (row_fields : row_field list) ~loc ->
    let case, _, result =
      List.fold_left row_fields ~init:(`Nothing, 0, [])
        ~f:(fun (nullary, i, acc) { prf_desc; prf_attributes; _ } ->
          let nullary, txt =
            match (nullary, prf_desc) with
            | (`Nothing | `Null), Rtag ({ txt; _ }, true, []) -> (`Null, txt)
            | (`Nothing | `NonNull), Rtag ({ txt; _ }, false, [ _ ]) ->
                (`NonNull, txt)
            | _ -> Error.err ~loc Invalid_mel_int_type
          in
          let i = process_mel_as ~attrs:prf_attributes i in
          (nullary, i + 1, (txt, External_arg_spec.Arg_cst.Int i) :: acc))
    in
    match case with
    | `Nothing -> assert false
    | `Null -> External_arg_spec.Int { descr = result; spread = false }
    | `NonNull -> Int { descr = result; spread = true }

(* It also check in-consistency of cases like
   {[ [`a  | `c of int ] ]} *)
let map_row_fields_into_strings =
  let process_mel_as tag ~txt ~has_mel_as =
    let name =
      match Ast_attributes.iter_process_mel_string_as tag.prf_attributes with
      | Some name ->
          has_mel_as := true;
          name
      | None -> txt
    in
    (txt, External_arg_spec.Arg_cst.Str name)
  in
  fun (row_fields : row_field list) ~loc ->
    let has_mel_as = ref false in
    let case, result =
      List.fold_right
        ~f:(fun tag (nullary, acc) ->
          let nullary, txt =
            match (nullary, tag.prf_desc) with
            | (`Nothing | `Null), Rtag ({ txt; _ }, true, []) -> (`Null, txt)
            | (`Nothing | `NonNull), Rtag ({ txt; _ }, false, [ _ ]) ->
                (`NonNull, txt)
            | _ -> Error.err ~loc Invalid_mel_string_type
          in
          (nullary, process_mel_as tag ~txt ~has_mel_as :: acc))
        row_fields ~init:(`Nothing, [])
    in
    match (case, !has_mel_as) with
    | `Nothing, _ -> Error.err ~loc Invalid_mel_string_type
    | `Null, false ->
        Mel_ast_invariant.warn ~loc Redundant_mel_string;
        External_arg_spec.Nothing
    | `Null, true -> Poly_var { descr = result; spread = false }
    | `NonNull, has_mel_as ->
        Poly_var { descr = (if has_mel_as then result else []); spread = true }

let map_row_fields_into_spread (row_fields : row_field list) ~loc =
  let result =
    List.map row_fields ~f:(function
      | { prf_desc = Rtag ({ txt; _ }, false, [ _ ]); prf_attributes; _ } ->
          ( txt,
            match Ast_attributes.iter_process_mel_as_cst prf_attributes with
            | Some x -> x
            | None -> Str txt )
      | _ -> Error.err ~loc Invalid_mel_spread_type)
  in
  External_arg_spec.Poly_var { descr = result; spread = true }

let infer_mel_as ~loc row_fields =
  let has_mel_as = ref false in
  let result =
    List.filter_map row_fields ~f:(function
      | { prf_desc = Rtag ({ txt; _ }, _, _); prf_attributes; _ } -> (
          match Ast_attributes.iter_process_mel_as_cst prf_attributes with
          | Some x ->
              has_mel_as := true;
              Some (txt, x)
          | None -> None)
      | _ -> Error.err ~loc Invalid_mel_spread_type)
  in
  match !has_mel_as with
  | true -> External_arg_spec.Poly_var { descr = result; spread = false }
  | false -> Nothing
