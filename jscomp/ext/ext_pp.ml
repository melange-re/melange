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

module L = struct
  let space = " "
  let indent_str = "  "
end

let indent_length = String.length L.indent_str

type kind =
  | Channel of out_channel
  | Buffer of Buffer.t
type t = {
  kind : kind;
  mutable indent_level : int;
  mutable column : int;
  mutable line : int;
  mutable last_new_line : bool;
  (* only when we print newline, we print the indent *)
}

let output_string t s =
  (match t.kind with
  | Channel chan -> output_string chan s
  | Buffer buf -> Buffer.add_string buf s);
  let (new_line, new_column) =
    Ext_string.fold_left 
      (fun (line, column) char ->
          if char = '\n' then
            (line + 1, 0)
          else (line, column + 1))
      (t.line, t.column)
      s
  in
  t.line <- new_line;
  t.column <- new_column

let output_char t c =
  (match t.kind with
  | Channel chan -> output_char chan c
  | Buffer buf -> Buffer.add_char buf c);
  if c = '\n' then begin
    t.line <- t.line + 1;
    t.column <- 0
  end else
    t.column <- t.column + 1

let flush t =
  match t.kind with
  | Channel chan -> flush chan
  | Buffer _ -> ()

let from_channel chan = {
  kind = Channel chan;
  line = 0;
  column = 0;
  indent_level = 0;
  last_new_line = false;
}


let from_buffer buf = {
  kind = Buffer buf;
  line = 0;
  column = 0;
  indent_level = 0;
  last_new_line = false;
}

let string t s =
  output_string t s;
  t.last_new_line <- Ext_string.ends_with s "\n"

let newline t =
  if not t.last_new_line then (
    output_char t '\n';
    for _ = 0 to t.indent_level - 1 do
      output_string t L.indent_str;
    done;
    t.last_new_line <- true)

let at_least_two_lines t =
  if not t.last_new_line then output_char t '\n';
  output_char t '\n';
  for _ = 0 to t.indent_level - 1 do
    output_string t L.indent_str
  done;
  t.last_new_line <- true

let force_newline t =
  output_char t '\n';
  for _ = 0 to t.indent_level - 1 do
    output_string t L.indent_str;
  done;
  t.last_new_line <- true

let space t  =
  output_string t L.space

let nspace  t n  =
  output_string t (String.make n ' ')

let group t i action =
  if i = 0 then action ()
  else
    let old = t.indent_level in
    t.indent_level <- t.indent_level + i;
    Ext_pervasives.finally ~clean:(fun _ -> t.indent_level <- old) () action

let vgroup = group

let paren t action =
  string t "(";
  let v = action () in
  string t ")";
  v

let brace fmt u =
  string fmt "{";
  (* break1 fmt ; *)
  let v = u () in
  string fmt "}";
  v

let bracket fmt u =
  string fmt "[";
  let v = u () in
  string fmt "]";
  v

let brace_vgroup st n action =
  string st "{";
  let v =
    vgroup st n (fun _ ->
        newline st;
        let v = action () in
        v)
  in
  force_newline st;
  string st "}";
  v

let bracket_vgroup st n action =
  string st "[";
  let v =
    vgroup st n (fun _ ->
        newline st;
        let v = action () in
        v)
  in
  force_newline st;
  string st "]";
  v

let bracket_group st n action = group st n (fun _ -> bracket st action)

let paren_vgroup st n action =
  string st "(";
  let v =
    group st n (fun _ ->
        newline st;
        let v = action () in
        v)
  in
  newline st;
  string st ")";
  v

let paren_group st n action = group st n (fun _ -> paren st action)

let cond_paren_group st b n action =
  if b then paren_group st n action else action ()

let brace_group st n action = group st n (fun _ -> brace st action)

(* let indent t n =
   t.indent_level <- t.indent_level + n *)

let flush t () = flush t

let current_line t = t.line
let current_column t = t.column
