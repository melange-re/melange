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

(* Source Map v3 / ECMA-426: generated and original JavaScript columns use
   UTF-16 code units, while OCaml locations count UTF-8 bytes. *)
type snapshot = { key : string; path : string; content : string option }

let sources : snapshot String.Hashtbl.t = String.Hashtbl.create 16
let reset () = String.Hashtbl.clear sources
let absolute = Paths.absolute_cwd_path

let relative ~from path =
  Filename.concat
    (Paths.rel_normalized_absolute_path ~from (Filename.dirname path))
    (Filename.basename path)
  |> String.map ~f:(function '\\' -> '/' | c -> c)

let source key =
  match String.Hashtbl.find_opt sources key with
  | Some source -> source
  | None ->
      let path = absolute key in
      let content =
        try Some (Io.read_file_exn path)
        with Sys_error _ | Unix.Unix_error _ -> None
      in
      let source = { key; path; content } in
      String.Hashtbl.add sources ~key ~data:source;
      source

let capture ~source_dir keys =
  let from = absolute source_dir in
  List.map keys ~f:(fun key ->
      let source = source key in
      { source with path = relative ~from source.path })

let register ~source_dir snapshots =
  List.iter snapshots ~f:(fun source ->
      String.Hashtbl.replace sources ~key:source.key
        ~data:
          {
            source with
            path = absolute (Filename.concat source_dir source.path);
          })

let location (loc : Location.t) =
  if !Js_config.source_map = None then loc
  else
    let position (p : Lexing.position) =
      if p.pos_fname = "" || p.pos_fname = "_none_" then p
      else { p with pos_fname = absolute p.pos_fname }
    in
    {
      loc with
      loc_start = position loc.loc_start;
      loc_end = position loc.loc_end;
    }

