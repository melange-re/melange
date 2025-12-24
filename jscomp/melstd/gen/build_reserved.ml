(* Copyright (C) 2019-Present Hongbo Zhang, Authors of ReScript
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

open Ppxlib_ast

let loc = Location.none

module SSet = Set.Make (String)

module Reserved_words = struct
  let reserved_words =
    [|
      (* keywork *)
      "break";
      "case";
      "catch";
      "continue";
      "debugger";
      "default";
      "delete";
      "do";
      "else";
      "finally";
      "for";
      "function";
      "if";
      (* "then";  *) "in";
      "instanceof";
      "new";
      "return";
      "switch";
      "this";
      "throw";
      "try";
      "typeof";
      "var";
      "void";
      "while";
      "with";
      (* reserved in ECMAScript 5 *)
      "class";
      "enum";
      "export";
      "extends";
      "import";
      "super";
      "implements";
      "interface";
      "let";
      "package";
      "private";
      "protected";
      "public";
      "static";
      "yield";
      (* other *)
      "null";
      "true";
      "false";
      "NaN";
      "undefined";
      "this";
      (* also reserved in ECMAScript 3 *)
      "abstract";
      "boolean";
      "byte";
      "char";
      "const";
      "double";
      "final";
      "float";
      "goto";
      "int";
      "long";
      "native";
      "short";
      "synchronized";
      (* "throws";  *)
      (* seems to be fine, like nodejs [assert.throws] *)
      "transient";
      "volatile";
      (* also reserved in ECMAScript 6 *)
      "await";
      "event";
      "location";
      "window";
      "document";
      "eval";
      "navigator";
      (* "self"; *)
      "Array";
      "Date";
      "Math";
      "JSON";
      "Object";
      "RegExp";
      "String";
      "Boolean";
      "Number";
      "Buffer";
      (* Node *)
      "Map";
      (* es6*)
      "Set";
      "Promise";
      "Infinity";
      "isFinite";
      "ActiveXObject";
      "XMLHttpRequest";
      "XDomainRequest";
      "DOMException";
      "Error";
      "SyntaxError";
      "arguments";
      "decodeURI";
      "decodeURIComponent";
      "encodeURI";
      "encodeURIComponent";
      "escape";
      "unescape";
      "fetch";
      "isNaN";
      "parseFloat";
      "parseInt";
      (* reserved for commonjs and NodeJS globals*)
      "require";
      "exports";
      "module";
      "clearImmediate";
      "clearInterval";
      "clearTimeout";
      "console";
      "global";
      "process";
      "require";
      "setImmediate";
      "setInterval";
      "setTimeout";
      "__dirname";
      "__filename";
      "__esModule";
      "Bun";
    |]

  let all_from_file =
    let get_predefined_words (fn : string) =
      let v = ref SSet.empty in
      let in_chan = open_in_bin fn in
      (try
         while true do
           let new_word = input_line in_chan in
           if String.length new_word <> 0 then v := SSet.add new_word !v
         done
       with End_of_file -> ());
      !v
    in

    let fill_extra (ss : SSet.t) : SSet.t =
      let v = ref ss in
      for i = 0 to Array.length reserved_words - 1 do
        v := SSet.add reserved_words.(i) !v
      done;
      !v
    in
    fun fn ->
      let ss = get_predefined_words fn in
      fill_extra ss
end

let binary_search =
  [%str
    type element = string

    let binarySearch =
      let rec binarySearchAux (arr : element array) (lo : int) (hi : int) key :
          bool =
        let mid = (lo + hi) / 2 in
        let midVal = Array.unsafe_get arr mid in
        (* let c = cmp key midVal [@u] in  *)
        if key = midVal then true
        else if key < midVal then
          (*  a[lo] =< key < a[mid] <= a[hi] *)
          if hi = mid then Array.unsafe_get arr lo = key
          else binarySearchAux arr lo mid key
        else if
          (*  a[lo] =< a[mid] < key <= a[hi] *)
          lo = mid
        then Array.unsafe_get arr hi = key
        else binarySearchAux arr mid hi key
      in
      fun (sorted : element array) (key : element) ->
        let len = Array.length sorted in
        if len = 0 then false
        else
          let lo = Array.unsafe_get sorted 0 in
          (* let c = cmp key lo [@u] in  *)
          if key < lo then false
          else
            let hi = Array.unsafe_get sorted (len - 1) in
            (* let c2 = cmp key hi [@u]in  *)
            if key > hi then false else binarySearchAux sorted 0 (len - 1) key

    let is_reserved s = binarySearch sorted_keywords s]

let write_ast oc ast =
  output_string oc Config.ast_impl_magic_number;
  output_value oc "reserved_keywords.ml";
  output_value oc (Ppxlib_ast.Selected_ast.To_ocaml.copy_structure ast)

let main keyword_file output_name =
  let ast =
    let keywords_array =
      let ss = Reserved_words.all_from_file keyword_file in
      let array =
        Ast_helper.(
          Exp.array
            (SSet.fold ss ~init:[] ~f:(fun s acc ->
                 Exp.constant (Const.string s) :: acc)
            |>
            (* Binary search expects an alphabetically ordered array. *)
            List.rev))
      in
      [%stri let sorted_keywords = [%e array]]
    in
    keywords_array :: binary_search
  in
  let oc = open_out_bin output_name in
  write_ast oc ast;
  close_out oc

(*
;;
for i = 0 to Array.length Sys.argv - 1  do
  print_endline ">"; print_string Sys.argv.(i)
done
;; *)
let () = main Sys.argv.(1) Sys.argv.(2)
