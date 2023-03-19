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

type fn = ?target:string -> Out_channel.t -> unit

let ( // ) = Ext_path.combine

let mk_ml_cmj_cmd ~(global_config : Bsb_ninja_global_vars.t) ~package_specs
    ?intf_suffix ~kind ~is_dev oc ?(target = "%{targets}") cur_dir =
  let package_name = global_config.package_name in
  let ns_flag =
    match global_config.namespace with None -> "" | Some n -> " -bs-ns " ^ n
  in
  let rel_incls ?namespace dirs =
    Bsb_build_util.rel_include_dirs ~package_name
      ~root_dir:global_config.root_dir ~per_proj_dir:global_config.per_proj_dir
      ~cur_dir ?namespace dirs
  in
  output_string oc "(action\n ";
  output_string oc " (run ";
  output_string oc global_config.bsc;
  output_string oc ns_flag;
  if not global_config.has_builtin then output_string oc " -nostdlib";
  Option.iter
    (fun intf_suffix ->
      output_string oc " -intf-suffix ";
      output_string oc intf_suffix)
    intf_suffix;
  if is_dev && global_config.g_dev_incls <> [] then (
    let dev_incls = rel_incls global_config.g_dev_incls in
    output_string oc " ";
    output_string oc dev_incls);
  output_string oc " -bs-legacy ";
  output_string oc (rel_incls global_config.g_sourcedirs_incls);
  output_string oc " ";
  output_string oc
    (rel_incls ?namespace:global_config.namespace global_config.g_lib_incls);
  if is_dev then (
    output_string oc " ";
    output_string oc (rel_incls global_config.g_dpkg_incls));
  output_char oc ' ';
  output_string oc global_config.bsc_flags;
  output_string oc " ";
  output_string oc global_config.warnings;

  (match kind with
  | `intf -> ()
  | _ ->
      output_string oc " -bs-package-name ";
      output_string oc (Ext_filename.maybe_quote global_config.package_name);
      output_string oc
        (Bsb_package_specs.package_flag_of_package_specs package_specs
           ~dirname:cur_dir));

  Option.iter
    (fun gentypeconfig ->
      output_string oc " ";
      output_string oc gentypeconfig)
    global_config.gentypeconfig;
  output_string oc " -o ";
  output_string oc target;
  output_string oc " %{inputs}";
  output_string oc "))"

let cm_file = mk_ml_cmj_cmd ~is_dev:false ~kind:`impl
let cm_file_dev = mk_ml_cmj_cmd ~is_dev:true ~kind:`impl
let cmi_file = mk_ml_cmj_cmd ~is_dev:false ~kind:`intf ?intf_suffix:None
let cmi_file_dev = mk_ml_cmj_cmd ~is_dev:true ~kind:`intf ?intf_suffix:None

let process_rescript oc =
  output_string oc
    {|(action
  (with-stdout-to %{targets}
   (run rescript_syntax -print=binary %{inputs})))|}

let process_reason oc =
  output_string oc
    {|(action
  (with-stdout-to %{targets}
   (run refmt --print=binary %{inputs})))|}

let ast (global_config : Bsb_ninja_global_vars.t) oc cur_dir =
  let rel_artifacts_dir =
    Mel_workspace.rel_artifacts_dir ~package_name:global_config.package_name
      ~root_dir:global_config.root_dir ~proj_dir:global_config.per_proj_dir
      cur_dir
  in
  output_string oc "(action\n (run ";
  output_string oc global_config.bsc;
  output_string oc " -bs-legacy ";
  output_string oc global_config.warnings;
  (match global_config.ppx_config with
  | Bsb_config_types.{ ppxlib = []; ppx_files = [] } -> ()
  | _not_empty ->
      output_char oc ' ';
      output_string oc
        (Bsb_build_util.ppx_flags ~artifacts_dir:rel_artifacts_dir
           global_config.ppx_config));
  (match global_config.pp_file with
  | None -> ()
  | Some flag ->
      output_char oc ' ';
      output_string oc (Bsb_build_util.pp_flag flag));

  output_char oc ' ';
  output_string oc global_config.bsc_flags;
  output_string oc " -absname -bs-ast -o %{targets} %{inputs}";
  output_string oc "))"

let meldep, meldep_dev =
  let meldep ~is_dev (global_config : Bsb_ninja_global_vars.t) oc cur_dir =
    let virtual_proj_dir =
      Mel_workspace.virtual_proj_dir ~root_dir:global_config.root_dir
        ~package_dir:global_config.per_proj_dir
        ~package_name:global_config.package_name
    in
    let root =
      Ext_path.rel_normalized_absolute_path
        ~from:(virtual_proj_dir // cur_dir)
        global_config.root_dir
    in
    let rel_proj_dir =
      Ext_path.rel_normalized_absolute_path
        ~from:(virtual_proj_dir // cur_dir)
        virtual_proj_dir
    in
    let ns_flag =
      match global_config.namespace with None -> "" | Some n -> " -bs-ns " ^ n
    in
    let s =
      Format.asprintf
        "(action (run %s %s -root-dir %s -p %s -proj-dir %s %s %%{inputs}))"
        global_config.bsdep
        (if is_dev then "-g" else "")
        root global_config.package_name rel_proj_dir ns_flag
    in
    output_string oc s
  in
  (meldep ~is_dev:false, meldep ~is_dev:true)

let namespace (global_config : Bsb_ninja_global_vars.t) oc =
  let s =
    global_config.bsc
    ^ " -bs-legacy -w -49 -color always -no-alias-deps %{inputs}"
  in
  output_string oc "(action (run ";
  output_string oc s;
  output_string oc "))"

module Generators = struct
  let regexp = Str.regexp "\\(\\$in\\)\\|\\(\\$out\\)"

  let maybe_match ~group s =
    match Str.matched_group group s with
    | matched -> Some matched
    | exception Not_found -> None
end

let generators custom_rules =
  Map_string.mapi custom_rules (fun _name command oc ->
      let actual_command =
        Str.global_substitute Generators.regexp
          (fun match_ ->
            match
              Generators.
                (maybe_match ~group:1 match_, maybe_match ~group:2 match_)
            with
            | Some _, None -> "%{inputs}"
            | None, Some _ -> "%{targets}"
            | _ -> assert false)
          command
      in
      let s = Format.asprintf "(action (system %S))" actual_command in
      output_string oc s)
