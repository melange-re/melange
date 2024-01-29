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

type error =
  | Invalid_code_point
  | Unterminated_backslash
  | Unterminated_variable
  | Unmatched_paren
  | Invalid_syntax_of_var of string

type kind = String | Var of int * int
(* [Var (loffset, roffset)]
   For parens it used to be (2,-1)
   for non-parens it used to be (1,0) *)

(* Note the position is about code point *)
type pos = {
  lnum : int;
  offset : int;
  byte_bol : int;
      (* Note it actually needs to be in sync with OCaml's lexing semantics *)
}

type segment = { start : pos; finish : pos; kind : kind; content : string }

type cxt = {
  mutable segment_start : pos;
  buf : Buffer.t;
  s_len : int;
  mutable segments : segment list;
  pos_bol : int; (* record the abs position of current beginning line *)
  byte_bol : int;
  pos_lnum : int; (* record the line number *)
}

exception Error of pos * pos * error

let pp_error fmt err =
  Format.pp_print_string fmt
  @@
  match err with
  | Invalid_code_point -> "Invalid code point"
  | Unterminated_backslash -> "\\ ended unexpectedly"
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

let update border start finish (loc : Location.t) =
  let start_pos = loc.loc_start in
  {
    loc with
    loc_start = update_position border start start_pos;
    loc_end = update_position border finish start_pos;
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

let add_var_segment cxt loc loffset roffset =
  let content = Buffer.contents cxt.buf in
  Buffer.clear cxt.buf;
  let next_loc =
    { lnum = cxt.pos_lnum; offset = loc - cxt.pos_bol; byte_bol = cxt.byte_bol }
  in
  if valid_identifier content then (
    cxt.segments <-
      {
        start = cxt.segment_start;
        finish = next_loc;
        kind = Var (loffset, roffset);
        content;
      }
      :: cxt.segments;
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

let add_str_segment cxt loc =
  let content = Buffer.contents cxt.buf in
  Buffer.clear cxt.buf;
  let next_loc =
    { lnum = cxt.pos_lnum; offset = loc - cxt.pos_bol; byte_bol = cxt.byte_bol }
  in
  cxt.segments <-
    { start = cxt.segment_start; finish = next_loc; kind = String; content }
    :: cxt.segments;
  cxt.segment_start <- next_loc

let rec check_and_transform loc s byte_offset ({ s_len; buf; _ } as cxt) =
  if byte_offset = s_len then add_str_segment cxt loc
  else
    let current_char = s.[byte_offset] in
    match Melange_ffi.Utf8_string.classify current_char with
    | Single 92 (* '\\' *) ->
        let loc = loc + 1 in
        let offset = byte_offset + 1 in
        if offset >= s_len then pos_error cxt ~loc Unterminated_backslash
        else Buffer.add_char buf '\\';
        let cur_char = s.[offset] in
        Buffer.add_char buf cur_char;
        check_and_transform (loc + 1) s (offset + 1) cxt
    | Single 36 ->
        (* $ *)
        add_str_segment cxt loc;
        let offset = byte_offset + 1 in
        if offset >= s_len then pos_error ~loc cxt Unterminated_variable
        else
          let cur_char = s.[offset] in
          if cur_char = '(' then expect_var_paren (loc + 2) s (offset + 1) cxt
          else expect_simple_var (loc + 1) s offset cxt
    | Single _ | Leading _ | Cont _ ->
        Buffer.add_char buf current_char;
        check_and_transform (loc + 1) s (byte_offset + 1) cxt
    | Invalid -> pos_error ~loc cxt Invalid_code_point

(* Lets keep identifier simple, so that we could generating a function easier
   in the future for example
   let f = [%fn{| $x + $y = $x_add_y |}] *)
and expect_simple_var loc s offset ({ buf; s_len; _ } as cxt) =
  let v = ref offset in
  if not (offset < s_len && valid_lead_identifier_char s.[offset]) then
    pos_error cxt ~loc (Invalid_syntax_of_var String.empty)
  else (
    while !v < s_len && valid_identifier_char s.[!v] do
      (* TODO *)
      let cur_char = s.[!v] in
      Buffer.add_char buf cur_char;
      incr v
    done;
    let added_length = !v - offset in
    let loc = added_length + loc in
    add_var_segment cxt loc 1 0;
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
    add_var_segment cxt loc 2 (-1);
    check_and_transform loc s (added_length + 1 + offset) cxt)
  else pos_error cxt ~loc Unmatched_paren

(* TODO: Allow identifers x.A.y *)

let border = String.length "{j|"

let rec handle_segments =
  let module Exp = Ast_helper.Exp in
  let concat_ident : Longident.t = Ldot (Lident "Stdlib", "^") in
  let escaped_js_delimiter =
    (* syntax not allowed at the user level *)
    let unescaped_js_delimiter = "js" in
    Some unescaped_js_delimiter
  in
  let merge_loc (l : Location.t) (r : Location.t) =
    if l.loc_ghost then r
    else if r.loc_ghost then l
    else
      match (l, r) with
      | { loc_start; _ }, { loc_end; _ } (* TODO: improve*) ->
          { loc_start; loc_end; loc_ghost = false }
  in
  let aux loc segment =
    match segment with
    | { start; finish; kind; content } -> (
        match kind with
        | String ->
            let loc = update border start finish loc in
            Exp.constant (Pconst_string (content, loc, escaped_js_delimiter))
        | Var (soffset, foffset) ->
            let loc =
              {
                loc with
                loc_start =
                  update_position (soffset + border) start loc.loc_start;
                loc_end =
                  update_position (foffset + border) finish loc.loc_start;
              }
            in
            Exp.ident ~loc { loc; txt = Lident content })
  in
  let concat_exp a_loc x ~(lhs : expression) =
    let loc = merge_loc a_loc lhs.pexp_loc in
    Exp.apply
      (Exp.ident { txt = concat_ident; loc })
      [ (Nolabel, lhs); (Nolabel, aux loc x) ]
  in
  fun loc rev_segments ->
    match rev_segments with
    | [] -> Exp.constant (Pconst_string ("", loc, escaped_js_delimiter))
    | [ segment ] -> aux loc segment (* string literal *)
    | { content = ""; _ } :: rest -> handle_segments loc rest
    | a :: rest -> concat_exp loc a ~lhs:(handle_segments loc rest)

let transform =
  let unescaped_j_delimiter = "j" in
  let transform (e : expression) s ~delim =
    match String.equal delim unescaped_j_delimiter with
    | true ->
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
        handle_segments e.pexp_loc cxt.segments
    | false -> e
  in
  fun ~loc ~delim expr s ->
    try transform expr s ~delim
    with Error (start, pos, error) ->
      let loc = update border start pos loc in
      Location.raise_errorf ~loc "%a" pp_error error

module Private = struct
  type nonrec segment = segment = {
    start : pos;
    finish : pos;
    kind : kind;
    content : string;
  }

  let transform_test s =
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
    List.rev cxt.segments
end
