(* TODO: proper implementation, this only mark the beginning of an AST node
          and has problems if the same node spans multiple lines, but
          it's O(n) in number of AST nodes, so blazing fast *)
(* HACKING
      https://sokra.github.io/source-map-visualization/ *)

module Sourcemap = struct
  include Sourcemap

  let pp_line_col fmt { line; col } = Format.fprintf fmt "%d:%d" line col
end

module Pos = struct
  type t = Lexing.position

  let line_col (t : t) =
    let line = t.pos_lnum and col = t.pos_cnum - t.pos_bol in
    { Sourcemap.line; col }

  let pp fmt (t : t) = Sourcemap.pp_line_col fmt (line_col t)
end

type t = Sourcemap.t

module Json_noloc = struct
  type t =
    | Str of string
    | Obj of (string * t) list
    | Arr of t list
    | Num of string
    | Null

  let str x = Str x
  let obj props = Obj props
  let arr xs = Arr xs
  let num x = Num x
  let null = Null

  let rec to_buffer buf = function
    | Str s ->
        Buffer.add_char buf '"';
        Buffer.add_string buf (String.escaped s);
        Buffer.add_char buf '"'
    | Num n -> Buffer.add_string buf n
    | Null -> Buffer.add_string buf "null"
    | Arr xs ->
        Buffer.add_char buf '[';
        List.iteri
          (fun i x ->
            if i > 0 then Buffer.add_char buf ',';
            to_buffer buf x)
          xs;
        Buffer.add_char buf ']'
    | Obj props ->
        Buffer.add_char buf '{';
        List.iteri
          (fun i (k, v) ->
            if i > 0 then Buffer.add_char buf ',';
            Buffer.add_char buf '"';
            Buffer.add_string buf (String.escaped k);
            Buffer.add_string buf "\":";
            to_buffer buf v)
          props;
        Buffer.add_char buf '}'

  let to_string x =
    let buf = Buffer.create 256 in
    to_buffer buf x;
    Buffer.contents buf

  let to_channel chan x = output_string chan (to_string x)
end

module Json_writer : Sourcemap.Json_writer_intf with type t = Json_noloc.t =
struct
  type t = Json_noloc.t

  let of_string x = Json_noloc.str x
  let of_obj props = Json_noloc.obj props
  let of_array arr = Json_noloc.arr arr
  let of_number x = Json_noloc.num x
  let null = Json_noloc.null
end

exception Json_error

module Json_reader : Sourcemap.Json_reader_intf with type t = Json_noloc.t =
struct
  type t = Json_noloc.t

  let to_string t =
    match t with Json_noloc.Str x -> x | _ -> raise Json_error

  let to_obj t =
    match t with Json_noloc.Obj x -> x | _ -> raise Json_error

  let to_array t =
    match t with Json_noloc.Arr x -> x | _ -> raise Json_error

  let to_number t =
    match t with Json_noloc.Num x -> x | _ -> raise Json_error

  let is_null = function Json_noloc.Null -> true | _ -> false
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
  Sourcemap.add_mapping ~original ~generated t

let add_sources_content t content =
  Sourcemap.add_source_content t
    ~source:(Option.get (Sourcemap.file t))
    ~content

let create ~source_name = Sourcemap.create ~file:source_name ()
let to_string t = Json_noloc.to_string (W.json_of_sourcemap t)
let to_channel t chan = Json_noloc.to_channel chan (W.json_of_sourcemap t)
