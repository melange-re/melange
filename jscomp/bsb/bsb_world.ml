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


let (//) = Ext_path.combine

let install_targets cwd ({ namespace } as config : Bsb_config_types.t ) =
  let deps = config.package_specs in
  let lib_artifacts_dir = Bsb_config.lib_bs in
  begin
    Bsb_log.info "@{<info>Installing started@}@.";
    let file_groups = ref [] in
    let queue =
      Bsb_build_util.walk_all_deps cwd  in
    queue |> Queue.iter (fun ({ top; proj_dir} : Bsb_build_util.package_context) ->
      let dep_config = match top with
        | Expect_none -> config
        | Expect_name s ->
          Bsb_config_parse.interpret_json
            ~package_kind:(Dependency deps)
            ~per_proj_dir:proj_dir
      in
      file_groups := (proj_dir, dep_config.file_groups) :: !file_groups
    );
    let lib_bs_dir = cwd // lib_artifacts_dir in
    Bsb_build_util.mkp lib_bs_dir;
    Bsb_watcher_gen.generate_sourcedirs_meta
      ~name:(lib_bs_dir // Literals.sourcedirs_meta)
      !file_groups;
    Bsb_log.info "@{<info>Installing finished@} @.";
  end


let build_bs_deps cwd ~buf (deps : Bsb_package_specs.t) =
   let queue =
      Bsb_build_util.walk_all_deps  cwd  in
      queue |> Queue.iter (fun ({top; proj_dir} : Bsb_build_util.package_context) ->
        match top with
        | Expect_none -> ()
        | Expect_name _ ->
          let package_kind = Bsb_package_kind.Dependency deps in
          let config : Bsb_config_types.t =
            Bsb_config_parse.interpret_json
              ~package_kind
              ~per_proj_dir:proj_dir
          in

          Bsb_ninja_regen.regenerate_ninja
            ~buf
            ~config
            ~package_kind
            ~root_dir:cwd
            proj_dir
    )


let make_world_deps ~cwd ~buf =
  Bsb_log.info "Making the dependency world!@.";
  let config : Bsb_config_types.t =
    Bsb_config_parse.interpret_json
      ~package_kind:Toplevel
      ~per_proj_dir:cwd
  in
  let deps = config.package_specs in
  build_bs_deps cwd ~buf deps;
  config
