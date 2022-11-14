(* TODO: proper implementation, this only mark the beginning of an AST node
          and has problems if the same node spans multiple lines, but
          it's O(n) in number of AST nodes, so blazing fast *)
(* HACKING
      https://sokra.github.io/source-map-visualization/ *)

module Sourcemap = struct
  include Sourcemap

  let pp_line_col fmt { line; col } = Format.fprintf fmt "%d:%d" line col
end

type t = Sourcemap.t

module Json_writer : Sourcemap.Json_writer_intf with type t = Ext_json_noloc.t =
struct
  type t = Ext_json_noloc.t

  let of_string x = Ext_json_noloc.str x
  let of_obj props = Ext_json_noloc.obj (Map_string.of_list props)
  let of_array arr = Ext_json_noloc.arr (Array.of_list arr)
  let of_number x = Ext_json_noloc.flo x
  let null = Ext_json_noloc.null
end

exception Json_error

module Json_reader : Sourcemap.Json_reader_intf with type t = Ext_json_noloc.t =
struct
  type t = Ext_json_noloc.t

  let to_string t =
    match t with Ext_json_noloc.Str x -> x | _ -> raise Json_error

  let to_obj t =
    match t with
    | Ext_json_noloc.Obj x -> x |> Map_string.to_sorted_array |> Array.to_list
    | _ -> raise Json_error

  let to_array t =
    match t with
    | Ext_json_noloc.Arr x -> Array.to_list x
    | _ -> raise Json_error

  let to_number t =
    match t with Ext_json_noloc.Flo x -> x | _ -> raise Json_error

  let is_null = function Ext_json_noloc.Null -> true | _ -> false
end

module W = Sourcemap.Make_json_writer (Json_writer)
module R = Sourcemap.Make_json_reader (Json_reader)

(* TODO: only works up to 31bits Vlq, hopefully this will never be a problem *)
let add_mapping (t : t) ~(pp : Js_pp.t) loc =
  let start = loc.Location.loc_start in

  let new_generated_line = Js_pp.current_line pp in
  let new_generated_column = Js_pp.current_column pp in
  let new_line = start.pos_lnum in
  let new_column = start.pos_cnum - start.pos_bol in

  let original =
    {
      Sourcemap.source = Option.get (Sourcemap.file t);
      original_loc = { line = new_line; col = new_column };
      name = None;
    }
  in
  let generated =
    { Sourcemap.line = new_generated_line; col = new_generated_column }
  in
  Format.eprintf "add mapping dude orig: %a; gen: %a@." Sourcemap.pp_line_col
    original.original_loc Sourcemap.pp_line_col generated;
  Sourcemap.add_mapping ~original ~generated t

let create ~source_name = Sourcemap.create ~file:source_name ()
let to_string t = Ext_json_noloc.to_string (W.json_of_sourcemap t)
let to_channel t chan = Ext_json_noloc.to_channel chan (W.json_of_sourcemap t)
