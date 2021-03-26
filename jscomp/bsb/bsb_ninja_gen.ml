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

let (//) = Ext_path.combine

(* we need copy package.json into [_build] since it does affect build output
   it is a bad idea to copy package.json which requires to copy js files
*)


(* let dash_i = "-I" *)

let dependencies_directories ~file_groups deps =
  Ext_list.flat_map deps (fun { Bsb_config_types.package_dirs; _ } -> package_dirs)


let get_bsc_flags
    (bsc_flags : string list)
  : string =
  String.concat Ext_string.single_space bsc_flags

let bsc_lib_includes (bs_dependencies : Bsb_config_types.dependencies) =
  (Ext_list.flat_map bs_dependencies (fun x -> x.package_install_dirs))

(* let output_static_resources
    (static_resources : string list)
    ~cur_dir
    copy_rule
    oc
  =
  Ext_list.iter static_resources (fun output ->
      Bsb_ninja_targets.output_build
        cur_dir
        oc
        ~outputs:[output]
        ~inputs:[Bsb_config.proj_rel output]
        ~rule:copy_rule);
  if static_resources <> [] then
    Bsb_ninja_targets.phony
      oc
      ~order_only_deps:static_resources
      ~inputs:[]
      ~output:Literals.build_ninja *)
(*
  FIXME: check if the trick still works
  phony build.ninja : | resources
*)
let mark_rescript oc =
  output_string oc "rescript = 1\n"
let output_installation_file cwd_lib_bs namespace files_to_install =
  let install_oc = open_out_bin (cwd_lib_bs // "install.ninja") in
  mark_rescript install_oc;
  let o s = output_string install_oc s in
  let[@inline] oo suffix ~dest ~src =
    o  "o " ;
    o dest ;
    o suffix;
    o " : cp ";
    o src;
    o suffix; o "\n" in
  let bs = ".."//"bs" in
  let sb = ".."//".." in
  o (if Ext_sys.is_windows_or_cygwin then
      "rule cp\n  command = cmd.exe /C copy /Y $i $out >NUL\n\
       rule touch\n command = cmd.exe /C type nul >>$out & copy $out+,, >NUL\n"
    else
      "rule cp\n  command = cp $i $out\n\
       rule touch\n command = touch $out\n"
    );
  let essentials = Ext_buffer.create 1_000 in
  files_to_install
  |> Queue.iter (fun ({name_sans_extension;syntax_kind; info} : Bsb_db.module_info) ->
      let base = Filename.basename name_sans_extension in
      let dest = Ext_namespace_encode.make ?ns:namespace base in
      let ns_origin = Ext_namespace_encode.make ?ns:namespace name_sans_extension in
      let src = bs//ns_origin in
      oo Literals.suffix_cmi ~dest ~src;
      oo Literals.suffix_cmj ~dest ~src;
      oo Literals.suffix_cmt ~dest ~src;

      Ext_buffer.add_string essentials  dest ;
      Ext_buffer.add_string_char essentials Literals.suffix_cmi ' ';
      Ext_buffer.add_string essentials dest ;
      Ext_buffer.add_string_char essentials Literals.suffix_cmj ' ';

      let suffix =
        match syntax_kind with
        | Ml -> Literals.suffix_ml
        | Reason -> Literals.suffix_re
        | Res -> Literals.suffix_res
      in  oo suffix ~dest:base ~src:(sb//name_sans_extension);
      match info with
      | Intf  -> assert false
      | Impl ->  ()
      | Impl_intf ->
        let  suffix_b =
          match syntax_kind with
          | Ml ->  Literals.suffix_mli
          | Reason ->  Literals.suffix_rei
          | Res ->  Literals.suffix_resi in
        oo suffix_b  ~dest:base ~src:(sb//name_sans_extension);
        oo Literals.suffix_cmti ~dest ~src
    );
  begin match namespace with
  | None -> ()
  | Some dest ->
    let src = bs // dest in
    oo Literals.suffix_cmi ~dest ~src;
    oo Literals.suffix_cmj ~dest ~src;
    oo Literals.suffix_cmt ~dest ~src;
    Ext_buffer.add_string essentials dest ;
    Ext_buffer.add_string_char essentials Literals.suffix_cmi ' ';
    Ext_buffer.add_string essentials dest ;
    Ext_buffer.add_string essentials Literals.suffix_cmj
  end;
  Ext_buffer.add_char essentials '\n';
  o "build install.stamp : touch ";
  Ext_buffer.output_buffer install_oc essentials;
  close_out install_oc

let output_ninja_and_namespace_map
    ~buf
    ~per_proj_dir
    ~root_dir
    ~package_kind
    ({
      package_name;
      external_includes;
      bsc_flags ;
      pp_file;
      ppx_files ;

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
  let lib_artifacts_dir = Bsb_config.lib_bs in
  (* let cwd_lib_bs = per_proj_dir // lib_artifacts_dir in *)
  let warnings = Bsb_warning.to_bsb_string ~package_kind warning in
  let bsc_flags = (get_bsc_flags bsc_flags) in
  let bs_groups : Bsb_db.t = {lib = Map_string.empty; dev = Map_string.empty} in
  let source_dirs : string list Bsb_db.cat = {lib = []; dev = []} in
  let _static_resources =
    Ext_list.fold_left
      bs_file_groups
      [] (
      fun
        (acc_resources : string list)
        {sources; dir; resources; is_dev}
        ->
          if is_dev then begin
            bs_groups.dev <- Bsb_db_util.merge bs_groups.dev sources ;
            source_dirs.dev <- dir :: source_dirs.dev;
          end else begin
            bs_groups.lib <- Bsb_db_util.merge bs_groups.lib sources ;
            source_dirs.lib <- dir :: source_dirs.lib
          end;
          Ext_list.map_append resources  acc_resources (fun x -> dir//x)
    ) in
  let g_stdlib_incl = if built_in_dependency then
      let path = Bsb_config.stdlib_path ~cwd:per_proj_dir in
      [ path ]
    else []
  in
  let global_config =
    Bsb_ninja_global_vars.make
      ~package_name
      ~src_root_dir:per_proj_dir
      ~bsc:(Ext_filename.maybe_quote Bsb_global_paths.vendor_bsc)
      ~bsdep:(Ext_filename.maybe_quote Bsb_global_paths.vendor_bsdep)
      ~bs_dep_parse:(Ext_filename.maybe_quote Bsb_global_paths.bs_dep_parse)
      ~warnings
      ~bsc_flags
      ~g_dpkg_incls:(bsc_lib_includes bs_dev_dependencies)
      ~g_dev_incls:source_dirs.dev
      ~g_stdlib_incl
      ~g_sourcedirs_incls:source_dirs.lib
      ~g_lib_incls:(bsc_lib_includes bs_dependencies)
      ~external_incls:external_includes
      ~gentypeconfig:(Ext_option.map gentype_config (fun x ->
          ("-bs-gentype " ^ x.path)))
      ~pp_flags:(Ext_option.map pp_file Bsb_build_util.pp_flag)
      ~namespace
  in
  let lib = bs_groups.lib in
  let dev = bs_groups.dev in
  Bsb_db_util.sanity_check lib;
  Bsb_db_util.sanity_check dev;
  Map_string.iter dev
    (fun k a ->
       if Map_string.mem lib k  then
         raise (Bsb_db_util.conflict_module_info k a (Map_string.find_exn lib k))
    ) ;
  Bsb_db_encode.write_build_cache ~proj_dir:per_proj_dir bs_groups;
  let rules : Bsb_ninja_rule.builtin =
      Bsb_ninja_rule.make_custom_rules
      ~global_config
      ~has_postbuild:js_post_build_cmd
      ~pp_file
      ~ppx_files
      ~has_builtin:built_in_dependency
      ~reason_react_jsx
      ~package_specs
      generators in
  let bs_dependencies =
    dependencies_directories ~file_groups:bs_file_groups bs_dependencies
  in
  let bs_dev_dependencies =
    dependencies_directories ~file_groups:bs_file_groups bs_dev_dependencies
  in
  Buffer.add_char buf '\n';

  (* output_static_resources static_resources rules.copy_resources oc ; *)
  (** Generate build statement for each file *)
  Ext_list.iter bs_file_groups
    (fun files_per_dir ->
      (* let group_dir = global_config.src_root_dir // files_per_dir.dir in *)
       Bsb_ninja_file_groups.handle_files_per_dir buf
         ~global_config
         ~rules
         ~package_specs
         ~files_to_install
         ~js_post_build_cmd
         ~bs_dev_dependencies
         ~bs_dependencies
         ~root_dir
         files_per_dir;
         )
  ;

  Buffer.add_char buf '\n';
  Ext_option.iter  namespace (fun ns ->
      let namespace_dir =
        Ext_path.rel_normalized_absolute_path ~from:root_dir (per_proj_dir // lib_artifacts_dir)
      in
      Bsb_namespace_map_gen.output
        ~dir:namespace_dir ns
        bs_file_groups;
      Buffer.add_string buf "(subdir ";
      Buffer.add_string buf namespace_dir;
      Bsb_ninja_targets.output_build namespace_dir buf
        ~outputs:[ns ^ Literals.suffix_cmi]
        ~inputs:[ns ^ Literals.suffix_mlmap]
        ~rule:rules.build_package;
      Buffer.add_string buf ")";
    );
  Buffer.add_char buf '\n'

  (* output_installation_file cwd_lib_bs namespace files_to_install *)
