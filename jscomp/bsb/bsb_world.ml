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

let install_targets dune_args =
  Bsb_log.info "@{<info>Installing started@}@.";
  let _p =
    Bsb_unix.dune_command
      ~on_exit:(fun _ ~exit_status:_ ~term_signal:_ ->
        Bsb_log.info "@{<info>Installing finished@} @.")
      ("build"
      :: (Literals.melange_eobjs_dir // Literals.sourcedirs_meta)
      :: dune_args)
  in
  ()

(* Don't use package specs from config because it could be a dependency, which
   gets the root's package specs. *)
let maybe_warn_about_dependencies_outside_workspace ~cwd
    (config : Bsb_config_types.t) ~package_specs =
  let is_path_outside_workspace { Bsb_config_types.package_path; _ } =
    not
      (Mel_workspace.is_dep_inside_workspace ~root_dir:cwd
         ~package_dir:package_path)
  in
  let has_in_source = Bsb_package_specs.has_in_source package_specs in
  if
    has_in_source
    && (Ext_list.exists config.bs_dependencies is_path_outside_workspace
       || Ext_list.exists config.bs_dev_dependencies is_path_outside_workspace)
  then
    raise
      (Bsb_exception.invalid_spec
         "`in-source: true` is not currently supported when dependencies exist \
          outside the workspace.")

let build_bs_deps cwd ~buf (deps : Bsb_package_specs.t) =
  let queue = Bsb_build_util.walk_all_deps cwd in
  Queue.fold
    (fun (acc : _ list) ({ top; proj_dir } : Bsb_build_util.package_context) ->
      match top with
      | Expect_none -> acc
      | Expect_name _ ->
          let config : Bsb_config_types.t =
            Bsb_config_parse.interpret_json ~package_kind:(Dependency deps)
              ~per_proj_dir:proj_dir
          in
          maybe_warn_about_dependencies_outside_workspace ~cwd config
            ~package_specs:deps;
          Bsb_ninja_gen.output_ninja_and_namespace_map ~buf
            ~per_proj_dir:proj_dir ~root_dir:cwd ~package_kind:(Dependency deps)
            config;
          config :: acc)
    [] queue

let make_world_deps ~cwd ~buf =
  Bsb_log.info "Making the dependency world!@.";
  let config : Bsb_config_types.t =
    Bsb_config_parse.interpret_json ~package_kind:Toplevel ~per_proj_dir:cwd
  in
  maybe_warn_about_dependencies_outside_workspace ~cwd config
    ~package_specs:config.package_specs;

  let deps = config.package_specs in
  let dep_configs = build_bs_deps cwd ~buf deps in
  let file_groups = ref [] in
  Ext_list.iter (config :: dep_configs)
    (fun (dep_config : Bsb_config_types.t) ->
      file_groups := (dep_config.dir, dep_config.file_groups) :: !file_groups);
  let source_meta = Source_metadata.create !file_groups in
  ((config, dep_configs), source_meta)
