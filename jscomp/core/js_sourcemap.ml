(* TODO: proper implementation, this only mark the beginning of an AST node
          and has problems if the same node spans multiple lines, but
          it's O(n) in number of AST nodes, so blazing fast *)
(* HACKING
      https://sokra.github.io/source-map-visualization/ *)
type t = {
  source_name: string;
  source_content: string;
  output_name: string;

  mutable generated_line: int;
  mutable generated_column: int;
  source: int;
  mutable line: int;
  mutable column: int;
  buffer: Buffer.t;
  pp_output: Ext_pp.t;
}


(* TODO: only works up to 31bits Vlq, hopefully this will never be a problem *)

let write t loc = 
  let start = loc.Location.loc_start in

  let new_generated_line = Ext_pp.current_line t.pp_output in
  let new_generated_column = Ext_pp.current_column t.pp_output in
  let new_line = start.pos_lnum in
  let new_column = start.pos_cnum - start.pos_bol in
  Format.eprintf "%a\n%!" Location.print_loc loc;

  let generated_line_offset = new_generated_line - t.generated_line in
  let generated_column_offset =
    if generated_line_offset = 0 then
      new_generated_column - t.generated_column
    else
      new_generated_column in
  let source_offset = 0 in
  let line_offset = new_line - t.line in
  let column_offset = new_column - t.column in

  t.generated_line <- new_generated_line;
  t.generated_column <- new_generated_column;
  t.line <- new_line;
  t.column <- new_column;

  (* add new group until the offset is 0 *)
  let rec print =
    function
    | 0 ->
      Buffer.add_string t.buffer ",";
      Vlq.Base64.encode t.buffer generated_column_offset;
      Vlq.Base64.encode t.buffer source_offset;
      Vlq.Base64.encode t.buffer line_offset;
      Vlq.Base64.encode t.buffer column_offset;
    | n ->
      (* TODO: is ;; valid to skip n lines? Run it on visualizer *)
      Buffer.add_string t.buffer ";A";
      print (n - 1) in
  print generated_line_offset


let make ~source_name ~source_content ~output_name pp_output = 
  let source_length = String.length source_content in
  let buffer = Buffer.create (source_length + (source_length / 2)) in

  {
    source_name;
    source_content;
    output_name;

    generated_line = 0;
    generated_column = 0;
    source = 0;
    line = 1;
    column = 0;
    buffer;
    pp_output
  }

let wrapper = Printf.sprintf {|{
  "version": 3,
  "sources": [%S],
  "names": [],
  "file": %S,
  "sourcesContent": [%S],
  "mappings": "%s"
}|}
let to_string t =
  let mappings = Buffer.to_bytes t.buffer |> Bytes.to_string in
  (* TODO: this API is not the smartest one, double allocation *)
  wrapper t.source_name t.output_name t.source_content mappings
