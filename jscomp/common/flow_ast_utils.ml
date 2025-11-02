(* Copyright (C) 2020 - Hongbo Zhang, Authors of ReScript
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
open Js_parser

let flow_deli_offset = function
  | None -> 1 (* length of '"' *)
  | Some deli -> String.length deli + 2 (* length of "{|" *)

let check_flow_errors =
  let offset_pos ({ pos_lnum; pos_bol; pos_cnum; _ } as loc : Lexing.position)
      ({ line; column } : Loc.position) first_line_offset =
    match line with
    | 1 -> { loc with pos_cnum = pos_cnum + column + first_line_offset }
    | line ->
        { loc with pos_lnum = pos_lnum + line - 1; pos_cnum = pos_bol + column }
  in
  (* Here, [loc] is the payload loc *)
  fun ~(loc : Location.t) ~offset (errors : (Loc.t * Parse_error.t) list) ->
    match errors with
    | [] -> None
    | ({ start; _end; _ }, first_error) :: _ ->
        let loc_start = loc.loc_start in
        Location.prerr_warning
          {
            loc with
            loc_start = offset_pos loc_start start offset;
            loc_end = offset_pos loc_start _end offset;
          }
          (Mel_ffi_warning (Parse_error.PP.error first_error));
        Some first_error

type check_errors =
  | Dont_check
  | Check of { loc : Location.t; delimiter : string option }

let parse_generic : type a.
    parser:(Parser_env.env -> 'x * a) ->
    check_errors:check_errors ->
    string ->
    (a, a * Parse_error.t) result =
 fun ~parser ~check_errors str ->
  let env = Parser_env.init_env None str in
  (* match Parser_env.Peek.token env with *)
  (* | Token.T_EOF -> Error Parse_error.UnexpectedEOS *)
  (* | _ -> *)
  let (_, prog), errors = Parser_flow.do_parse env parser false in
  match check_errors with
  | Dont_check -> Ok prog
  | Check { loc; delimiter } -> (
      let offset = flow_deli_offset delimiter in
      match check_flow_errors ~loc ~offset errors with
      | Some e -> Error (prog, e)
      | None -> Ok prog)

let parse_expression =
  let with_eof parser env =
    (* Makes the input parser expect EOF at the end.
       Use this to error on trailing junk when parsing non-Program nodes. *)
    let ast = parser env in
    Parser_env.Expect.token env T_EOF;
    ast
  in
  let parse = with_eof Parser_flow.Parse.expression in
  fun ~check_errors str -> parse_generic ~parser:parse ~check_errors str

let parse_program ~check_errors str =
  let parser = Parser_flow.Parse.program in
  parse_generic ~parser ~check_errors str
