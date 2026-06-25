(* Copyright (C) 2017 Hongbo Zhang, Authors of ReScript
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
module P = Js_pp
module L = Js_dump_lit

(* Exports printer *)

let print_commonjs_export f s export =
  P.group f 0 (fun () ->
      if not @@ String.equal export s then (
        P.string f s;
        P.string f L.colon;
        P.space f);
      P.string f export;
      P.string f L.comma)

let print_es6_export f s export =
  P.group f 0 (fun () ->
      P.string f export;
      if not @@ String.equal export s then (
        P.space f;
        P.string f L.as_;
        P.space f;
        P.string f s);
      P.string f L.comma)

let export_name cxt id =
  let id_name = Ident.name id in
  let s = Ident.convert id_name in
  let export, cxt = Js_pp.Scope.str_of_ident cxt id in
  let is_default = id_name = L.default in
  let s = if is_default then L.default else s in
  (s, export, is_default, cxt)

let iter_exports cxt f idents ~add_esmodule ~print_export =
  let first = ref true in
  let print_one s export =
    if !first then first := false else P.newline f;
    print_export f s export
  in
  List.fold_left idents ~init:cxt ~f:(fun cxt id ->
      let s, export, is_default, cxt = export_name cxt id in
      print_one s export;
      if add_esmodule && is_default then (
        P.newline f;
        print_export f "__esModule" "true");
      cxt)

(* Print exports in CommonJS format *)
let module_exports cxt f (idents : Ident.t list) =
  match idents with
  | [] -> cxt
  | idents ->
      P.at_least_two_lines f;
      P.string f L.module_;
      P.string f L.dot;
      P.string f L.exports;
      P.space f;
      P.string f L.eq;
      P.space f;
      P.brace_vgroup f 1 (fun () ->
          iter_exports cxt f idents ~add_esmodule:true
            ~print_export:print_commonjs_export)

(** Print module in ES6 format, it is ES6, trailing comma is valid ES6 code *)
let es6_export cxt f (idents : Ident.t list) =
  match idents with
  | [] -> cxt
  | idents ->
      P.at_least_two_lines f;
      P.string f L.export;
      P.space f;
      P.brace_vgroup f 1 (fun () ->
          iter_exports cxt f idents ~add_esmodule:false
            ~print_export:print_es6_export)

type module_ = { id : Ident.t; path : string; default : bool }

(** Node style imports *)
let requires cxt f modules =
  P.at_least_two_lines f;
  List.fold_left modules ~init:cxt ~f:(fun cxt { id; path = file; default } ->
      let s, cxt = Js_pp.Scope.str_of_ident cxt id in
      P.string f L.const;
      P.space f;
      P.string f s;
      P.space f;
      P.string f L.eq;
      P.space f;
      P.string f L.require;
      P.paren_group f 0 (fun () -> Js_dump_string.pp_string f file);
      if default then (
        P.string f L.dot;
        P.string f L.default);
      P.string f L.semi;
      P.newline f;
      cxt)

(** ES6 module style imports *)
let imports cxt f modules =
  P.at_least_two_lines f;
  List.fold_left modules ~init:cxt ~f:(fun cxt { id; path = file; default } ->
      let s, cxt = Js_pp.Scope.str_of_ident cxt id in
      P.string f L.import;
      P.space f;
      if default then (
        P.string f s;
        P.space f;
        P.string f L.from;
        P.space f;
        Js_dump_string.pp_string f file)
      else (
        P.string f L.star;
        P.space f;
        (* import * as xx from 'xx'*)
        P.string f L.as_;
        P.space f;
        P.string f s;
        P.space f;
        P.string f L.from;
        P.space f;
        Js_dump_string.pp_string f file);
      P.string f L.semi;
      P.newline f;
      cxt)
