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

(* [@@@warning "-37"] *)
type t = (* | File of string  *)
  | Dir of string [@@unboxed]

let cwd = lazy (Sys.getcwd ())
let path_sep = if Sys.win32 then ';' else ':'

let split_by_sep_per_os : string -> string list =
  if Sys.win32 || Sys.cygwin then fun x ->
    (* on Windows, we can still accept -bs-package-output lib/js *)
    Ext_string.split_by
      (fun x -> match x with '/' | '\\' -> true | _ -> false)
      x
  else fun x -> Ext_string.split x '/'

(** Used when produce node compatible paths *)
let node_sep = "/"

let node_parent = ".."
let node_current = "."

(** example
    {[
      "/bb/mbigc/mbig2899/bgit/bucklescript/jscomp/stdlib/external/pervasives.cmj"
        "/bb/mbigc/mbig2899/bgit/bucklescript/jscomp/stdlib/ocaml_array.ml"
    ]}

    The other way
    {[

      "/bb/mbigc/mbig2899/bgit/bucklescript/jscomp/stdlib/ocaml_array.ml"
        "/bb/mbigc/mbig2899/bgit/bucklescript/jscomp/stdlib/external/pervasives.cmj"
    ]}
    {[
      "/bb/mbigc/mbig2899/bgit/bucklescript/jscomp/stdlib//ocaml_array.ml"
    ]}
    {[
      /a/b
      /c/d
    ]}
*)
let node_relative_path ~from:(file_or_dir_2 : t) (file_or_dir_1 : t) =
  let relevant_dir1 =
    match file_or_dir_1 with Dir x -> x
    (* | File file1 ->  Filename.dirname file1 *)
  in
  let relevant_dir2 =
    match file_or_dir_2 with Dir x -> x
    (* | File file2 -> Filename.dirname file2  *)
  in
  let dir1 = split_by_sep_per_os relevant_dir1 in
  let dir2 = split_by_sep_per_os relevant_dir2 in
  let rec go (dir1 : string list) (dir2 : string list) =
    match (dir1, dir2) with
    | "." :: xs, ys -> go xs ys
    | xs, "." :: ys -> go xs ys
    | x :: xs, y :: ys when x = y -> go xs ys
    | _, _ -> List.map (fun _ -> node_parent) dir2 @ dir1
  in
  match go dir1 dir2 with
  | x :: _ as ys when x = node_parent -> String.concat node_sep ys
  | ys -> String.concat node_sep @@ (node_current :: ys)

let node_concat ~dir base = dir ^ node_sep ^ base

let node_rebase_file ~from ~to_ file =
  node_concat
    ~dir:
      (if from = to_ then node_current
       else node_relative_path ~from:(Dir from) (Dir to_))
    file

let strip_trailing_slashes p =
  let len = String.length p in
  if String.unsafe_get p (len - 1) == '/' && len > 1 then (
    let idx = ref 0 in
    while String.unsafe_get p (len - 1 - !idx) == '/' && len - 1 - !idx > 0 do
      incr idx
    done;
    Bytes.(unsafe_to_string (sub (unsafe_of_string p) 0 (len - !idx))))
  else p

let concat dirname filename =
  if String.length filename = 0 then dirname
  else if strip_trailing_slashes filename = Filename.current_dir_name then
    dirname
  else if strip_trailing_slashes dirname = Filename.current_dir_name then
    filename
  else if strip_trailing_slashes filename = Filename.current_dir_name then
    filename
  else Filename.concat dirname filename

(***
   {[
     Filename.concat "." "";;
     "./"
   ]}
*)
let combine path1 path2 =
  if Filename.is_relative path2 then concat path1 path2 else path2

