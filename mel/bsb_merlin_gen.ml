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

let () = ()
let merlin = ".merlin"
let merlin_header = "####{BSB GENERATED: NO EDIT"
let merlin_trailer = "####BSB GENERATED: NO EDIT}"
let merlin_trailer_length = String.length merlin_trailer
let ( // ) = Ext_path.combine

(* [new_content] should start end finish with newline *)
let revise_merlin merlin new_content =
  if Sys.file_exists merlin then
    let s = Ext_io.load_file merlin in
    let header = Ext_string.find s ~sub:merlin_header in
    let tail = Ext_string.find s ~sub:merlin_trailer in
    if header < 0 && tail < 0 then (
      (* locked region not added yet *)
      let ochan = open_out_bin merlin in
      output_string ochan s;
      output_string ochan "\n";
      output_string ochan merlin_header;
      Buffer.output_buffer ochan new_content;
      output_string ochan merlin_trailer;
      output_string ochan "\n";
      close_out ochan)
    else if header >= 0 && tail >= 0 then (
      (* there is one, hit it everytime,
         should be fixed point
      *)
      let ochan = open_out_bin merlin in
      output_string ochan (String.sub s 0 header);
      output_string ochan merlin_header;
      Buffer.output_buffer ochan new_content;
      output_string ochan merlin_trailer;
      output_string ochan
        (Ext_string.tail_from s (tail + merlin_trailer_length));
      close_out ochan)
    else
      failwith
        "the .merlin is corrupted, locked region by bsb is not consistent "
  else
    let ochan = open_out_bin merlin in
    output_string ochan merlin_header;
    Buffer.output_buffer ochan new_content;
    output_string ochan merlin_trailer;
    output_string ochan "\n";
    close_out ochan

(* ATTENTION: order matters here, need resolve global properties before
   merlin generation
*)
let merlin_flg_ppx = "\nFLG -ppx "
let merlin_flg_pp = "\nFLG -pp "
let merlin_s = "\nS "
let merlin_b = "\nB "
let merlin_flg = "\nFLG "
let bs_flg_prefix = "-bs-"

let output_merlin_namespace buffer ns =
  match ns with
  | None -> ()
  | Some x ->
      Buffer.add_string buffer merlin_flg;
      Buffer.add_string buffer "-open ";
      Buffer.add_string buffer x

(* Literals.dash_nostdlib::
   FIX editor tooling, note merlin does not need -nostdlib since we added S and B
   RLS will add -I for those cmi files,
   Some consistency check is needed
   Unless we tell the editor to peek those cmi for auto-complete and others for building which is too
   complicated
*)
let bsc_flg_to_merlin_ocamlc_flg bsc_flags =
  let flags =
    Ext_list.filter bsc_flags (fun x ->
        not (Ext_string.starts_with x bs_flg_prefix))
  in
  if flags <> [] then merlin_flg ^ String.concat Ext_string.single_space flags
  else ""

(* No need for [-warn-error] in merlin  *)
let warning_to_merlin_flg (warning : Bsb_warning.t) : string =
  merlin_flg ^ Bsb_warning.to_merlin_string warning

let package_merlin buffer ~dune_build_dir
    (package : Bsb_config_types.dependency) =
  Ext_list.iter package.package_install_dirs
    (fun { Bsb_config_types.dir; package_path; package_name; _ } ->
      let source_path, package_install_path =
        if
          Mel_workspace.is_dep_inside_workspace ~root_dir:Mel_workspace.cwd
            ~package_dir:package_path
        then
          let rel =
            Ext_path.rel_normalized_absolute_path ~from:Mel_workspace.cwd
              (package_path // dir)
          in
          (Mel_workspace.cwd // rel, Mel_workspace.cwd // dune_build_dir // rel)
        else
          let source_path = package_path // dir
          and build_path =
            Mel_workspace.cwd // dune_build_dir
            // (Mel_workspace.to_workspace_proj_dir ~package_name // dir)
          in
          (source_path, build_path)
      in
      Buffer.add_string buffer merlin_s;
      Buffer.add_string buffer source_path;
      Buffer.add_string buffer merlin_b;
      Buffer.add_string buffer package_install_path);

  Buffer.add_string buffer merlin_b;
  Buffer.add_string buffer
    (Mel_workspace.absolute_artifacts_dir
       ~package_name:(Bsb_pkg_types.to_string package.package_name)
       ~include_dune_build_dir:true ~root_dir:Mel_workspace.cwd
       package.package_path)

let as_ppx arg =
  let fmt : _ format =
    if Ext_sys.is_windows_or_cygwin then "\"%s -as-ppx \"" else "'%s -as-ppx '"
  in
  Printf.sprintf fmt arg

let merlin_file_gen ~(per_proj_dir : string)
    ({
       file_groups = res_files;
       generate_merlin;
       ppx_config;
       pp_file;
       bs_dependencies;
       bs_dev_dependencies;
       bsc_flags;
       built_in_dependency;
       reason_react_jsx;
       namespace;
       warning;
       package_name;
     } :
      Bsb_config_types.t) =
  if generate_merlin then (
    let buffer = Buffer.create 1024 in
    output_merlin_namespace buffer namespace;
    let dune_build_dir = Lazy.force Mel_workspace.dune_build_dir in
    if ppx_config.ppxlib <> [] then (
      Buffer.add_string buffer merlin_flg_ppx;
      Buffer.add_string buffer
        (as_ppx
           (dune_build_dir // Literals.melange_eobjs_dir
          // Mel_workspace.ppx_exe)));
    Ext_list.iter ppx_config.ppx_files (fun ppx ->
        Buffer.add_string buffer merlin_flg_ppx;
        if ppx.args = [] then Buffer.add_string buffer ppx.name
        else
          let fmt : _ format =
            if Ext_sys.is_windows_or_cygwin then "\"%s %s\"" else "'%s %s'"
          in
          Buffer.add_string buffer
            (Printf.sprintf fmt ppx.name (String.concat " " ppx.args)));
    Ext_option.iter pp_file (fun x ->
        Buffer.add_string buffer (merlin_flg_pp ^ x));
    Buffer.add_string buffer
      (merlin_flg_ppx
      ^
      match reason_react_jsx with
      | None -> as_ppx Bsb_global_paths.vendor_bsc
      | Some opt ->
          let fmt : _ format =
            if Ext_sys.is_windows_or_cygwin then "\"%s -as-ppx -bs-jsx %d\""
            else "'%s -as-ppx -bs-jsx %d'"
          in
          Printf.sprintf fmt Bsb_global_paths.vendor_bsc
            (match opt with Jsx_v3 -> 3));
    (if built_in_dependency then
     let paths = [ Lazy.force Js_config.stdlib_path ] in
     Ext_list.iter paths (fun path ->
         Buffer.add_string buffer (merlin_s ^ path);
         Buffer.add_string buffer (merlin_b ^ path)));
    let bsc_string_flag = bsc_flg_to_merlin_ocamlc_flg bsc_flags in
    Buffer.add_string buffer bsc_string_flag;
    Buffer.add_string buffer (warning_to_merlin_flg warning);
    Ext_list.iter bs_dependencies (package_merlin buffer ~dune_build_dir);
    (* TODO: shall we generate .merlin for dev packages? *)
    Ext_list.iter bs_dev_dependencies (package_merlin buffer ~dune_build_dir);
    Ext_list.iter res_files.files (fun x ->
        if not (Bsb_file_groups.is_empty x) then (
          Buffer.add_string buffer merlin_s;
          Buffer.add_string buffer (per_proj_dir // x.dir);
          Buffer.add_string buffer merlin_b;
          Buffer.add_string buffer (per_proj_dir // dune_build_dir // x.dir)));
    Buffer.add_string buffer merlin_b;
    Buffer.add_string buffer
      (dune_build_dir
      // Mel_workspace.rel_artifacts_dir ~package_name ~root_dir:per_proj_dir
           ~proj_dir:per_proj_dir per_proj_dir);
    Buffer.add_string buffer "\n";
    revise_merlin (per_proj_dir // merlin) buffer)
