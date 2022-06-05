(* Copyright (C) 2017- Hongbo Zhang, Authors of ReScript
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

let install_targets cwd dep_configs =
  let artifacts_dir =
    Bsb_config.rel_artifacts_dir ~root_dir:cwd ~proj_dir:cwd cwd
  in
  Bsb_log.info "@{<info>Installing started@}@.";
  let file_groups = ref [] in
  Ext_list.iter dep_configs (fun (dep_config : Bsb_config_types.t) ->
      file_groups := (dep_config.dir, dep_config.file_groups) :: !file_groups);
  Bsb_build_util.mkp artifacts_dir;
  let source_meta =
    Bsb_watcher_gen.generate_sourcedirs_meta
      ~name:(artifacts_dir // Literals.sourcedirs_meta)
      !file_groups
  in
  Bsb_log.info "@{<info>Installing finished@} @.";
  source_meta

let build_bs_deps cwd ~buf (deps : Bsb_package_specs.t) =
  let queue = Bsb_build_util.walk_all_deps cwd in
  Queue.fold
    (fun (acc : _ list) ({ top; proj_dir } : Bsb_build_util.package_context) ->
      match top with
      | Expect_none -> acc
      | Expect_name _ ->
          let package_kind = Bsb_package_kind.Dependency deps in
          let config : Bsb_config_types.t =
            Bsb_config_parse.interpret_json ~package_kind ~per_proj_dir:proj_dir
          in
          Bsb_ninja_gen.output_ninja_and_namespace_map ~buf
            ~per_proj_dir:proj_dir ~root_dir:cwd ~package_kind config;
          config :: acc)
    [] queue

let make_world_deps ~cwd ~buf =
  Bsb_log.info "Making the dependency world!@.";
  let config : Bsb_config_types.t =
    Bsb_config_parse.interpret_json ~package_kind:Toplevel ~per_proj_dir:cwd
  in
  Bsb_merlin_gen.merlin_file_gen ~per_proj_dir:cwd config;
  let deps = config.package_specs in
  let dep_configs = build_bs_deps cwd ~buf deps in
  (config, dep_configs)
