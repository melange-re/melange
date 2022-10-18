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

let ( // ) = Ext_path.combine

module Generators = struct
  let regexp = Str.regexp "\\(\\$in\\)\\|\\(\\$out\\)"

  let maybe_match ~group s =
    match Str.matched_group group s with
    | matched -> Some matched
    | exception Not_found -> None
end

type t = {
  rule :
    Buffer.t ->
    ?error_syntax_kind:Bsb_db.syntax_kind ->
    ?target:string ->
    string ->
    unit;
}

let output_rule (x : t) buf ?error_syntax_kind ?target cur_dir =
  let _name = x.rule buf ?error_syntax_kind ?target cur_dir in
  ()

(* allocate an unique name for such rule*)
let define ~command : t =
  let self = { rule = command } in
  self

type command = string

type builtin = {
  build_ast : t; (* TODO: Implement it on top of pp_flags *)
  (* platform dependent, on Win32,
      invoking cmd.exe
  *)
  build_bin_deps : t;
  build_bin_deps_dev : t;
  mj : t;
  mj_dev : t;
  mij : t;
  mij_dev : t;
  mi : t;
  mi_dev : t;
  build_package : t;
  customs : t Map_string.t;
}

let make_custom_rules ~(global_config : Bsb_ninja_global_vars.t)
    ~(has_postbuild : string option) ~(pp_file : string option)
    ~(has_builtin : bool)
    ~(reason_react_jsx : Bsb_config_types.reason_react_jsx option)
    ~package_specs (custom_rules : command Map_string.t) : builtin =
  (* FIXME: We don't need set [-o ${out}] when building ast
      since the default is already good -- it does not*)
  (* NOTE(anmonteiro): The above comment is false, namespace needs `-o` *)
  let package_name = global_config.package_name in
  let ns_flag =
    match global_config.namespace with None -> "" | Some n -> " -bs-ns " ^ n
  in
  let mk_ml_cmj_cmd ~(read_cmi : [ `yes | `is_cmi | `no ]) ~is_dev ~postbuild
      buf ?error_syntax_kind ?(target = "%{targets}") cur_dir =
    let rel_incls ?namespace dirs =
      Bsb_build_util.rel_include_dirs ~package_name
        ~root_dir:global_config.root_dir
        ~per_proj_dir:global_config.per_proj_dir ~cur_dir ?namespace dirs
    in
    Buffer.add_string buf "(action\n ";
    Buffer.add_string buf " (run ";
    Buffer.add_string buf global_config.bsc;
    Buffer.add_string buf ns_flag;
    if not has_builtin then Buffer.add_string buf " -nostdlib";
    if read_cmi = `yes then Buffer.add_string buf " -bs-read-cmi";
    if is_dev && global_config.g_dev_incls <> [] then (
      let dev_incls = rel_incls global_config.g_dev_incls in
      Buffer.add_string buf " ";
      Buffer.add_string buf dev_incls);
    if error_syntax_kind = Some Bsb_db.Reason then
      Buffer.add_string buf " -bs-re-out";
    Buffer.add_string buf " ";
    Buffer.add_string buf (rel_incls global_config.g_sourcedirs_incls);
    Buffer.add_string buf " ";
    Buffer.add_string buf
      (rel_incls ?namespace:global_config.namespace global_config.g_lib_incls);
    if is_dev then (
      Buffer.add_string buf " ";
      Buffer.add_string buf (rel_incls global_config.g_dpkg_incls));
    Buffer.add_char buf ' ';
    Buffer.add_string buf global_config.bsc_flags;
    Buffer.add_string buf " ";
    Buffer.add_string buf global_config.warnings;
    if read_cmi <> `is_cmi then (
      Buffer.add_string buf " -bs-stop-after-cmj -bs-package-name ";
      Buffer.add_string buf
        (Ext_filename.maybe_quote global_config.package_name);
      Buffer.add_string buf
        (Bsb_package_specs.package_flag_of_package_specs package_specs
           ~dirname:cur_dir));

    Ext_option.iter global_config.gentypeconfig (fun gentypeconfig ->
        Buffer.add_string buf " ";
        Buffer.add_string buf gentypeconfig);
    Buffer.add_string buf " -o ";
    Buffer.add_string buf target;
    Buffer.add_string buf " %{inputs}";
    Buffer.add_string buf "))";
    match postbuild with
    | None -> ()
    | Some cmd ->
        Buffer.add_string buf " && ";
        Buffer.add_string buf cmd;
        Buffer.add_string buf " $out_last"
  in
  let mk_ast buf ?error_syntax_kind:_ ?target:_ cur_dir : unit =
    let rel_artifacts_dir =
      Mel_workspace.rel_artifacts_dir ~package_name
        ~root_dir:global_config.root_dir ~proj_dir:global_config.per_proj_dir
        cur_dir
    in
    Buffer.add_string buf "(action\n (run ";
    Buffer.add_string buf global_config.bsc;
    Buffer.add_string buf " ";
    Buffer.add_string buf global_config.warnings;
    (match global_config.ppx_config with
    | Bsb_config_types.{ ppxlib = []; ppx_files = [] } -> ()
    | _not_empty ->
        Buffer.add_char buf ' ';
        Buffer.add_string buf
          (Bsb_build_util.ppx_flags ~artifacts_dir:rel_artifacts_dir
             global_config.ppx_config));
    (match pp_file with
    | None -> ()
    | Some flag ->
        Buffer.add_char buf ' ';
        Buffer.add_string buf (Bsb_build_util.pp_flag flag));
    (match reason_react_jsx with
    | None -> ()
    | Some Jsx_v3 -> Buffer.add_string buf " -bs-jsx 3");

    Buffer.add_char buf ' ';
    Buffer.add_string buf global_config.bsc_flags;
    Buffer.add_string buf " -absname -bs-ast -o %{targets} %{inputs}";
    Buffer.add_string buf "))"
  in
  let build_ast = define ~command:mk_ast in

  let aux ~read_cmi ~postbuild =
    ( define ~command:(mk_ml_cmj_cmd ~read_cmi ~is_dev:false ~postbuild),
      define ~command:(mk_ml_cmj_cmd ~read_cmi ~is_dev:true ~postbuild) )
  in

  let meldep ~is_dev buf ?error_syntax_kind:_ ?target:_ cur_dir =
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
    let s =
      Format.asprintf
        "(action (run %s %s -root-dir %s -p %s -proj-dir %s %s %%{inputs}))"
        global_config.bsdep
        (if is_dev then "-g" else "")
        root package_name rel_proj_dir ns_flag
    in
    Buffer.add_string buf s
  in

  let build_bin_deps = define ~command:(meldep ~is_dev:false) in
  let build_bin_deps_dev = define ~command:(meldep ~is_dev:true) in

  let mj, mj_dev = aux ~read_cmi:`yes ~postbuild:has_postbuild in
  let mij, mij_dev = aux ~read_cmi:`no ~postbuild:has_postbuild in
  let mi, mi_dev = aux ~read_cmi:`is_cmi ~postbuild:None in

  let build_package =
    define ~command:(fun buf ?error_syntax_kind:_ ?target:_ _cur_dir ->
        let s =
          global_config.bsc ^ " -w -49 -color always -no-alias-deps %{inputs}"
        in
        Buffer.add_string buf "(action (run ";
        Buffer.add_string buf s;
        Buffer.add_string buf "))")
  in
  {
    build_ast;
    build_bin_deps;
    build_bin_deps_dev;
    mj;
    mj_dev;
    mij;
    mi;
    mij_dev;
    mi_dev;
    build_package;
    customs =
      Map_string.mapi custom_rules (fun _name command ->
          define ~command:(fun buf ?error_syntax_kind:_ ?target:_ _cur_dir ->
              let actual_command =
                Str.global_substitute Generators.regexp
                  (fun match_ ->
                    match
                      Generators.
                        ( maybe_match ~group:1 match_,
                          maybe_match ~group:2 match_ )
                    with
                    | Some _, None -> "%{inputs}"
                    | None, Some _ -> "%{targets}"
                    | _ -> assert false)
                  command
              in
              let s = Format.asprintf "(action (system %S))" actual_command in
              Buffer.add_string buf s));
  }
