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

let indent_length = Stdlib.String.length L.indent_str

type kind = Channel of out_channel | Buffer of Buffer.t

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
  let new_line, new_column =
    Stdlib.String.fold_left
      (fun (line, column) char ->
        match char with '\n' -> (line + 1, 0) | _c -> (line, column + 1))
      (t.line, t.column) s
  in
  t.line <- new_line;
  t.column <- new_column

let output_char t c =
  (match t.kind with
  | Channel chan -> output_char chan c
  | Buffer buf -> Buffer.add_char buf c);
  if c = '\n' then (
    t.line <- t.line + 1;
    t.column <- 0)
  else t.column <- t.column + 1

let flush t = match t.kind with Channel chan -> flush chan | Buffer _ -> ()

let from_channel chan =
  {
    kind = Channel chan;
    line = 0;
    column = 0;
    indent_level = 0;
    last_new_line = false;
  }

let from_buffer buf =
  {
    kind = Buffer buf;
    line = 0;
    column = 0;
    indent_level = 0;
    last_new_line = false;
  }

let string =
  let ends_with_char s c =
    match Stdlib.String.length s with
    | 0 -> false
    | len -> Stdlib.String.unsafe_get s (len - 1) = c
  in
  fun t s ->
    output_string t s;
    t.last_new_line <- ends_with_char s '\n'

let newline t =
  if not t.last_new_line then (
    output_char t '\n';
    for _ = 0 to t.indent_level - 1 do
      output_string t L.indent_str
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
    output_string t L.indent_str
  done;
  t.last_new_line <- true

let space t = output_string t L.space
let nspace t n = output_string t (Stdlib.String.make n ' ')

let group t i action =
  if i = 0 then action ()
  else
    let old = t.indent_level in
    t.indent_level <- t.indent_level + i;
    Fun.protect ~finally:(fun () -> t.indent_level <- old) (fun () -> action ())

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

module Scope = struct
  type t = int Map_int.t Map_string.t

  (* -- "name" --> int map -- stamp --> index suffix *)
  let empty : t = Map_string.empty

  let rec print fmt v =
    Format.fprintf fmt "@[<v>{";
    Map_string.iter v (fun k m ->
        Format.fprintf fmt "%s: @[%a@],@ " k print_int_map m);
    Format.fprintf fmt "}@]"

  and print_int_map fmt m =
    Map_int.iter m (fun k v -> Format.fprintf fmt "%d - %d" k v)

  let add_ident ~mangled:name (stamp : int) (cxt : t) : int * t =
    match Map_string.find_opt cxt name with
    | None -> (0, Map_string.add cxt name (Map_int.add Map_int.empty stamp 0))
    | Some imap -> (
        match Map_int.find_opt imap stamp with
        | None ->
            let v = Map_int.cardinal imap in
            (v, Map_string.add cxt name (Map_int.add imap stamp v))
        | Some i -> (i, cxt))

  (*
   same as {!Js_dump.ident} except it generates a string instead of doing the printing
   For fast/debug mode, we can generate the name as
       [Printf.sprintf "%s$%d" name id.stamp] which is
       not relevant to the context

   Attention:
   - $$Array.length, due to the fact that global module is
       always printed in the begining(via imports), so you get a gurantee,
       (global modules will not be printed as [List$1])

       However, this means we loose the ability of dynamic loading, is it a big
       deal? we can fix this by a scanning first, since we already know which
       modules are global

       check [test/test_global_print.ml] for regression
   - collision
      It is obvious that for the same identifier that they
      print the same name.

      It also needs to be hold that for two different identifiers,
      they print different names:
      - This happens when they escape to the same name and
        share the  same stamp
      So the key has to be mangled name  + stamp
      otherwise, if two identifier happens to have same mangled name,
      if we use the original name as key, they can have same id (like 0).
      then it caused a collision

      Here we can guarantee that if mangled name and stamp are not all the same
      they can not have a collision *)
  let str_of_ident (cxt : t) (id : Ident.t) : string * t =
    if Mel_ident.is_js id then
      (* reserved by compiler *)
      (Ident.name id, cxt)
    else
      let id_name = Ident.name id in
      let name = Mel_ident.convert id_name in
      let i, new_cxt = add_ident ~mangled:name (Mel_ident.stamp id) cxt in
      ((if i == 0 then name else Printf.sprintf "%s$%d" name i), new_cxt)

  let ident (cxt : t) f (id : Ident.t) : t =
    let str, cxt = str_of_ident cxt id in
    string f str;
    cxt

  let merge (cxt : t) (set : Set_ident.t) =
    Set_ident.fold set cxt (fun ident acc ->
        snd
          (add_ident
             ~mangled:(Mel_ident.convert (Ident.name ident))
             (Mel_ident.stamp ident) acc))

  (* Assume that all idents are already in [scope]
     so both [param/0] and [param/1] are in idents, we don't need
     update twice,  once is enough *)
  let sub_scope (scope : t) (idents : Set_ident.t) : t =
    Set_ident.fold idents empty (fun id acc ->
        let name = Ident.name id in
        let mangled = Mel_ident.convert name in
        match Map_string.find_exn scope mangled with
        | exception Not_found -> assert false
        | imap ->
            if Map_string.mem acc mangled then acc
            else Map_string.add acc mangled imap)
end
