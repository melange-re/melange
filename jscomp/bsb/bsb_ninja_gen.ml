(* Copyright (C) 2015 - 2016 Bloomberg Finance L.P.
 * Copyright (C) 2017 - Hongbo Zhang, Authors of ReScript
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

(* we need copy package.json into [_build] since it does affect build output
   it is a bad idea to copy package.json which requires to copy js files
*)

let ( // ) = Ext_path.concat

let get_bsc_flags (bsc_flags : string list) : string =
  String.concat Ext_string.single_space bsc_flags

let bsc_lib_includes ~root_dir (bs_dependencies : Bsb_config_types.dependencies)
    =
  Ext_list.flat_map bs_dependencies (fun { package_install_dirs; _ } ->
      Ext_list.map package_install_dirs
        (fun { Bsb_config_types.package_path; package_name; dir } ->
          let virtual_proj_dir =
            Mel_workspace.virtual_proj_dir ~root_dir ~package_dir:package_path
              ~package_name
          in
          virtual_proj_dir // dir))

let output_ninja_and_namespace_map ~buf ~per_proj_dir ~root_dir
    ~(package_kind : Bsb_package_kind.Source_info.t)
    ({
       package_name;
       bsc_flags;
       pp_file;
       ppx_config;
       bs_dependencies;
       bs_dev_dependencies;
       js_post_build_cmd;
       package_specs;
       file_groups = { files = bs_file_groups };
       built_in_dependency;
       reason_react_jsx;
       generators;
       namespace;
       warning;
       gentype_config;
     } :
      Bsb_config_types.t) : unit =
  let warnings =
    Bsb_warning.to_bsb_string
      ~package_kind:(Bsb_package_kind.Source_info.to_package_kind package_kind)
      warning
  in
  let bsc_flags = get_bsc_flags bsc_flags in
  let bs_groups : Bsb_db.t =
    { lib = Map_string.empty; dev = Map_string.empty }
  in
  let source_dirs : string list Bsb_db.cat = { lib = []; dev = [] } in
  Ext_list.iter bs_file_groups (fun { sources; dir; is_dev } ->
      if is_dev then (
        bs_groups.dev <- Bsb_db_util.merge bs_groups.dev sources;
        source_dirs.dev <- dir :: source_dirs.dev)
      else (
        bs_groups.lib <- Bsb_db_util.merge bs_groups.lib sources;
        source_dirs.lib <- dir :: source_dirs.lib));
  let global_config =
    Bsb_ninja_global_vars.make ~package_name ~root_dir ~per_proj_dir
      ~bsc:(Ext_filename.maybe_quote Bsb_global_paths.vendor_bsc)
      ~bsdep:(Ext_filename.maybe_quote Bsb_global_paths.vendor_bsdep)
      ~warnings ~bsc_flags
      ~g_dpkg_incls:(bsc_lib_includes ~root_dir bs_dev_dependencies)
      ~g_dev_incls:source_dirs.dev ~g_sourcedirs_incls:source_dirs.lib
      ~g_lib_incls:(bsc_lib_includes ~root_dir bs_dependencies)
      ~gentypeconfig:
        (Ext_option.map gentype_config (fun x -> "-bs-gentype " ^ x.path))
      ~ppx_config
      ~pp_flags:(Ext_option.map pp_file Bsb_build_util.pp_flag)
      ~namespace
  in
  let lib = bs_groups.lib in
  let dev = bs_groups.dev in
  Map_string.iter dev (fun k a ->
      if Map_string.mem lib k then
        raise (Bsb_db_util.conflict_module_info k a (Map_string.find_exn lib k)));
  let rules : Bsb_ninja_rule.builtin =
    Bsb_ninja_rule.make_custom_rules ~global_config
      ~has_postbuild:js_post_build_cmd ~pp_file ~has_builtin:built_in_dependency
      ~reason_react_jsx ~package_specs generators
  in
  Buffer.add_char buf '\n';

  (* Generate build statement for each file *)
  Ext_list.iter bs_file_groups (fun files_per_dir ->
      Bsb_ninja_file_groups.handle_files_per_dir buf ~global_config ~rules
        ~db:bs_groups ~js_post_build_cmd ~bs_dev_dependencies ~bs_dependencies
        files_per_dir);

  if
    not
      (Mel_workspace.is_dep_inside_workspace ~root_dir ~package_dir:per_proj_dir)
  then (
    Buffer.add_string buf "(subdir ";
    Buffer.add_string buf (Mel_workspace.to_workspace_proj_dir ~package_name);
    Buffer.add_string buf
      "\n (copy_files (alias mel_copy_out_of_source_dir)\n (files ";
    Buffer.add_string buf per_proj_dir;
    Buffer.add_string buf Filename.dir_sep;
    Buffer.add_string buf "*)))");

  Buffer.add_char buf '\n';

  let artifacts_dir =
    Mel_workspace.rel_artifacts_dir ~package_name ~root_dir
      ~proj_dir:per_proj_dir root_dir
  in

  Buffer.add_string buf "(subdir ";
  Buffer.add_string buf artifacts_dir;

  Bsb_ppxlib.ppxlib buf ~ppx_config;

  Ext_option.iter namespace (fun ns ->
      Bsb_namespace_map_gen.output buf ns bs_file_groups;

      Bsb_ninja_targets.output_build artifacts_dir buf
        ~outputs:[ ns ^ Literals.suffix_cmi ]
        ~inputs:[ ns ^ Literals.suffix_mlmap ]
        ~rule:rules.build_package);

  Bsb_db_encode.write_build_cache buf bs_groups;

  match package_kind with
  | Bsb_package_kind.Source_info.Toplevel source_meta ->
      Buffer.add_string buf
        (Format.asprintf "\n(rule (write-file %s %S)) " Literals.sourcedirs_meta
           (source_meta |> Source_metadata.to_json |> Ext_json_noloc.to_string));
      Buffer.add_string buf "\n)\n";

      (* Add `(data_only_dirs node_modules)` because they could contain native
       * OCaml code that we do not want to build. *)
      Buffer.add_string buf "\n(data_only_dirs ";
      Buffer.add_string buf Literals.node_modules;
      Buffer.add_char buf ' ';
      (* Ext_list.iter (Bsb_package_specs.specs package_specs) (fun spec -> *)
      (* Buffer.add_string buf (Bsb_package_specs.output_dir_of_spec spec)); *)
      Buffer.add_char buf ' ';
      Buffer.add_string buf Literals.melange_eobjs_dir;
      (* for the edge case of empty sources (either in user config or because a
         source dir is empty), we emit an empty `bsb_world` alias. This avoids
         showing the user an error when they haven't done anything. *)
      Buffer.add_string buf
        (Format.asprintf ")\n(alias (name mel) (deps %s "
           (artifacts_dir // Literals.sourcedirs_meta));

      (* Build the dependencies in case `"sources"` == []. *)
      Ext_list.iter
        (Bsb_ninja_file_groups.rel_dependencies_alias ~root_dir
           ~proj_dir:root_dir ~cur_dir:root_dir bs_dependencies) (fun dep ->
          Buffer.add_string buf (Format.asprintf "(alias %s)" dep));
      Buffer.add_string buf "))\n"
  | Dependency _ -> Buffer.add_string buf "\n)\n"

let rel_include_dirs ~package_name ~root_dir ~per_proj_dir ~install_dir ~cur_dir
    ?namespace source_dirs =
  let relativize_single dir =
    Ext_path.rel_normalized_absolute_path ~from:install_dir (per_proj_dir // dir)
  in
  let source_dirs = Ext_list.map source_dirs relativize_single in
  let dirs =
    match namespace with
    | None -> source_dirs
    | Some _namespace ->
        let rel_artifacts =
          (* XXX(anmonteiro): wrong *)
          Mel_workspace.rel_artifacts_dir ~package_name ~root_dir
            ~proj_dir:per_proj_dir (install_dir // cur_dir)
        in
        rel_artifacts :: source_dirs
    (*working dir is [lib/bs] we include this path to have namespace mapping*)
  in
  Bsb_build_util.include_dirs dirs

let output_virtual_package ~root_dir ~package_spec ~buf
    ((config, configs) : Bsb_config_types.t * Bsb_config_types.t list) =
  let package_spec_dir = Bsb_package_specs.output_dir_of_spec package_spec in
  let package_spec_suffix = Ext_js_suffix.to_string package_spec.suffix in
  Buffer.add_string buf "\n(subdir ";
  Buffer.add_string buf package_spec_dir;

  Ext_list.iter
    ((Bsb_package_kind.Toplevel, config)
    :: List.map
         (fun c -> (Bsb_package_kind.Dependency config.package_specs, c))
         configs)
    (fun (_package_kind, config) ->
      let {
        Bsb_config_types.dir = config_proj_dir;
        package_name;
        file_groups;
        namespace;
        bs_dependencies;
        bs_dev_dependencies;
        _;
      } =
        config
      in

      Ext_list.iter file_groups.files (fun group ->
          let virtual_proj_dir =
            Mel_workspace.virtual_proj_dir ~root_dir
              ~package_dir:config_proj_dir ~package_name
          in
          let rel_group_dir =
            Ext_path.rel_normalized_absolute_path ~from:root_dir
              (virtual_proj_dir // group.dir)
          in
          let install_dir = root_dir // package_spec_dir // rel_group_dir in

          Buffer.add_string buf "\n(subdir ";
          Buffer.add_string buf rel_group_dir;
          let rel_build_dir =
            Ext_path.rel_normalized_absolute_path ~from:install_dir
              (root_dir // rel_group_dir)
          in

          let js_targets =
            Map_string.fold group.sources []
              (fun _module_name { Bsb_db.name_sans_extension; _ } acc ->
                let output_filename_sans_extension =
                  Filename.basename
                    (Ext_namespace_encode.make ?ns:namespace name_sans_extension)
                in
                let input_cmj =
                  output_filename_sans_extension ^ Literals.suffix_cmj
                in
                let output_js =
                  output_filename_sans_extension ^ package_spec_suffix
                in
                let rule =
                  {
                    Bsb_ninja_rule.rule =
                      (fun buf ?error_syntax_kind:_
                           ?target:(_target = "%{targets}") _cur_dir ->
                        if package_spec.in_source then (
                          Buffer.add_string buf
                            "(mode (promote (until-clean) (only ";
                          Buffer.add_string buf output_js;
                          Buffer.add_string buf ") (into ";
                          Buffer.add_string buf rel_build_dir;
                          Buffer.add_string buf ")))");

                        (* else Buffer.add_string buf "(mode fallback)"; *)
                        let ns_flag =
                          match namespace with
                          | None -> " "
                          | Some n -> " -bs-ns " ^ n
                        in
                        let rel_incls ?namespace dirs =
                          rel_include_dirs ~package_name ~root_dir
                            ~per_proj_dir:virtual_proj_dir ~install_dir
                            ~cur_dir:group.dir ?namespace dirs
                        in
                        let source_dirs : string list Bsb_db.cat =
                          { lib = []; dev = [] }
                        in

                        Ext_list.iter file_groups.files (fun { dir; is_dev } ->
                            if is_dev then
                              source_dirs.dev <- dir :: source_dirs.dev
                            else source_dirs.lib <- dir :: source_dirs.lib);

                        Buffer.add_string buf "(action\n ";
                        Buffer.add_string buf " (progn (run cp %{sources} .";
                        Buffer.add_string buf ")\n";
                        Buffer.add_string buf " (run ";
                        Buffer.add_string buf
                          (Ext_filename.maybe_quote Bsb_global_paths.vendor_bsc);
                        Buffer.add_string buf ns_flag;
                        if group.is_dev && source_dirs.dev <> [] then (
                          let dev_incls =
                            rel_incls ?namespace source_dirs.dev
                          in
                          Buffer.add_string buf " ";
                          Buffer.add_string buf dev_incls);
                        Buffer.add_string buf (rel_incls source_dirs.lib);
                        Buffer.add_string buf " ";
                        Buffer.add_string buf
                          (Bsb_build_util.include_dirs
                             (Ext_list.map
                                (bsc_lib_includes ~root_dir bs_dependencies)
                                (fun dir ->
                                  Ext_path.rel_normalized_absolute_path
                                    ~from:install_dir dir)));
                        if group.is_dev then (
                          Buffer.add_string buf " ";
                          Buffer.add_string buf
                            (Bsb_build_util.include_dirs
                               (Ext_list.map
                                  (bsc_lib_includes ~root_dir
                                     bs_dev_dependencies) (fun dir ->
                                    Ext_path.rel_normalized_absolute_path
                                      ~from:install_dir dir))));

                        Buffer.add_string buf " -bs-package-name ";
                        Buffer.add_string buf
                          (Ext_filename.maybe_quote package_name);

                        Buffer.add_string buf
                          (Format.asprintf " -bs-package-output %s:%s:%s"
                             (Bsb_package_specs.string_of_format
                                package_spec.format)
                             group.dir package_spec_suffix);
                        Buffer.add_string buf " %{inputs}";
                        Buffer.add_string buf ")))");
                  }
                in
                let rel_cmj = rel_build_dir // input_cmj in

                Bsb_ninja_targets.output_build rel_group_dir buf
                  ~outputs:[ output_js ] ~inputs:[ rel_cmj ]
                  ~implicit_deps:
                    [
                      Format.asprintf "(:sources (source_tree %s))"
                        rel_build_dir;
                    ]
                  ~rule;
                output_js :: acc)
          in

          Bsb_ninja_targets.output_alias buf ~name:Literals.mel_dune_alias
            ~deps:js_targets;

          Buffer.add_string buf ")\n"));

  Buffer.add_string buf ")\n"
