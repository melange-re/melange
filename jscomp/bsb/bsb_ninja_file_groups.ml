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
let ( // ) = Ext_path.combine

let rel_dependencies_alias ~root_dir ~proj_dir ~cur_dir deps =
  Ext_list.flat_map deps
    (fun ({ package_install_dirs; _ } : Bsb_config_types.dependency) ->
      Ext_list.filter_map package_install_dirs
        (fun { Bsb_config_types.package_path; package_name; dir } ->
          if Ext_string.starts_with dir Literals.melange_eobjs_dir then
            (* We don't emit the `mel` alias for the artifacts directory *)
            None
          else
            let virtual_package_dir =
              Mel_workspace.virtual_proj_dir ~root_dir ~package_dir:package_path
                ~package_name
            in
            let rel_dir =
              Ext_path.rel_normalized_absolute_path ~from:(proj_dir // cur_dir)
                (virtual_package_dir // dir)
            in
            Some (rel_dir // Literals.mel_dune_alias)))

let handle_generators buf (group : Bsb_file_groups.file_group) custom_rules =
  Ext_list.iter group.generators (fun { output; input; command } ->
      (* TODO: add a loc for better error message *)
      match Map_string.find_opt custom_rules command with
      | None ->
          Ext_fmt.failwithf ~loc:__LOC__ "custom rule %s used but  not defined"
            command
      | Some rule ->
          Bsb_ninja_targets.output_build group.dir buf ~outputs:output
            ~inputs:input ~rule)

type suffixes = { impl : string; intf : string }

let re_suffixes = { impl = Literals.suffix_re; intf = Literals.suffix_rei }
let ml_suffixes = { impl = Literals.suffix_ml; intf = Literals.suffix_mli }
let res_suffixes = { impl = Literals.suffix_res; intf = Literals.suffix_resi }

let emit_module_build (rules : Bsb_ninja_rule.builtin)
    (package_specs : Bsb_package_specs.t) (is_dev : bool) buf ?gentype_config
    ~global_config:
      { Bsb_ninja_global_vars.per_proj_dir; root_dir; package_name; _ }
    ~bs_dependencies ~bs_dev_dependencies _js_post_build_cmd namespace ~cur_dir
    ~ppx_config (module_info : Bsb_db.module_info) =
  let impl_dir, intf_dir =
    match module_info.dir with
    | Same dir -> (dir, dir)
    | Different { impl; intf } -> (impl, intf)
  in
  let which =
    match (impl_dir = cur_dir, intf_dir = cur_dir) with
    | true, true -> if module_info.info = Intf then `intf else `both
    | true, false -> `impl
    | false, true -> `intf
    | false, false -> assert false
  in
  let has_intf_file =
    match module_info.info with Intf | Impl_intf -> true | Impl -> false
  in
  let config =
    match module_info.syntax_kind with
    | Same Reason -> re_suffixes
    | Same Ml -> ml_suffixes
    | Same Res -> res_suffixes
    | Different { impl; intf } -> (
        assert (impl <> intf);
        match (impl, intf) with
        | Ml, Reason -> { impl = ml_suffixes.impl; intf = re_suffixes.intf }
        | Reason, Ml -> { impl = re_suffixes.impl; intf = ml_suffixes.intf }
        | Ml, Res -> { impl = ml_suffixes.impl; intf = res_suffixes.intf }
        | Res, Ml -> { impl = res_suffixes.impl; intf = ml_suffixes.intf }
        | Reason, Res -> { impl = re_suffixes.impl; intf = res_suffixes.intf }
        | Res, Reason -> { impl = res_suffixes.impl; intf = re_suffixes.intf }
        | Ml, Ml | Reason, Reason | Res, Res -> assert false)
  in
  let error_syntax_kind =
    match module_info.syntax_kind with
    | Same syntax_kind -> syntax_kind
    | Different { impl } -> impl
  in
  let filename_sans_extension = module_info.name_sans_extension in
  let input_impl =
    Format.asprintf "%s%s" (basename filename_sans_extension) config.impl
  in
  let input_intf =
    Format.asprintf "%s%s" (basename filename_sans_extension) config.intf
  in
  let output_ast = filename_sans_extension ^ Literals.suffix_ast in
  let output_iast = filename_sans_extension ^ Literals.suffix_iast in
  let virtual_proj_dir =
    Mel_workspace.virtual_proj_dir ~package_name ~root_dir
      ~package_dir:per_proj_dir
  in
  let rel_proj_dir, rel_artifacts_dir =
    ( Ext_path.rel_normalized_absolute_path
        ~from:(virtual_proj_dir // cur_dir)
        virtual_proj_dir,
      Mel_workspace.rel_artifacts_dir ~root_dir ~package_name
        ~proj_dir:virtual_proj_dir cur_dir )
  in

  let output_ast = rel_proj_dir // (impl_dir // basename output_ast) in
  let output_iast = rel_proj_dir // (intf_dir // basename output_iast) in
  let ppx_deps =
    if ppx_config.Bsb_config_types.ppxlib <> [] then
      [ rel_artifacts_dir // Mel_workspace.ppx_exe ]
    else []
  in
  let output_d =
    (rel_proj_dir // filename_sans_extension) ^ Literals.suffix_d
  in
  let output_d_as_dep = Format.asprintf "(include %s)" (basename output_d) in
  let output_filename_sans_extension =
    Ext_namespace_encode.make ?ns:namespace filename_sans_extension
  in
  let output_cmi = output_filename_sans_extension ^ Literals.suffix_cmi in
  let output_cmj = output_filename_sans_extension ^ Literals.suffix_cmj in
  let output_cmt = output_filename_sans_extension ^ Literals.suffix_cmt in
  let output_cmti = output_filename_sans_extension ^ Literals.suffix_cmti in
  let maybe_gentype_deps =
    Option.map
      (fun _ ->
        let root_artifacts_dir =
          Mel_workspace.rel_root_artifacts_dir ~root_dir
            (virtual_proj_dir // cur_dir)
        in
        [ root_artifacts_dir // Literals.sourcedirs_meta ])
      gentype_config
  in
  let output_js =
    Bsb_package_specs.get_list_of_output_js package_specs
      output_filename_sans_extension
  in
  if which <> `intf then (
    Bsb_ninja_targets.output_build cur_dir buf
      ~implicit_deps:
        ((rel_artifacts_dir // Literals.bsbuild_cache)
        :: (Option.value ~default:[] maybe_gentype_deps @ ppx_deps))
      ~outputs:[ output_ast ] ~inputs:[ input_impl ] ~rule:rules.build_ast
      ~error_syntax_kind;

    Bsb_ninja_targets.output_build cur_dir buf ~outputs:[ output_d ]
      ~inputs:
        (if has_intf_file then [ output_ast; output_iast ] else [ output_ast ])
      ~rule:(if is_dev then rules.build_bin_deps_dev else rules.build_bin_deps));
  let relative_ns_cmi =
    match namespace with
    | Some ns -> [ rel_artifacts_dir // (ns ^ Literals.suffix_cmi) ]
    | None -> []
  in
  let rel_bs_config_json = rel_proj_dir // Literals.bsconfig_json in

  let bs_dependencies =
    rel_dependencies_alias ~root_dir ~proj_dir:per_proj_dir ~cur_dir
      bs_dependencies
  in
  let bs_dependencies =
    if is_dev then
      let dev_dependencies =
        rel_dependencies_alias ~root_dir ~proj_dir:per_proj_dir ~cur_dir
          bs_dev_dependencies
      in
      dev_dependencies @ bs_dependencies
    else bs_dependencies
  in
  if has_intf_file && which <> `impl then (
    Bsb_ninja_targets.output_build cur_dir buf ~outputs:[ output_iast ]
      ~implicit_deps:ppx_deps ~inputs:[ input_intf ] ~rule:rules.build_ast
      ~error_syntax_kind;

    Bsb_ninja_targets.output_build cur_dir buf
      ~implicit_deps:[ output_d_as_dep ] ~outputs:[ output_cmi ]
      ~inputs:[ basename output_iast ]
      ~implicit_outputs:[ output_cmti ]
      ~rule:(if is_dev then rules.mi_dev else rules.mi)
      ~bs_dependencies
      ~rel_deps:(rel_bs_config_json :: relative_ns_cmi)
      ~error_syntax_kind);

  let rule =
    if has_intf_file then if is_dev then rules.mj_dev else rules.mj
    else if is_dev then rules.mij_dev
    else rules.mij
  in
  (if which <> `intf then
   let output_cmi =
     Ext_path.rel_normalized_absolute_path ~from:(per_proj_dir // cur_dir)
       (per_proj_dir // intf_dir)
     // basename output_cmi
   in
   Bsb_ninja_targets.output_build cur_dir buf ~outputs:[ output_cmj ]
     ~implicit_outputs:
       (if has_intf_file then [ output_cmt ] else [ output_cmi; output_cmt ])
     ~js_outputs:output_js
     ~inputs:[ basename output_ast ]
     ~implicit_deps:
       (if has_intf_file then [ output_cmi; output_d_as_dep ]
       else [ output_d_as_dep ])
     ~bs_dependencies
     ~rel_deps:(rel_bs_config_json :: relative_ns_cmi)
     ~rule ~error_syntax_kind);
  if which <> `intf then output_js else []

let handle_files_per_dir buf ~(global_config : Bsb_ninja_global_vars.t)
    ~(rules : Bsb_ninja_rule.builtin) ~package_specs ~js_post_build_cmd
    ~files_to_install ~bs_dependencies ~bs_dev_dependencies
    (group : Bsb_file_groups.file_group) : unit =
  let per_proj_dir = global_config.per_proj_dir in
  let is_dep_inside_workspace =
    Mel_workspace.is_dep_inside_workspace ~root_dir:global_config.root_dir
      ~package_dir:per_proj_dir
  in
  let rel_group_dir =
    (* For out-of source builds, mimic `node_modules/<package>` *)
    let virtual_proj_dir =
      Mel_workspace.virtual_proj_dir ~root_dir:global_config.root_dir
        ~package_dir:per_proj_dir ~package_name:global_config.package_name
    in
    Ext_path.rel_normalized_absolute_path ~from:global_config.root_dir
      (virtual_proj_dir // group.dir)
  in

  Buffer.add_string buf "(subdir ";
  Buffer.add_string buf rel_group_dir;
  Buffer.add_char buf '\n';
  if Bsb_file_groups.is_empty group then
    (* Still need to emit an alias or dune will complain it's empty in other deps. *)
    Bsb_ninja_targets.output_alias buf ~name:Literals.mel_dune_alias ~deps:[]
  else (
    if group.subdirs <> [] then (
      Buffer.add_string buf "(dirs :standard";
      Ext_list.iter group.subdirs (fun subdir ->
          Buffer.add_char buf ' ';
          Buffer.add_string buf subdir);
      Buffer.add_string buf ")\n");
    if not is_dep_inside_workspace then (
      Buffer.add_string buf
        "(copy_files (alias mel_copy_out_of_source_dir)\n (files ";
      Buffer.add_string buf (per_proj_dir // group.dir);
      Buffer.add_string buf Filename.dir_sep;
      Buffer.add_string buf "*))");
    let is_dev = group.is_dev in
    handle_generators buf group rules.customs;
    let installable =
      match group.public with
      | Export_all -> fun _ -> true
      | Export_none -> fun _ -> false
      | Export_set set -> fun module_name -> Set_string.mem set module_name
    in
    let db = global_config.db in
    let js_targets =
      Map_string.fold group.sources [] (fun module_name _ acc_js ->
          let module_info =
            Map_string.find_exn (if is_dev then db.dev else db.lib) module_name
          in
          if installable module_name then Queue.add module_info files_to_install;
          let js_outputs =
            emit_module_build rules package_specs is_dev buf ~global_config
              ~bs_dependencies ~bs_dev_dependencies
              ?gentype_config:global_config.gentypeconfig ~cur_dir:group.dir
              ~ppx_config:global_config.ppx_config js_post_build_cmd
              global_config.namespace module_info
          in
          List.map fst js_outputs :: acc_js)
    in
    Bsb_ninja_targets.output_alias buf ~name:Literals.mel_dune_alias
      ~deps:(List.concat js_targets));
  Buffer.add_string buf ")";
  Buffer.add_string buf "\n"
