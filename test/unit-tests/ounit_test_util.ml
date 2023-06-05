(* Copyright (C) 2019-Present Hongbo Zhang, Authors of ReScript
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

let min_int x y = if x < y then x else y

let random_string chars upper =
  let len = Array.length chars in
  let string_len = Random.int (min_int upper len) in
  String.init string_len (fun _i -> chars.(Random.int len))

let stats_to_string
    ({ num_bindings; num_buckets; max_bucket_length; bucket_histogram } :
      Hashtbl.statistics) =
  Printf.sprintf "bindings: %d,buckets: %d, longest: %d, hist:[%s]" num_bindings
    num_buckets max_bucket_length
    (String.concat ","
       (Array.to_list (Array.map string_of_int bucket_histogram)))

let rec dump r =
  if Obj.is_int r then string_of_int (Obj.magic r : int)
  else
    (* Block. *)
    let rec get_fields acc = function
      | 0 -> acc
      | n ->
          let n = n - 1 in
          get_fields (Obj.field r n :: acc) n
    in
    let rec is_list r =
      if Obj.is_int r then r = Obj.repr 0 (* [] *)
      else
        let s = Obj.size r and t = Obj.tag r in
        t = 0 && s = 2 && is_list (Obj.field r 1)
      (* h :: t *)
    in
    let rec get_list r =
      if Obj.is_int r then []
      else
        let h = Obj.field r 0 and t = get_list (Obj.field r 1) in
        h :: t
    in
    let opaque name =
      (* XXX In future, print the address of value 'r'.  Not possible
       * in pure OCaml at the moment. *)
      "<" ^ name ^ ">"
    in
    let s = Obj.size r and t = Obj.tag r in
    (* From the tag, determine the type of block. *)
    match t with
    | _ when is_list r ->
        let fields = get_list r in
        "[" ^ String.concat "; " (List.map dump fields) ^ "]"
    | 0 ->
        let fields = get_fields [] s in
        "(" ^ String.concat ", " (List.map dump fields) ^ ")"
    | x when x = Obj.lazy_tag ->
        (* Note that [lazy_tag .. forward_tag] are < no_scan_tag.  Not
           * clear if very large constructed values could have the same
           * tag. XXX *)
        opaque "lazy"
    | x when x = Obj.closure_tag -> opaque "closure"
    | x when x = Obj.object_tag ->
        let fields = get_fields [] s in
        let _clasz, id, slots =
          match fields with h :: h' :: t -> (h, h', t) | _ -> assert false
        in
        (* No information on decoding the class (first field).  So just print
           * out the ID and the slots. *)
        "Object #" ^ dump id ^ " ("
        ^ String.concat ", " (List.map dump slots)
        ^ ")"
    | x when x = Obj.infix_tag -> opaque "infix"
    | x when x = Obj.forward_tag -> opaque "forward"
    | x when x < Obj.no_scan_tag ->
        let fields = get_fields [] s in
        "Tag" ^ string_of_int t ^ " ("
        ^ String.concat ", " (List.map dump fields)
        ^ ")"
    | x when x = Obj.string_tag ->
        "\"" ^ String.escaped (Obj.magic r : string) ^ "\""
    | x when x = Obj.double_tag -> string_of_float (Obj.magic r : float)
    | x when x = Obj.abstract_tag -> opaque "abstract"
    | x when x = Obj.custom_tag -> opaque "custom"
    | x when x = Obj.custom_tag -> opaque "final"
    | x when x = Obj.double_array_tag ->
        "[|"
        ^ String.concat ";"
            (Array.to_list
               (Array.map string_of_float (Obj.magic r : float array)))
        ^ "|]"
    | _ -> opaque (Printf.sprintf "unknown: tag %d size %d" t s)

let dump v = dump (Obj.repr v)
let pp_any fmt v = Format.fprintf fmt "@[%s@]" (dump v)
