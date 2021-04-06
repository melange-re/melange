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

module D = Dune_action_plugin.V1
module P = D.Path
module Glob = Dune_glob.V1

open D.O

let (//) = Ext_path.combine

let lib_bs = Literals.melange_eobjs_dir

(* return an non-decoded string *)
let extract_dep_raw_string (fn : string) : string =
  let ic = open_in_bin fn in
  let size = input_binary_int ic in
  let s = really_input_string ic size in
  close_in ic;
  s

(* Make sure it is the same as {!Binary_ast.magic_sep_char}*)
let magic_sep_char = '\n'

let encode_cm_file ~ext ?namespace source =
  (Ext_namespace_encode.make ?ns:namespace source) ^ ext

(* For cases with self cycle
    e.g, in b.ml
    {[
      include B
    ]}
    When ns is not turned on, it makes sense that b may come from third party package.
    Hoever, this case is wont supported.
    It complicates when it has interface file or not.
    - if it has interface file, the current interface will have priority, failed to build?
    - if it does not have interface file, the build will not open this module at all(-bs-read-cmi)

    When ns is turned on, `B` is interprted as `Ns-B` which is a cyclic dependency,
    it can be errored out earlier
*)
let oc_deps
    ~deps
    (ast_file : string)
    ~(namespace : string option)
    ~(kind : [`impl | `intf ])
    : unit
  =
  let cur_module_name = Ext_filename.module_name ast_file  in
  Ext_option.iter namespace (fun ns ->
    (* always cmi *)
    deps := Set_string.add !deps (lib_bs // (ns ^ Literals.suffix_cmi)));
  let s = extract_dep_raw_string ast_file in
  let offset = ref 1 in
  let size = String.length s in
  while !offset < size do
    let next_tab = String.index_from s !offset magic_sep_char in
    let dependent_module = String.sub s !offset (next_tab - !offset) in
    (if dependent_module = cur_module_name then
      begin
        prerr_endline ("FAILED: " ^ cur_module_name ^ " has a self cycle");
        exit 2
      end
    );
    begin
      if kind = `impl then begin
        deps :=
          Set_string.add !deps
            (encode_cm_file
              ?namespace
              ~ext:Literals.suffix_cmj
              dependent_module);
      end;
      (* #3260 cmj changes does not imply cmi change anymore *)
      deps :=
        Set_string.add !deps
          (encode_cm_file
            ?namespace
            ~ext:Literals.suffix_cmi
            dependent_module);
    end;
    offset := next_tab + 1
  done

let multi_file_glob files =
  let pp_list =
    Format.(pp_print_list ~pp_sep:(fun fmt () -> fprintf fmt ",") pp_print_string)
  in
  Glob.of_string (Format.asprintf "{%a}" pp_list files)

let process_deps ~root:_ ~cwd:_ ~dirs ~deps =
  let basenames = List.concat_map (fun dep -> [dep; String.uncapitalize_ascii dep]) deps in
  Ext_list.filter_map dirs (fun dir ->
    (* https://github.com/ocaml/dune/issues/4445 *)
    match Sys.file_exists dir with
    | false -> None
    | true ->
      let p =
        let+ (_: string list) =
          D.read_directory_with_glob
            ~path:(P.of_string dir)
            ~glob:(multi_file_glob basenames)
        in ()
      in
      Some p)

let ignore_both a b =
  D.map ~f:(fun (_, _) -> ()) (D.both a b)

let realize ~rules =
  List.fold_left ignore_both (D.return ()) rules

let run_dependency_rules ~root ~cwd ~dirs ~deps =
  let rules= process_deps ~root ~cwd ~dirs ~deps in
  let rule = realize ~rules in
  D.run rule

let compute_dependency_info
  ~root
  ~cwd
  ~dirs
  (namespace : string option) (mlast : string) (mliast : string) =
  let deps = ref Set_string.empty in
  oc_deps
    ~deps
    mlast
    ~namespace
    ~kind:`impl
    ;
  if mliast <> "" then begin
    oc_deps
      ~deps
      mliast
      ~namespace
      ~kind:`intf
  end;
  let deps = Set_string.elements !deps in
  run_dependency_rules ~root ~cwd ~dirs ~deps

