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

let (//) = Ext_path.concat

let get_bsc_flags
    (bsc_flags : string list)
  : string =
  String.concat Ext_string.single_space bsc_flags

let bsc_lib_includes ~root_dir (bs_dependencies : Bsb_config_types.dependencies) =
  Ext_list.flat_map bs_dependencies (fun { package_install_dirs; _ } ->
    Ext_list.map package_install_dirs
      (fun { Bsb_config_types.package_path; package_name; dir } ->
        let virtual_proj_dir =
          Bsb_config.virtual_proj_dir ~root_dir ~package_dir:package_path ~package_name
        in
        (virtual_proj_dir // dir)))

let output_ninja_and_namespace_map
    ~buf
    ~per_proj_dir
    ~root_dir
    ~package_kind
    ({
      package_name;
      bsc_flags ;
      pp_file;
      ppx_config ;

      bs_dependencies;
      bs_dev_dependencies;
      js_post_build_cmd;
      package_specs;
      file_groups = { files = bs_file_groups};
      files_to_install;
      built_in_dependency;
      reason_react_jsx;
      generators ;
      namespace ;
      warning;
      gentype_config;

    } : Bsb_config_types.t) : unit
  =
  let warnings = Bsb_warning.to_bsb_string ~package_kind warning in
  let bsc_flags = (get_bsc_flags bsc_flags) in
  let bs_groups : Bsb_db.t = {lib = Map_string.empty; dev = Map_string.empty} in
  let source_dirs : string list Bsb_db.cat = {lib = []; dev = []} in
  Ext_list.iter bs_file_groups (fun
      {sources; dir; is_dev} ->
    if is_dev then begin
      bs_groups.dev <- Bsb_db_util.merge bs_groups.dev sources ;
      source_dirs.dev <- dir :: source_dirs.dev;
    end else begin
      bs_groups.lib <- Bsb_db_util.merge bs_groups.lib sources ;
      source_dirs.lib <- dir :: source_dirs.lib
    end);
  let global_config =
    Bsb_ninja_global_vars.make
      ~package_name
      ~db:bs_groups
      ~root_dir
      ~per_proj_dir
      ~bsc:(Ext_filename.maybe_quote Bsb_global_paths.vendor_bsc)
      ~bsdep:(Ext_filename.maybe_quote Bsb_global_paths.vendor_bsdep)
      ~warnings
      ~bsc_flags
      ~g_dpkg_incls:(bsc_lib_includes ~root_dir bs_dev_dependencies)
      ~g_dev_incls:source_dirs.dev
      ~g_sourcedirs_incls:source_dirs.lib
      ~g_lib_incls:(bsc_lib_includes ~root_dir bs_dependencies)
      ~gentypeconfig:(Ext_option.map gentype_config (fun x ->
          ("-bs-gentype " ^ x.path)))
      ~ppx_config
      ~pp_flags:(Ext_option.map pp_file Bsb_build_util.pp_flag)
      ~namespace
  in
  let lib = bs_groups.lib in
  let dev = bs_groups.dev in
  Map_string.iter dev
    (fun k a ->
       if Map_string.mem lib k  then
         raise (Bsb_db_util.conflict_module_info k a (Map_string.find_exn lib k))
    ) ;
  let rules : Bsb_ninja_rule.builtin =
      Bsb_ninja_rule.make_custom_rules
      ~global_config
      ~has_postbuild:js_post_build_cmd
      ~pp_file
      ~has_builtin:built_in_dependency
      ~reason_react_jsx
      ~package_specs
      generators in
  Buffer.add_char buf '\n';

  (** Generate build statement for each file *)
  Ext_list.iter bs_file_groups
    (fun files_per_dir ->
       Bsb_ninja_file_groups.handle_files_per_dir buf
         ~global_config
         ~rules
         ~package_specs
         ~files_to_install
         ~js_post_build_cmd
         ~bs_dev_dependencies
         ~bs_dependencies
         files_per_dir);

  if not (Bsb_config.is_dep_inside_workspace ~root_dir ~package_dir:per_proj_dir) then (
    Buffer.add_string buf "(subdir ";
    Buffer.add_string buf (Bsb_config.to_workspace_proj_dir ~package_name);
    Buffer.add_string buf
      "\n (copy_files (alias mel_copy_out_of_source_dir)\n (files ";
    Buffer.add_string buf (per_proj_dir);
    Buffer.add_string buf Filename.dir_sep;
    Buffer.add_string buf "*)))");

  Buffer.add_char buf '\n';

  let artifacts_dir =
    Bsb_config.rel_artifacts_dir
      ~package_name
      ~root_dir ~proj_dir:per_proj_dir root_dir
  in

  Buffer.add_string buf "(subdir ";
  Buffer.add_string buf artifacts_dir;

  Bsb_ppxlib.ppxlib buf ~ppx_config;

  Ext_option.iter namespace (fun ns ->
      Bsb_namespace_map_gen.output buf ns bs_file_groups;

      Bsb_ninja_targets.output_build artifacts_dir buf
        ~outputs:[ns ^ Literals.suffix_cmi]
        ~inputs:[ns ^ Literals.suffix_mlmap]
        ~rule:rules.build_package;
    );

  Bsb_db_encode.write_build_cache buf bs_groups;
  Buffer.add_string buf "\n)\n";

  match package_kind with
  | Bsb_package_kind.Toplevel ->
    (* Add `(data_only_dirs node_modules)` because they could contain native
     * OCaml code that we do not want to build. *)
    Buffer.add_string buf "\n(data_only_dirs ";
    Buffer.add_string buf Literals.node_modules;
    Buffer.add_char buf ' ';
    Buffer.add_string buf Literals.melange_eobjs_dir;
    (* for the edge case of empty sources (either in user config or because a
       source dir is empty), we emit an empty `bsb_world` alias. This avoids
       showing the user an error when they haven't done anything. *)
    Buffer.add_string buf ")\n(alias (name mel) (deps ";

    (* Build the dependencies in case `"sources"` == []. *)
    Ext_list.iter
      (Bsb_ninja_file_groups.rel_dependencies_alias
        ~root_dir:root_dir
        ~proj_dir:root_dir
        ~cur_dir:root_dir
        bs_dependencies)
      (fun dep ->
        Buffer.add_string buf (Format.asprintf "(alias %s)" dep));
    Buffer.add_string buf "))\n" ;
  | Dependency _ -> ()


