(* Copyright (C) 2017 Authors of BuckleScript
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

let (//) = Ext_path.combine






let handle_generators oc
    (group : Bsb_file_groups.file_group)
    custom_rules =
  let map_to_source_dir =
    (fun x -> Bsb_config.proj_rel (group.dir //x )) in
  Ext_list.iter group.generators (fun {output; input; command} ->
      (*TODO: add a loc for better error message *)
      match Map_string.find_opt custom_rules command with
      | None -> Ext_fmt.failwithf ~loc:__LOC__ "custom rule %s used but  not defined" command
      | Some rule ->
        Bsb_ninja_targets.output_build group.dir oc
          ~outputs:(Ext_list.map  output  map_to_source_dir)
          ~inputs:(Ext_list.map input map_to_source_dir)
          ~rule
    )




type suffixes = {
  impl : string;
  intf : string
}

let re_suffixes = {
  impl  = Literals.suffix_re;
  intf = Literals.suffix_rei;
}

let ml_suffixes = {
  impl = Literals.suffix_ml;
  intf = Literals.suffix_mli;
}
let res_suffixes = {
  impl = Literals.suffix_res;
  intf = Literals.suffix_resi;
}

let emit_module_build
    (rules : Bsb_ninja_rule.builtin)
    (package_specs : Bsb_package_specs.t)
    (is_dev : bool)
    buf
    ~per_proj_dir
    ~bs_dependencies_deps
    js_post_build_cmd
    namespace
    (module_info : Bsb_db.module_info)
  =
  let cur_dir = module_info.dir in
  let has_intf_file = module_info.info = Impl_intf in
  let config, ast_rule  =
    match module_info.syntax_kind with
    | Reason -> re_suffixes, rules.build_ast_from_re
    | Ml -> ml_suffixes, rules.build_ast
    | Res -> res_suffixes, rules.build_ast_from_re (* FIXME: better names *)
  in
  let filename_sans_extension = module_info.name_sans_extension in
  let input_impl = Bsb_config.proj_rel (filename_sans_extension ^ config.impl ) in
  let input_intf = Bsb_config.proj_rel (filename_sans_extension ^ config.intf) in
  let output_ast = filename_sans_extension  ^ Literals.suffix_ast in
  let output_iast = filename_sans_extension  ^ Literals.suffix_iast in
  let output_d = filename_sans_extension ^ Literals.suffix_d in
  let output_depends = filename_sans_extension ^ Literals.suffix_depends in
  let output_filename_sans_extension =
      Ext_namespace_encode.make ?ns:namespace filename_sans_extension
  in
  let output_cmi =  output_filename_sans_extension ^ Literals.suffix_cmi in
  let output_cmj =  output_filename_sans_extension ^ Literals.suffix_cmj in
  let output_js =
    Bsb_package_specs.get_list_of_output_js package_specs output_filename_sans_extension in
  Bsb_ninja_targets.output_build cur_dir buf
    ~outputs:[output_ast]
    ~inputs:[input_impl]
    ~rule:ast_rule;
  Bsb_ninja_targets.output_build
    cur_dir
    buf
    ~outputs:[output_d]
    ~inputs:(if has_intf_file then [output_ast;output_iast] else [output_ast] )
    ~rule:(if is_dev then rules.build_bin_deps_dev else rules.build_bin_deps)
  ;
  if has_intf_file then begin
    Bsb_ninja_targets.output_build cur_dir buf
      ~outputs:[output_iast]
      (* TODO: we can get rid of absloute path if we fixed the location to be
          [lib/bs], better for testing?
      *)
      ~inputs:[input_intf]
      ~rule:ast_rule
    ;
    Bsb_ninja_targets.output_build cur_dir buf
      ~outputs:[output_cmi]
      ~order_only_deps:[output_depends]
      ~inputs:[output_iast]
      ~rule:(if is_dev then rules.mi_dev else rules.mi)
    ;
  end;

  let rule =
    if has_intf_file then
      (if  is_dev then rules.mj_dev
       else rules.mj)
    else
      (if is_dev then rules.mij_dev
       else rules.mij
      )
  in
  let relative_ns_cmi =
   match namespace with
   | Some ns ->
     [ (Ext_path.rel_normalized_absolute_path
       ~from:(per_proj_dir // cur_dir)
       (per_proj_dir // Bsb_config.lib_bs)) //
      (ns ^ Literals.suffix_cmi) ]
   | None -> []
   in
  let bs_dependencies_deps = Ext_list.map bs_dependencies_deps (fun dir ->
     (Ext_path.rel_normalized_absolute_path ~from:(per_proj_dir // cur_dir) dir) // Literals.bsb_world
  )
  in
  let rel_bs_config_json =
   Ext_path.combine
    (Ext_path.rel_normalized_absolute_path
       ~from:(Ext_path.combine per_proj_dir module_info.dir)
       per_proj_dir)
    Literals.bsconfig_json
  in
  Bsb_ninja_targets.output_build cur_dir buf
    ~outputs:
      (if has_intf_file then [output_cmj] else [output_cmj;output_cmi])
    ~implicit_outputs:
     (if has_intf_file then [] else [ output_cmi ])
    ~js_outputs:output_js
    ~inputs:(if has_intf_file then [output_ast; output_cmi] else [output_ast])
    ~implicit_deps:(if has_intf_file then [output_cmi] else [])
    ~bs_dependencies_deps
    ~rel_deps:(rel_bs_config_json :: relative_ns_cmi)
    ~order_only_deps:[output_depends]
    ~rule;
  output_js, output_d
  (* ;
  {output_cmj; output_cmi} *)


let handle_files_per_dir
    ~(global_config: Bsb_ninja_global_vars.t)
    ~digest
    ~(rules : Bsb_ninja_rule.builtin)
    ~package_specs
    ~js_post_build_cmd
    ~files_to_install
    ~bs_dependencies_deps
    (group: Bsb_file_groups.file_group )
  : unit =

  (* handle_generators oc group rules.customs ; *)
  let installable =
    match group.public with
    | Export_all -> fun _ -> true
    | Export_none -> fun _ -> false
    | Export_set set ->
      fun module_name ->
      Set_string.mem set module_name in
  let group_dir = global_config.src_root_dir // group.dir in
  let dune_bsb_inc = group_dir // Literals.dune_bsb_inc in
  if not (Sys.file_exists dune_bsb_inc) then begin
    let buf = Buffer.create 128 in
    (* Empty buffer, populated by dune. *)
    Bsb_ninja_targets.revise_dune dune_bsb_inc buf;
  end;
  let dune_bsb = group_dir // Literals.dune_bsb in
  let buf = Buffer.create 1024 in
  Buffer.add_char buf '\n';
  Buffer.add_string buf "(include ";
  Buffer.add_string buf Literals.dune_bsb_inc;
  Buffer.add_string buf ")\n";
  let js_targets, d_targets = Map_string.fold group.sources ([], []) (fun module_name module_info (acc_js, acc_d)  ->
      if installable module_name then
        Queue.add
          module_info files_to_install;
      let js_outputs, output_d = emit_module_build  rules
        package_specs
        group.dev_index
        buf
        ~per_proj_dir:global_config.src_root_dir
        ~bs_dependencies_deps
        js_post_build_cmd
        global_config.namespace module_info
      in
      (js_outputs :: acc_js, output_d :: acc_d)
  )
  in
  Bsb_ninja_targets.output_dune_bsb_inc buf ~digest ~bs_dep_parse:global_config.bs_dep_parse ~deps:d_targets;
  Bsb_ninja_targets.output_alias buf ~name:Literals.bsb_world ~deps:(List.concat js_targets);
  Bsb_ninja_targets.output_alias buf ~name:Literals.bsb_depends ~deps:[dune_bsb_inc];
  Bsb_ninja_targets.revise_dune dune_bsb buf;

  let buf = Buffer.create 128 in
  Buffer.add_string buf "\n(include ";
  Buffer.add_string buf Literals.dune_bsb;
  Buffer.add_string buf ")\n";
  Bsb_ninja_targets.revise_dune (group_dir // Literals.dune) buf

    (* ;
    Bsb_ninja_targets.phony
    oc ~order_only_deps:[] ~inputs:[] ~output:group.dir *)

    (* pseuduo targets per directory *)