let ( // ) = concat

(**
   {[
     split_aux "//ghosg//ghsogh/";;
     - : string * string list = ("/", ["ghosg"; "ghsogh"])
   ]}
   Note that
   {[
     Filename.dirname "/a/" = "/"
       Filename.dirname "/a/b/" = Filename.dirname "/a/b" = "/a"
   ]}
   Special case:
   {[
     basename "//" = "/"
       basename "///"  = "/"
   ]}
   {[
     basename "" =  "."
       basename "" = "."
       dirname "" = "."
       dirname "" =  "."
   ]}
*)
let split_aux p =
  let rec go p acc =
    let dir = Filename.dirname p in
    if dir = p then (dir, acc)
    else
      let new_path = Filename.basename p in
      if String.equal new_path Filename.dir_sep then go dir acc
        (* We could do more path simplification here
           leave to [rel_normalized_absolute_path]
        *)
      else go dir (new_path :: acc)
  in

  go p []

(**
   TODO: optimization
   if [from] and [to] resolve to the same path, a zero-length string is returned

   This function is useed in [es6-global] and
   [amdjs-global] format and tailored for `rollup`
*)
let curd = Filename.current_dir_name

let pard = Filename.parent_dir_name

let rel_normalized_absolute_path ~from to_ =
  let merge_parent_segment acc segment =
    if segment = curd then acc else acc // pard
  in
  let root1, paths1 = split_aux from in
  let root2, paths2 = split_aux to_ in
  if root1 <> root2 then root2
  else
    let rec go xss yss =
      match (xss, yss) with
      | x :: xs, y :: ys ->
          if String.equal x y then go xs ys
          else if x = curd then go xs yss
          else if y = curd then go xss ys
          else
            let start = List.fold_left merge_parent_segment pard xs in
            List.fold_left (fun acc v -> acc // v) start yss
      | [], [] -> String.empty
      | [], y :: ys -> List.fold_left (fun acc x -> acc // x) y ys
      | x :: xs, [] ->
          let start = if x = curd then "" else pard in
          List.fold_left merge_parent_segment start xs
    in
    let v = go paths1 paths2 in

    if String.length v = 0 then node_current
    else if
      v = curd || v = pard
      || String.starts_with v ~prefix:(curd ^ Filename.dir_sep)
      || String.starts_with v ~prefix:(pard ^ Filename.dir_sep)
    then v
    else if Filename.is_relative from then (curd ^ Filename.dir_sep) ^ v
    else v

(*TODO: could be hgighly optimized later
  {[
    normalize_absolute_path "/gsho/./..";;

    normalize_absolute_path "/a/b/../c../d/e/f";;

    normalize_absolute_path "/gsho/./..";;

    normalize_absolute_path "/gsho/./../..";;

    normalize_absolute_path "/a/b/c/d";;

    normalize_absolute_path "/a/b/c/d/";;

    normalize_absolute_path "/a/";;

    normalize_absolute_path "/a";;
  ]}
*)

(** See tests in {!Ounit_path_tests} *)
let normalize_absolute_path x =
  let drop_if_exist xs = match xs with [] -> [] | _ :: xs -> xs in
  let rec normalize_list acc paths =
    match paths with
    | [] -> acc
    | x :: xs ->
        if String.equal x curd then normalize_list acc xs
        else if String.equal x pard then normalize_list (drop_if_exist acc) xs
        else normalize_list (x :: acc) xs
  in
  let root, paths = split_aux x in
  let rev_paths = normalize_list [] paths in
  let rec go acc rev_paths =
    match rev_paths with
    | [] -> Filename.concat root acc
    | last :: rest -> go (Filename.concat last acc) rest
  in
  match rev_paths with [] -> root | last :: rest -> go last rest

let absolute_path cwd s =
  let process s =
    let s = if Filename.is_relative s then Lazy.force cwd // s else s in
    (* Now simplify . and .. components *)
    let rec aux s =
      let base, dir = (Filename.basename s, Filename.dirname s) in
      if dir = s then dir
      else if base = Filename.current_dir_name then aux dir
      else if base = Filename.parent_dir_name then Filename.dirname (aux dir)
      else aux dir // base
    in
    aux s
  in
  process s

let absolute_cwd_path s = absolute_path cwd s
