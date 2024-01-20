open Import

type error =
  | Unterminated_variable
  | Unmatched_paren
  | Invalid_syntax_of_var of string

(* Note the position is about code point *)
type pos = {
  lnum : int;
  offset : int;
  byte_bol : int;
      (* Note it actually needs to be in sync with OCaml's lexing semantics *)
}

type cxt = {
  mutable segment_start : pos;
  buf : Buffer.t;
  s_len : int;
  mutable segments : string list;
  pos_bol : int; (* record the abs position of current beginning line *)
  byte_bol : int;
  pos_lnum : int; (* record the line number *)
}

type exn += Error of pos * pos * error

let pp_error fmt err =
  Format.pp_print_string fmt
  @@
  match err with
  | Unterminated_variable -> "$ unterminated"
  | Unmatched_paren -> "Unmatched paren"
  | Invalid_syntax_of_var s ->
      "`" ^ s ^ "' is not a valid syntax of interpolated identifer"

let valid_lead_identifier_char x =
  match x with 'a' .. 'z' | '_' -> true | _ -> false

let valid_identifier_char x =
  match x with
  | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '\'' -> true
  | _ -> false

(* Invariant: [valid_lead_identifier] has to be [valid_identifier] *)
let valid_identifier =
  let for_all_from =
    let rec unsafe_for_all_range s ~start ~finish p =
      start > finish
      || p (String.unsafe_get s start)
         && unsafe_for_all_range s ~start:(start + 1) ~finish p
    in
    fun s start p ->
      let len = String.length s in
      if start < 0 then invalid_arg "for_all_from"
      else unsafe_for_all_range s ~start ~finish:(len - 1) p
  in
  fun s ->
    let s_len = String.length s in
    if s_len = 0 then false
    else
      valid_lead_identifier_char s.[0] && for_all_from s 1 valid_identifier_char

(* FIXME: multiple line offset
   if there is no line offset. Note {|{j||} border will never trigger a new
   line *)
let update_position border { lnum; offset; byte_bol } (pos : Lexing.position) =
  if lnum = 0 then { pos with pos_cnum = pos.pos_cnum + border + offset }
    (* When no newline, the column number is [border + offset] *)
  else
    {
      pos with
      pos_lnum = pos.pos_lnum + lnum;
      pos_bol = pos.pos_cnum + border + byte_bol;
      pos_cnum = pos.pos_cnum + border + byte_bol + offset;
      (* when newline, the column number is [offset] *)
    }

let pos_error cxt ~loc error =
  raise
    (Error
       ( cxt.segment_start,
         {
           lnum = cxt.pos_lnum;
           offset = loc - cxt.pos_bol;
           byte_bol = cxt.byte_bol;
         },
         error ))

let add_var_segment cxt loc =
  let content = Buffer.contents cxt.buf in
  Buffer.clear cxt.buf;
  let next_loc =
    { lnum = cxt.pos_lnum; offset = loc - cxt.pos_bol; byte_bol = cxt.byte_bol }
  in
  if valid_identifier content then (
    cxt.segments <- content :: cxt.segments;
    cxt.segment_start <- next_loc)
  else
    let cxt =
      match String.trim content with
      | "" ->
          (* Move the position back 2 characters "$(" if this is the empty
             interpolation. *)
          {
            cxt with
            segment_start =
              {
                cxt.segment_start with
                offset =
                  (match cxt.segment_start.offset with 0 -> 0 | n -> n - 3);
                byte_bol =
                  (match cxt.segment_start.byte_bol with 0 -> 0 | n -> n - 3);
              };
            pos_bol = cxt.pos_bol + 3;
            byte_bol = cxt.byte_bol + 3;
          }
      | _ -> cxt
    in
    pos_error cxt ~loc (Invalid_syntax_of_var content)

let rec check_and_transform loc s byte_offset ({ s_len; _ } as cxt) =
  if byte_offset = s_len then ()
  else
    let current_char = s.[byte_offset] in
    match Melange_ffi.Utf8_string.classify current_char with
    | Single 36 ->
        (* $ *)
        let offset = byte_offset + 1 in
        if offset >= s_len then pos_error ~loc cxt Unterminated_variable
        else
          let cur_char = s.[offset] in
          if cur_char = '(' then expect_var_paren (loc + 2) s (offset + 1) cxt
          else expect_simple_var (loc + 1) s offset cxt
    | _ -> check_and_transform (loc + 1) s (byte_offset + 1) cxt

and expect_simple_var loc s offset ({ buf; s_len; _ } as cxt) =
  let v = ref offset in
  if not (offset < s_len && valid_lead_identifier_char s.[offset]) then
    pos_error cxt ~loc (Invalid_syntax_of_var String.empty)
  else (
    while !v < s_len && valid_identifier_char s.[!v] do
      (* TODO*)
      let cur_char = s.[!v] in
      Buffer.add_char buf cur_char;
      incr v
    done;
    let added_length = !v - offset in
    let loc = added_length + loc in
    add_var_segment cxt loc;
    check_and_transform loc s (added_length + offset) cxt)

and expect_var_paren loc s offset ({ buf; s_len; _ } as cxt) =
  let v = ref offset in
  while !v < s_len && s.[!v] <> ')' do
    let cur_char = s.[!v] in
    Buffer.add_char buf cur_char;
    incr v
  done;
  let added_length = !v - offset in
  let loc = added_length + 1 + loc in
  if !v < s_len && s.[!v] = ')' then (
    add_var_segment cxt loc;
    check_and_transform loc s (added_length + 1 + offset) cxt)
  else pos_error cxt ~loc Unmatched_paren

module Exp = Ast_helper.Exp

let handle_variables rev_segments =
  List.map
    ~f:(fun content ->
      let loc = Location.none in
      Ast_helper.Vb.mk (Ast_helper.Pat.any ())
        (Exp.ident ~loc { loc; txt = Lident content }))
    rev_segments

let transform_interp s =
  let s_len = String.length s in
  let buf = Buffer.create (s_len * 2) in
  let cxt =
    {
      segment_start = { lnum = 0; offset = 0; byte_bol = 0 };
      buf;
      s_len;
      segments = [];
      pos_lnum = 0;
      byte_bol = 0;
      pos_bol = 0;
    }
  in
  check_and_transform 0 s 0 cxt;
  handle_variables cxt.segments

let update start finish (loc : Location.t) =
  let start_pos = loc.loc_start in
  let border = 3 (* "{j|" *) in
  {
    loc with
    loc_start = update_position border start start_pos;
    loc_end = update_position border finish start_pos;
  }

let transform =
  let transform (e : Parsetree.expression) s ~delim =
    match String.equal delim "j" with
    | true -> (
        match transform_interp s with
        | [] -> e
        | _ :: _ as vbs -> Exp.let_ Nonrecursive vbs e)
    | false -> e
  in
  fun ~loc ~delim expr s ->
    try transform expr s ~delim
    with Error (start, pos, error) ->
      let loc = update start pos loc in
      Location.raise_errorf ~loc "%a" pp_error error
