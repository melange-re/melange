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

let ( // ) = Ext_path.combine

let write_file name buf =
  let oc = open_out_bin name in
  Ext_buffer.output_buffer oc buf;
  close_out oc

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
  Ext_namespace_encode.make ?ns:namespace source ^ ext

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
let oc_deps ~deps (ast_file : string) (is_dev : bool) (db : Bsb_db_decode.t)
    (namespace : string option) (kind : [ `impl | `intf ]) : unit =
  let cur_module_name = Ext_filename.module_name ast_file in
  let s = extract_dep_raw_string ast_file in
  let offset = ref 1 in
  let size = String.length s in
  while !offset < size do
    let next_tab = String.index_from s !offset magic_sep_char in
    let dependent_module = String.sub s !offset (next_tab - !offset) in
    if dependent_module = cur_module_name then (
      prerr_endline ("FAILED: " ^ cur_module_name ^ " has a self cycle");
      exit 2);
    (match
       ( Bsb_db_decode.find db ~kind:`impl dependent_module is_dev,
         Bsb_db_decode.find db ~kind:`intf dependent_module is_dev )
     with
    | None, None -> ()
    | Some _, None | None, Some _ -> assert false
    | ( Some { dir_name = impl_dir_name; case },
        Some { dir_name = intf_dir_name; _ } ) ->
        let module_basename =
          if case then dependent_module
          else Ext_string.uncapitalize_ascii dependent_module
        in
        if kind = `impl then
          deps :=
            Set_string.add !deps
              (encode_cm_file ?namespace ~ext:Literals.suffix_cmj
                 (impl_dir_name // module_basename));
        (* #3260 cmj changes does not imply cmi change anymore *)
        deps :=
          Set_string.add !deps
            (encode_cm_file ?namespace ~ext:Literals.suffix_cmi
               (intf_dir_name // module_basename)));
    offset := next_tab + 1
  done

let process_deps_for_dune ~proj_dir ~cur_dir deps =
  let rel_deps =
    Ext_list.map deps (fun dep ->
        Ext_path.rel_normalized_absolute_path ~from:(proj_dir // cur_dir)
          (proj_dir // dep))
  in
  String.concat " " rel_deps

let emit_d ~package_name ~root_dir ~cur_dir ~proj_dir ~(is_dev : bool)
    (namespace : string option) (mlast : string) (mliast : string) =
  let rel_artifacts_dir =
    Mel_workspace.rel_artifacts_dir ~package_name ~root_dir ~proj_dir cur_dir
  in
  let data = Bsb_db_decode.read_build_cache ~dir:rel_artifacts_dir in
  let deps = ref Set_string.empty in
  let filename = Ext_filename.new_extension mlast Literals.suffix_d in
  oc_deps ~deps mlast is_dev data namespace `impl;
  if mliast <> "" then oc_deps ~deps mliast is_dev data namespace `intf;
  let deps = Set_string.elements !deps in
  let buf = Ext_buffer.create 2048 in
  Ext_buffer.add_string buf "(";
  let deps = process_deps_for_dune ~proj_dir ~cur_dir deps in
  Ext_buffer.add_string buf deps;
  Ext_buffer.add_string buf ")";
  write_file filename buf