let uri_path s =
  let buffer = Buffer.create (String.length s) in
  String.iter s ~f:(function
    | ('a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '-' | '_' | '.' | '~' | '/') as c
      ->
        Buffer.add_char buffer c
    | c -> Buffer.add_string buffer (Printf.sprintf "%%%02X" (Char.code c)));
  Buffer.contents buffer

let utf16_width byte =
  if byte land 0xc0 = 0x80 then 0 else if byte >= 0xf0 then 2 else 1

let utf16_column line bytes =
  let column = ref 0 in
  for i = 0 to bytes - 1 do
    column := !column + utf16_width (Char.code line.[i])
  done;
  !column

type mapping = { line : int; column : int; original : (int * int * int) option }
type original = { index : int; lines : string array }

type t = {
  file : string;
  output_dir : string;
  mutable line : int;
  mutable column : int;
  mutable previous : int;
  mutable penultimate : int;
  mutable mappings : mapping list;
  originals : original String.Hashtbl.t;
  mutable ordered_sources : snapshot list;
}

let create ~file =
  {
    file = Filename.basename file;
    output_dir = absolute (Filename.dirname file);
    line = 0;
    column = 0;
    previous = -1;
    penultimate = -1;
    mappings = [];
    originals = String.Hashtbl.create 8;
    ordered_sources = [];
  }

let advance t s len =
  for i = 0 to len - 1 do
    let byte = Char.code s.[i] in
    if byte = 0x0d then (
      t.line <- t.line + 1;
      t.column <- 0)
    else if byte = 0x0a then (
      if t.previous <> 0x0d then t.line <- t.line + 1;
      t.column <- 0)
    else if
      t.penultimate = 0xe2 && t.previous = 0x80 && (byte = 0xa8 || byte = 0xa9)
    then (
      t.line <- t.line + 1;
      t.column <- 0)
    else t.column <- t.column + utf16_width byte;
    t.penultimate <- t.previous;
    t.previous <- byte
  done

let add t original =
  let mapping = { line = t.line; column = t.column; original } in
  match t.mappings with
  | last :: rest when last.line = t.line && last.column = t.column ->
      t.mappings <- mapping :: rest
  | last :: _ when last.line = t.line && last.original = original -> ()
  | _ -> t.mappings <- mapping :: t.mappings

let unmapped t = add t None

let mark t (loc : Location.t) =
  let p = loc.loc_start in
  if p.pos_fname <> "" && p.pos_fname <> "_none_" && p.pos_lnum > 0 then
    let original =
      match String.Hashtbl.find_opt t.originals p.pos_fname with
      | Some original -> original
      | None ->
          let source = source p.pos_fname in
          let original =
            {
              index = String.Hashtbl.length t.originals;
              lines =
                (match source.content with
                | None -> [||]
                | Some text ->
                    Array.of_list (String.split_on_char ~sep:'\n' text));
            }
          in
          String.Hashtbl.add t.originals ~key:p.pos_fname ~data:original;
          t.ordered_sources <- source :: t.ordered_sources;
          original
    in
    let line = p.pos_lnum - 1 in
    let bytes = p.pos_cnum - p.pos_bol in
    if
      line < Array.length original.lines
      && bytes >= 0
      && bytes <= String.length original.lines.(line)
    then
      add t
        (Some (original.index, line, utf16_column original.lines.(line) bytes))
    else unmapped t

let alphabet =
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

let vlq buffer value =
  let rec loop n =
    let digit = n land 31 in
    let rest = n lsr 5 in
    Buffer.add_char buffer alphabet.[if rest = 0 then digit else digit lor 32];
    if rest <> 0 then loop rest
  in
  loop (if value < 0 then (-value lsl 1) lor 1 else value lsl 1)

let encode_mappings mappings =
  let buffer = Buffer.create 256 in
  let line = ref 0 and column = ref 0 and first = ref true in
  let source = ref 0 and original_line = ref 0 and original_column = ref 0 in
  List.rev_iter mappings ~f:(fun (mapping : mapping) ->
      while !line < mapping.line do
        Buffer.add_char buffer ';';
        incr line;
        column := 0;
        first := true
      done;
      if !first then first := false else Buffer.add_char buffer ',';
      vlq buffer (mapping.column - !column);
      column := mapping.column;
      match mapping.original with
      | None -> ()
      | Some (s, l, c) ->
          vlq buffer (s - !source);
          source := s;
          vlq buffer (l - !original_line);
          original_line := l;
          vlq buffer (c - !original_column);
          original_column := c);
  Buffer.contents buffer

let json_string s =
  let buffer = Buffer.create (String.length s + 2) in
  Buffer.add_char buffer '"';
  String.iter s ~f:(function
    | '"' -> Buffer.add_string buffer "\\\""
    | '\\' -> Buffer.add_string buffer "\\\\"
    | '\n' -> Buffer.add_string buffer "\\n"
    | '\r' -> Buffer.add_string buffer "\\r"
    | '\t' -> Buffer.add_string buffer "\\t"
    | c when Char.code c < 32 ->
        Buffer.add_string buffer (Printf.sprintf "\\u%04x" (Char.code c))
    | c -> Buffer.add_char buffer c);
  Buffer.add_char buffer '"';
  Buffer.contents buffer

let to_json t =
  let sources = List.rev t.ordered_sources in
  let array f = "[" ^ String.concat ~sep:"," (List.map sources ~f) ^ "]" in
  "{\"version\":3,\"file\":" ^ json_string t.file ^ ",\"sources\":"
  ^ array (fun s -> json_string (uri_path (relative ~from:t.output_dir s.path)))
  ^ ",\"sourcesContent\":"
  ^ array (fun s ->
      match s.content with None -> "null" | Some s -> json_string s)
  ^ ",\"names\":[],\"mappings\":"
  ^ json_string (encode_mappings t.mappings)
  ^ "}\n"

let base64 s =
  let buffer = Buffer.create ((String.length s + 2) / 3 * 4) in
  let byte i = if i < String.length s then Char.code s.[i] else 0 in
  let rec loop i =
    if i < String.length s then (
      let a = byte i and b = byte (i + 1) and c = byte (i + 2) in
      Buffer.add_char buffer alphabet.[a lsr 2];
      Buffer.add_char buffer alphabet.[((a land 3) lsl 4) lor (b lsr 4)];
      Buffer.add_char buffer
        (if i + 1 < String.length s then
           alphabet.[((b land 15) lsl 2) lor (c lsr 6)]
         else '=');
      Buffer.add_char buffer
        (if i + 2 < String.length s then alphabet.[c land 63] else '=');
      loop (i + 3))
  in
  loop 0;
  Buffer.contents buffer

let comment_prefix t = if t.column = 0 then "" else "\n"

let inline_comment t =
  comment_prefix t
  ^ "//# sourceMappingURL=data:application/json;charset=utf-8;base64,"
  ^ base64 (to_json t)
  ^ "\n"

let file_comment t file =
  comment_prefix t ^ "//# sourceMappingURL="
  ^ uri_path (Filename.basename file)
  ^ ".map\n"
