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

let default_export = L.default
let esModule = ("__esModule", "true")
(* Exports printer *)

let rev_iter_inter lst f inter =
  match lst with
  | [] -> ()
  | [ a ] -> f a
  | a :: rest ->
      List.rev_iter rest ~f:(fun x ->
          f x;
          inter ());
      f a

let accumulate_exports ~es6 =
 fun (cxt, acc) id ->
  let id_name = Ident.name id in
  let s = Ident.convert id_name in
  let str, cxt = Js_pp.Scope.str_of_ident cxt id in
  let exports =
    if id_name = default_export then
      (if es6 then [ esModule ] else []) @ ((default_export, str) :: acc)
    else (s, str) :: acc
  in
  (cxt, exports)

(* Print exports in CommonJS format *)
let module_exports =
  let accumulate_exports = accumulate_exports ~es6:false in
  fun cxt f (idents : Ident.t list) ->
    match idents with
    | [] -> cxt
    | idents ->
        let outer_cxt, reversed_list =
          List.fold_left ~f:accumulate_exports ~init:(cxt, []) idents
        in
        P.at_least_two_lines f;
        P.string f L.module_;
        P.string f L.dot;
        P.string f L.exports;
        P.space f;
        P.string f L.eq;
        P.space f;
        P.brace_vgroup f 1 (fun _ ->
            rev_iter_inter reversed_list
              (fun (s, export) ->
                P.group f 0 (fun _ ->
                    P.string f export;
                    if not @@ String.equal export s then (
                      P.space f;
                      P.string f L.as_;
                      P.space f;
                      P.string f s);
                    P.string f L.comma))
              (fun _ -> P.newline f));
        outer_cxt

(** Print module in ES6 format, it is ES6, trailing comma is valid ES6 code *)
let es6_export =
  let accumulate_exports = accumulate_exports ~es6:true in
  fun cxt f (idents : Ident.t list) ->
    match idents with
    | [] -> cxt
    | idents ->
        let outer_cxt, reversed_list =
          List.fold_left ~f:accumulate_exports ~init:(cxt, []) idents
        in
        P.at_least_two_lines f;
        P.string f L.export;
        P.space f;
        P.brace_vgroup f 1 (fun _ ->
            rev_iter_inter reversed_list
              (fun (s, export) ->
                P.group f 0 (fun _ ->
                    P.string f export;
                    if not @@ String.equal export s then (
                      P.space f;
                      P.string f L.as_;
                      P.space f;
                      P.string f s);
                    P.string f L.comma))
              (fun _ -> P.newline f));
        outer_cxt

type module_ = { id : Ident.t; path : string; default : bool }

(** Node style imports *)
let requires cxt f modules =
  (* the context used to print the following program *)
  let outer_cxt, reversed_list =
    List.fold_left
      ~f:(fun (cxt, acc) { id; path; default } ->
        let str, cxt = Js_pp.Scope.str_of_ident cxt id in
        (cxt, (str, path, default) :: acc))
      ~init:(cxt, []) modules
  in
  P.at_least_two_lines f;
  List.rev_iter reversed_list ~f:(fun (s, file, default) ->
      P.string f L.const;
      P.space f;
      P.string f s;
      P.space f;
      P.string f L.eq;
      P.space f;
      P.string f L.require;
      P.paren_group f 0 (fun _ -> Js_dump_string.pp_string f file);
      if default then (
        P.string f L.dot;
        P.string f L.default);
      P.string f L.semi;
      P.newline f);
  outer_cxt

(** ES6 module style imports *)
let imports cxt f modules =
  (* the context used to print the following program *)
  let outer_cxt, reversed_list =
    List.fold_left
      ~f:(fun (cxt, acc) { id; path; default } ->
        let str, cxt = Js_pp.Scope.str_of_ident cxt id in
        (cxt, (str, path, default) :: acc))
      ~init:(cxt, []) modules
  in
  P.at_least_two_lines f;
  List.rev_iter reversed_list ~f:(fun (s, file, default) ->
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
      P.newline f);
  outer_cxt
