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

let basename = Filename.basename
let (//) = Ext_path.combine



let handle_generators buf
    (group : Bsb_file_groups.file_group)
    custom_rules =
  Ext_list.iter group.generators (fun {output; input; command} ->
      (* TODO: add a loc for better error message *)
      match Map_string.find_opt custom_rules command with
      | None -> Ext_fmt.failwithf ~loc:__LOC__ "custom rule %s used but  not defined" command
      | Some rule ->
        Bsb_ninja_targets.output_build group.dir buf
          ~outputs:output
          ~inputs:input
          ~rule)


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
    ?gentype_config
    ~per_proj_dir
    ~bs_dependencies
    ~bs_dev_dependencies
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
  let output_d_as_dep = Format.asprintf "(:dep_file %s)" (basename output_d) in
  let output_filename_sans_extension =
      Ext_namespace_encode.make ?ns:namespace filename_sans_extension
  in
  let output_cmi =  output_filename_sans_extension ^ Literals.suffix_cmi in
  let output_cmj =  output_filename_sans_extension ^ Literals.suffix_cmj in
  let maybe_gentype_deps = Option.map (fun _ ->
    let rel_sourcedirs_dir = Ext_path.rel_normalized_absolute_path
         ~from:(per_proj_dir // module_info.dir)
         (per_proj_dir // Bsb_config.lib_bs // Literals.sourcedirs_meta) in
    [rel_sourcedirs_dir]) gentype_config
  in
  let output_js =
    Bsb_package_specs.get_list_of_output_js package_specs output_filename_sans_extension in
  Bsb_ninja_targets.output_build cur_dir buf
    ~implicit_deps:(Option.value ~default:[] maybe_gentype_deps)
    ~outputs:[output_ast]
    ~inputs:[basename input_impl]
    ~rule:ast_rule;
  Bsb_ninja_targets.output_build
    cur_dir
    buf
    ~outputs:[output_d]
    ~inputs:(Ext_list.map (if has_intf_file then [output_ast;output_iast] else [output_ast] ) basename)
    ~rule:(if is_dev then rules.build_bin_deps_dev else rules.build_bin_deps)
  ;
  let relative_ns_cmi =
   match namespace with
   | Some ns ->
     [ (Ext_path.rel_normalized_absolute_path
       ~from:(per_proj_dir // cur_dir)
       (per_proj_dir // Bsb_config.lib_bs)) //
      (ns ^ Literals.suffix_cmi) ]
   | None -> []
   in
  let bs_dependencies = Ext_list.map bs_dependencies (fun dir ->
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
  let bs_dependencies = if is_dev then
    let dev_dependencies = Ext_list.map bs_dev_dependencies (fun dir ->
      (Ext_path.rel_normalized_absolute_path ~from:(per_proj_dir // cur_dir) dir) // Literals.bsb_world
      )
    in
    dev_dependencies @ bs_dependencies
  else
    bs_dependencies
  in
  if has_intf_file then begin
    Bsb_ninja_targets.output_build cur_dir buf
      ~outputs:[output_iast]
      (* TODO: we can get rid of absloute path if we fixed the location to be
          [lib/bs], better for testing?
      *)
      ~inputs:[basename input_intf]
      ~rule:ast_rule
    ;
    Bsb_ninja_targets.output_build cur_dir buf
      ~implicit_deps:[output_d_as_dep]
      ~outputs:[output_cmi]
      ~inputs:[basename output_iast]
      ~rule:(if is_dev then rules.mi_dev else rules.mi)
      ~bs_dependencies
      ~rel_deps:(rel_bs_config_json :: relative_ns_cmi)
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
  Bsb_ninja_targets.output_build cur_dir buf
    ~outputs:[output_cmj]
    ~implicit_outputs:
     (if has_intf_file then [] else [ output_cmi ])
    ~js_outputs:output_js
    ~inputs:[basename output_ast]
    ~implicit_deps:(if has_intf_file then [(basename output_cmi); output_d_as_dep] else [output_d_as_dep])
    ~bs_dependencies
    ~rel_deps:(rel_bs_config_json :: relative_ns_cmi)
    ~rule;
  output_js, output_d


let handle_files_per_dir
    buf
    ~(global_config: Bsb_ninja_global_vars.t)
    ~root_dir
    ~(rules : Bsb_ninja_rule.builtin)
    ~package_specs
    ~js_post_build_cmd
    ~files_to_install
    ~bs_dependencies
    ~bs_dev_dependencies
    (group: Bsb_file_groups.file_group )
  : unit =
  let per_proj_dir = global_config.src_root_dir in
  let rel_group_dir =
    Ext_path.rel_normalized_absolute_path ~from:root_dir (per_proj_dir // group.dir)
  in

  if not (Bsb_file_groups.is_empty group) then begin
    Buffer.add_string buf "(subdir ";
    Buffer.add_string buf rel_group_dir;
    Buffer.add_char buf '\n';
    let is_dev = group.is_dev in
    handle_generators buf group rules.customs ;
    let installable =
      match group.public with
      | Export_all -> fun _ -> true
      | Export_none -> fun _ -> false
      | Export_set set ->
        fun module_name ->
        Set_string.mem set module_name in
    let js_targets, _d_targets = Map_string.fold group.sources ([], []) (fun module_name module_info (acc_js, acc_d)  ->
        if installable module_name then
          Queue.add
            module_info files_to_install;
        let js_outputs, output_d = emit_module_build  rules
          package_specs
          is_dev
          buf
          ~per_proj_dir
          ~bs_dependencies
          ~bs_dev_dependencies
          ?gentype_config:global_config.gentypeconfig
          js_post_build_cmd
          global_config.namespace module_info
        in
        (List.map fst js_outputs :: acc_js, output_d :: acc_d)
    )
    in

    Bsb_ninja_targets.output_alias buf ~name:Literals.bsb_world ~deps:(List.concat js_targets);
    Buffer.add_string buf ")";
    Buffer.add_string buf "\n"

  end

    (* ;
    Bsb_ninja_targets.phony
    oc ~order_only_deps:[] ~inputs:[] ~output:group.dir *)

    (* pseuduo targets per directory *)
