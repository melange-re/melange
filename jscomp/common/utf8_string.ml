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

type byte = Single of int | Cont of int | Leading of int * int | Invalid

(** [classify chr] returns the {!byte} corresponding to [chr] *)
let classify chr =
  let c = int_of_char chr in
  (* Classify byte according to leftmost 0 bit *)
  if c land 0b1000_0000 = 0 then Single c
  else if (* c 0b0____*)
          c land 0b0100_0000 = 0 then Cont (c land 0b0011_1111)
  else if (* c 0b10___*)
          c land 0b0010_0000 = 0 then Leading (1, c land 0b0001_1111)
  else if (* c 0b110__*)
          c land 0b0001_0000 = 0 then Leading (2, c land 0b0000_1111)
  else if (* c 0b1110_ *)
          c land 0b0000_1000 = 0 then Leading (3, c land 0b0000_0111)
  else if (* c 0b1111_0___*)
          c land 0b0000_0100 = 0 then Leading (4, c land 0b0000_0011)
  else if (* c 0b1111_10__*)
          c land 0b0000_0010 = 0 then Leading (5, c land 0b0000_0001)
    (* c 0b1111_110__ *)
  else Invalid

let rec next s ~remaining offset =
  if remaining = 0 then offset
  else
    match classify s.[offset + 1] with
    | Cont _cc -> next s ~remaining:(remaining - 1) (offset + 1)
    | _ -> -1
    | exception _ -> -1
(* it can happen when out of bound *)

let rec check_no_escapes_or_unicode (s : string) (byte_offset : int)
    (s_len : int) =
  if byte_offset = s_len then true
  else
    let current_char = s.[byte_offset] in
    match classify current_char with
    | Single 92 (* '\\' *) -> false
    | Single _ -> check_no_escapes_or_unicode s (byte_offset + 1) s_len
    | Invalid | Cont _ | Leading _ -> false

let simple_comparison s = check_no_escapes_or_unicode s 0 (String.length s)

(* Supported delimiters *)
let escaped_j_delimiter = "*j" (* not user level syntax allowed *)
let unescaped_j_delimiter = "j"
let unescaped_js_delimiter = "js"
let is_unicode_string opt = String.equal opt escaped_j_delimiter

let is_unescaped s =
  String.equal s unescaped_j_delimiter || String.equal s unescaped_js_delimiter

let valid_hex x =
  match x with '0' .. '9' | 'a' .. 'f' | 'A' .. 'F' -> true | _ -> false

let merge_loc (l : Location.t) (r : Location.t) =
  if l.loc_ghost then r
  else if r.loc_ghost then l
  else
    match (l, r) with
    | { loc_start; _ }, { loc_end; _ } (* TODO: improve*) ->
        { loc_start; loc_end; loc_ghost = false }

