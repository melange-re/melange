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

type arity = Single of Lam_arity.t | Submodule of Lam_arity.t array

(* TODO: add a magic number *)
type cmj_value = {
  arity : arity;
  persistent_closed_lambda : (Lam.t * Lam_var_stats.t Ident.Map.t) option;
      (** Either constant or closed functor *)
}

let single_na = Single Lam_arity.na

type keyed_cmj_value = {
  name : string;
  arity : arity;
  persistent_closed_lambda : (Lam.t * Lam_var_stats.t Ident.Map.t) option;
}

type t = {
  values : keyed_cmj_value array;
  effectful_exports : string array;
  pure : bool;
  package_spec : Js_packages_info.t;
  case : Js_packages_info.file_case;
  delayed_program : J.deps_program;
}

let to_sorted_array_with_f_seq ~(f : String.Map.key -> 'a -> 'b)
    (m : 'a String.Map.t) : 'b array =
  let len = String.Map.cardinal m in
  let arr = Array.make len (Obj.magic 0) in
  (* temporary placeholder *)
  let i = ref 0 in
  String.Map.to_seq m
  |> Seq.iter (fun (k, v) ->
      Array.unsafe_set arr !i (f k v);
      incr i);
  arr

let make ~(values : cmj_value String.Map.t) ~effectful_exports ~effect_
    ~package_spec ~case
    ~delayed_program : t =
  {
    values =
      to_sorted_array_with_f_seq values ~f:(fun k (v : cmj_value) ->
          {
            name = k;
            arity = v.arity;
            persistent_closed_lambda = v.persistent_closed_lambda;
          });
    effectful_exports;
    pure = effect_ = None;
    package_spec;
    case;
    delayed_program;
  }

(* Serialization .. *)
let marshal_header_size = 16

let from_file name : t =
  let s = Io.read_file name in
  let _digest = Digest.substring s 0 marshal_header_size in
  Marshal.from_string s marshal_header_size

(* This may cause some build system always rebuild
   maybe should not be turned on by default *)
let to_file =
  let for_sure_not_changed name header =
    match Sys.file_exists name with
    | true ->
        let holder =
          Io.with_file_in_fd name ~f:(fun fd ->
              let buf = Bytes.create marshal_header_size in
              let _len = Unix.read fd buf 0 marshal_header_size in
              Bytes.unsafe_to_string buf)
        in
        String.equal holder header
    | false -> false
  in
  fun name (v : t) ->
    let s = Marshal.to_string v [] in
    let cur_digest = Digest.string s in
    let header = cur_digest in
    if not (for_sure_not_changed name header) then
      Io.write_filev name [ header; s ]

let keyComp (a : string) b = String.compare a b.name

let not_found key =
  { name = key; arity = single_na; persistent_closed_lambda = None }

let get_result midVal =
  match midVal.persistent_closed_lambda with
  | Some
      ( Lconst
          (Const_js_null | Const_js_undefined _ | Const_js_true | Const_js_false),
        _ )
  | None ->
      midVal
  | Some _ ->
      if !Js_config.cross_module_inline then midVal
      else { midVal with persistent_closed_lambda = None }

let rec binarySearchAux arr lo hi (key : string) =
  let mid = (lo + hi) / 2 in
  let midVal = Array.unsafe_get arr mid in
  let c = keyComp key midVal in
  if c = 0 then get_result midVal
  else if c < 0 then
    (*  a[lo] =< key < a[mid] <= a[hi] *)
    if hi = mid then
      let loVal = Array.unsafe_get arr lo in
      if loVal.name = key then get_result loVal else not_found key
    else binarySearchAux arr lo mid key
  else if
    (*  a[lo] =< a[mid] < key <= a[hi] *)
    lo = mid
  then
    let hiVal = Array.unsafe_get arr hi in
    if hiVal.name = key then get_result hiVal else not_found key
  else binarySearchAux arr mid hi key

let binarySearch (sorted : keyed_cmj_value array) (key : string) :
    keyed_cmj_value =
  let len = Array.length sorted in
  if len = 0 then not_found key
  else
    let lo = Array.unsafe_get sorted 0 in
    let c = keyComp key lo in
    if c < 0 then not_found key
    else
      let hi = Array.unsafe_get sorted (len - 1) in
      let c2 = keyComp key hi in
      if c2 > 0 then not_found key else binarySearchAux sorted 0 (len - 1) key

(* FIXME: better error message when ocamldep
   gets self-cycle *)
let query_by_name (cmj_table : t) name : keyed_cmj_value =
  let values = cmj_table.values in
  binarySearch values name

let rec nth_export_name exports index =
  match exports with
  | [] -> None
  | id :: _ when index = 0 -> Some (Ident.name id)
  | _ :: rest -> nth_export_name rest (index - 1)

let export_name_by_index (cmj_table : t) index =
  if index < 0 then None
  else nth_export_name cmj_table.delayed_program.program.exports index

let is_effectful_export (cmj_table : t) name =
  Array.exists cmj_table.effectful_exports ~f:(String.equal name)

type cmj_load_info = {
  cmj_table : t;
      (* TODO(anmonteiro): re-enable for es6-global support *)
      (* package_path : path; *)
      (* Note it is the package path we want
         for ES6_global module spec
         Maybe we can employ package map in the future
      *)
}

let load_unit unit_name : cmj_load_info =
  let file = Artifact_extension.append_extension unit_name Cmj in
  match Initialization.find_in_path_exn file with
  | f -> { cmj_table = from_file f }
  | exception Not_found -> Mel_exception.error (Cmj_not_found unit_name)