module Utf8_string = struct
  type error =
    | Invalid_code_point
    | Unterminated_backslash
    | Invalid_hex_escape
    | Invalid_unicode_escape

  let pp_error fmt err =
    let msg =
      match err with
      | Invalid_code_point -> "Invalid code point"
      | Unterminated_backslash -> "\\ ended unexpectedly"
      | Invalid_hex_escape -> "Invalid \\x escape"
      | Invalid_unicode_escape -> "Invalid \\u escape"
    in
    Format.pp_print_string fmt msg

  type exn += Error of int (* offset *) * error

  let error ~loc error = raise (Error (loc, error))

  (* Note the [loc] really should be the utf8-offset, it has nothing to do with our
      escaping mechanism *)
  (* we can not just print new line in ES5
     seems we don't need
     escape "\b" "\f"
     we need escape "\n" "\r" since
     ocaml multiple-line allows [\n]
     visual input while es5 string
     does not*)

  let rec check_and_transform (loc : int) (buf : Buffer.t) (s : string)
      (byte_offset : int) (s_len : int) =
    if byte_offset = s_len then ()
    else
      let current_char = s.[byte_offset] in
      match classify current_char with
      | Single 92 (* '\\' *) ->
          escape_code (loc + 1) buf s (byte_offset + 1) s_len
      | Single 34 ->
          Buffer.add_string buf "\\\"";
          check_and_transform (loc + 1) buf s (byte_offset + 1) s_len
      | Single 10 ->
          Buffer.add_string buf "\\n";
          check_and_transform (loc + 1) buf s (byte_offset + 1) s_len
      | Single 13 ->
          Buffer.add_string buf "\\r";
          check_and_transform (loc + 1) buf s (byte_offset + 1) s_len
      | Single _ ->
          Buffer.add_char buf current_char;
          check_and_transform (loc + 1) buf s (byte_offset + 1) s_len
      | Invalid | Cont _ -> error ~loc Invalid_code_point
      | Leading (n, _) ->
          let i' = next s ~remaining:n byte_offset in
          if i' < 0 then error ~loc Invalid_code_point
          else (
            for k = byte_offset to i' do
              Buffer.add_char buf s.[k]
            done;
            check_and_transform (loc + 1) buf s (i' + 1) s_len)

  (* we share the same escape sequence with js *)
  and escape_code loc buf s offset s_len =
    if offset >= s_len then error ~loc Unterminated_backslash
    else Buffer.add_char buf '\\';
    let cur_char = s.[offset] in
    match cur_char with
    | '\\' | 'b' | 't' | 'n' | 'v' | 'f' | 'r' | '0' | '$' ->
        Buffer.add_char buf cur_char;
        check_and_transform (loc + 1) buf s (offset + 1) s_len
    | 'u' ->
        Buffer.add_char buf cur_char;
        unicode (loc + 1) buf s (offset + 1) s_len
    | 'x' ->
        Buffer.add_char buf cur_char;
        two_hex (loc + 1) buf s (offset + 1) s_len
    | _ ->
        (* Regular characters, like `a` in `\a`,
         * are valid escape sequences *)
        Buffer.add_char buf cur_char;
        check_and_transform (loc + 1) buf s (offset + 1) s_len

  and two_hex loc buf s offset s_len =
    if offset + 1 >= s_len then error ~loc Invalid_hex_escape;
    let a, b = (s.[offset], s.[offset + 1]) in
    if valid_hex a && valid_hex b then (
      Buffer.add_char buf a;
      Buffer.add_char buf b;
      check_and_transform (loc + 2) buf s (offset + 2) s_len)
    else error ~loc Invalid_hex_escape

  and unicode loc buf s offset s_len =
    if offset + 3 >= s_len then error ~loc Invalid_unicode_escape;
    let a0, a1, a2, a3 =
      (s.[offset], s.[offset + 1], s.[offset + 2], s.[offset + 3])
    in
    if valid_hex a0 && valid_hex a1 && valid_hex a2 && valid_hex a3 then (
      Buffer.add_char buf a0;
      Buffer.add_char buf a1;
      Buffer.add_char buf a2;
      Buffer.add_char buf a3;
      check_and_transform (loc + 4) buf s (offset + 4) s_len)
    else error ~loc Invalid_unicode_escape

  (* http://www.2ality.com/2015/01/es6-strings.html
     console.log('\uD83D\uDE80'); (* ES6*)
     console.log('\u{1F680}');
  *)
  let transform s =
    let s_len = String.length s in
    let buf = Buffer.create (s_len * 2) in
    check_and_transform 0 buf s 0 s_len;
    Buffer.contents buf

  module Private = struct
    let transform = transform
  end

  let transform ~loc s =
    try transform s
    with Error (offset, error) ->
      Location.raise_errorf ~loc "Offset: %d, %a" offset pp_error error
end

module Interp = struct
  type error =
    | Invalid_code_point
    | Unterminated_backslash
    | Invalid_escape_code of char
    | Invalid_hex_escape
    | Invalid_unicode_escape
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
  type segments = segment list

  type cxt = {
    mutable segment_start : pos;
    buf : Buffer.t;
    s_len : int;
    mutable segments : segments;
    mutable pos_bol : int;
        (* record the abs position of current beginning line *)
    mutable byte_bol : int;
    mutable pos_lnum : int; (* record the line number *)
  }

  type exn += Error of pos * pos * error

  let pp_error fmt err =
    Format.pp_print_string fmt
    @@
    match err with
    | Invalid_code_point -> "Invalid code point"
    | Unterminated_backslash -> "\\ ended unexpectedly"
    | Invalid_escape_code c -> "Invalid escape code: " ^ String.make 1 c
    | Invalid_hex_escape -> "Invalid \\x escape"
    | Invalid_unicode_escape -> "Invalid \\u escape"
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
        valid_lead_identifier_char s.[0]
        && for_all_from s 1 valid_identifier_char

  (* FIXME: multiple line offset
     if there is no line offset. Note {|{j||} border will never trigger a new
     line *)
  let update_position border ({ lnum; offset; byte_bol } : pos)
      (pos : Lexing.position) =
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

  let update border (start : pos) (finish : pos) (loc : Location.t) : Location.t
      =
    let start_pos = loc.loc_start in
    {
      loc with
      loc_start = update_position border start start_pos;
      loc_end = update_position border finish start_pos;
    }

  let update_newline ~byte_bol loc cxt =
    cxt.pos_lnum <- cxt.pos_lnum + 1;
    cxt.pos_bol <- loc;
    cxt.byte_bol <- byte_bol

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
      {
        lnum = cxt.pos_lnum;
        offset = loc - cxt.pos_bol;
        byte_bol = cxt.byte_bol;
      }
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
                    (match cxt.segment_start.byte_bol with
                    | 0 -> 0
                    | n -> n - 3);
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
      {
        lnum = cxt.pos_lnum;
        offset = loc - cxt.pos_bol;
        byte_bol = cxt.byte_bol;
      }
    in
    cxt.segments <-
      { start = cxt.segment_start; finish = next_loc; kind = String; content }
      :: cxt.segments;
    cxt.segment_start <- next_loc

  let rec check_and_transform (loc : int) s byte_offset
      ({ s_len; buf; _ } as cxt : cxt) =
    if byte_offset = s_len then add_str_segment cxt loc
    else
      let current_char = s.[byte_offset] in
      match classify current_char with
      | Single 92 (* '\\' *) -> escape_code (loc + 1) s (byte_offset + 1) cxt
      | Single 34 ->
          Buffer.add_string buf "\\\"";
          check_and_transform (loc + 1) s (byte_offset + 1) cxt
      | Single 10 ->
          Buffer.add_string buf "\\n";
          let loc = loc + 1 in
          let byte_offset = byte_offset + 1 in
          update_newline ~byte_bol:byte_offset loc cxt;
          (* Note variable could not have new-line *)
          check_and_transform loc s byte_offset cxt
      | Single 13 ->
          Buffer.add_string buf "\\r";
          check_and_transform (loc + 1) s (byte_offset + 1) cxt
      | Single 36 ->
          (* $ *)
          add_str_segment cxt loc;
          let offset = byte_offset + 1 in
          if offset >= s_len then pos_error ~loc cxt Unterminated_variable
          else
            let cur_char = s.[offset] in
            if cur_char = '(' then expect_var_paren (loc + 2) s (offset + 1) cxt
            else expect_simple_var (loc + 1) s offset cxt
      | Single _ ->
          Buffer.add_char buf current_char;
          check_and_transform (loc + 1) s (byte_offset + 1) cxt
      | Invalid | Cont _ -> pos_error ~loc cxt Invalid_code_point
      | Leading (n, _) ->
          let i' = next s ~remaining:n byte_offset in
          if i' < 0 then pos_error cxt ~loc Invalid_code_point
          else (
            for k = byte_offset to i' do
              Buffer.add_char buf s.[k]
            done;
            check_and_transform (loc + 1) s (i' + 1) cxt)

  (* Lets keep identifier simple, so that we could generating a function easier
     in the future for example
     let f = [%fn{| $x + $y = $x_add_y |}] *)
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

  (* we share the same escape sequence with js *)
  and escape_code loc s offset ({ buf; s_len; _ } as cxt) =
    if offset >= s_len then pos_error cxt ~loc Unterminated_backslash
    else Buffer.add_char buf '\\';
    let cur_char = s.[offset] in
    match cur_char with
    | '\\' | 'b' | 't' | 'n' | 'v' | 'f' | 'r' | '0' | '$' ->
        Buffer.add_char buf cur_char;
        check_and_transform (loc + 1) s (offset + 1) cxt
    | 'u' ->
        Buffer.add_char buf cur_char;
        unicode (loc + 1) s (offset + 1) cxt
    | 'x' ->
        Buffer.add_char buf cur_char;
        two_hex (loc + 1) s (offset + 1) cxt
    | _ -> pos_error cxt ~loc (Invalid_escape_code cur_char)

  and two_hex loc s offset ({ buf; s_len; _ } as cxt) =
    if offset + 1 >= s_len then pos_error cxt ~loc Invalid_hex_escape;
    let a, b = (s.[offset], s.[offset + 1]) in
    if valid_hex a && valid_hex b then (
      Buffer.add_char buf a;
      Buffer.add_char buf b;
      check_and_transform (loc + 2) s (offset + 2) cxt)
    else pos_error cxt ~loc Invalid_hex_escape

  and unicode loc s offset ({ buf; s_len; _ } as cxt) =
    if offset + 3 >= s_len then pos_error cxt ~loc Invalid_unicode_escape;
    let a0, a1, a2, a3 =
      (s.[offset], s.[offset + 1], s.[offset + 2], s.[offset + 3])
    in
    if valid_hex a0 && valid_hex a1 && valid_hex a2 && valid_hex a3 then (
      Buffer.add_char buf a0;
      Buffer.add_char buf a1;
      Buffer.add_char buf a2;
      Buffer.add_char buf a3;
      check_and_transform (loc + 4) s (offset + 4) cxt)
    else pos_error cxt ~loc Invalid_unicode_escape

  (* TODO: Allow identifers x.A.y *)

  module Exp = Ast_helper.Exp

  let concat_ident : Longident.t = Ldot (Lident "Stdlib", "^")

  let escaped_j_delimiter =
    (* syntax not allowed at the user level *)
    Some escaped_j_delimiter

  let border = String.length "{j|"

  (* Invariant: the [lhs] is always of type string *)
  let rec handle_segments =
    let aux loc (segment : segment) ~to_string_ident : Parsetree.expression =
      match segment with
      | { start; finish; kind; content } -> (
          match kind with
          | String ->
              let loc = update border start finish loc in
              Exp.constant (Pconst_string (content, loc, escaped_j_delimiter))
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
              Exp.apply
                (Exp.ident ~loc { loc; txt = to_string_ident })
                [ (Nolabel, Exp.ident ~loc { loc; txt = Lident content }) ])
    in
    let concat_exp =
      let to_string_ident = Longident.Ldot (Lident "Obj", "magic") in
      fun a_loc x ~(lhs : Parsetree.expression) : Parsetree.expression ->
        let loc = merge_loc a_loc lhs.pexp_loc in
        Exp.apply
          (Exp.ident { txt = concat_ident; loc })
          [ (Nolabel, lhs); (Nolabel, aux loc x ~to_string_ident) ]
    in
    let to_string_ident =
      Longident.Ldot (Ldot (Lident "Js", "String"), "make")
    in
    fun loc (rev_segments : segment list) ->
      match rev_segments with
      | [] -> Exp.constant (Pconst_string ("", loc, escaped_j_delimiter))
      | [ segment ] -> aux loc segment ~to_string_ident (* string literal *)
      | { content = ""; _ } :: rest -> handle_segments loc rest
      | a :: rest -> concat_exp loc a ~lhs:(handle_segments loc rest)

  let transform_interp loc s =
    let s_len = String.length s in
    let buf = Buffer.create (s_len * 2) in
    let cxt : cxt =
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
    handle_segments loc cxt.segments

  let transform =
    let transform (e : Parsetree.expression) s ~loc ~delim =
      match String.equal delim unescaped_js_delimiter with
      | true ->
          {
            e with
            pexp_desc =
              Pexp_constant
                (Pconst_string
                   (Utf8_string.transform ~loc s, loc, escaped_j_delimiter));
          }
      | false -> (
          match String.equal delim unescaped_j_delimiter with
          | true -> transform_interp e.pexp_loc s
          | false -> e)
    in
    fun ~loc ~delim expr s ->
      try transform expr s ~loc ~delim
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
end

let rewrite_structure =
  let mapper =
    let super = Ast_mapper.default_mapper in
    {
      super with
      expr =
        (fun self e ->
          match e.pexp_desc with
          | Pexp_constant (Pconst_string (s, loc, Some delim)) ->
              Interp.transform e s ~loc ~delim
          | _ -> super.expr self e);
    }
  in
  fun (stru : Parsetree.structure) -> mapper.structure mapper stru
