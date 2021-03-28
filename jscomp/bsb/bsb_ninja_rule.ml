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



module Generators = struct
  let regexp = Str.regexp "\\(\\$in\\)\\|\\(\\$out\\)"

  let maybe_match ~group s =
    match Str.matched_group group s with
    | matched -> Some matched
    | exception Not_found -> None
end


type t = {
  rule_name : string;
  name : Buffer.t -> ?target:string -> string -> unit
}

let output_rule (x : t) buf ?target cur_dir =
 let _name = x.name buf ?target cur_dir in
 ()

let get_name (x : t) ?target cur_dir buf = x.name buf ?target cur_dir


(** allocate an unique name for such rule*)
let define
    ~command
    ?dyndep
    ?restat
    rule_name : t
  =

  let self = {
    rule_name ;
    name = fun buf ?target cur_dir ->
         command buf ?target cur_dir
  } in

  self




type command = string

type builtin = {
  build_ast : t;
  (** TODO: Implement it on top of pp_flags *)
  build_ast_from_re : t ;
  (* build_ast_from_rei : t ; *)


  (** platform dependent, on Win32,
      invoking cmd.exe
  *)
  copy_resources : t;
  (** Rules below all need restat *)
  build_bin_deps : t ;
  build_bin_deps_dev : t;
  mj : t;
  mj_dev : t;
  mij : t ;
  mij_dev : t ;
  mi : t;
  mi_dev : t ;

  build_package : t ;
  customs : t Map_string.t
}

let external_includes (global_config : Bsb_ninja_global_vars.t) =
  (* for external includes, if it is absolute path, leave it as is
     for relative path './xx', we need '../.././x' since we are in
     [lib/bs], [build] is different from merlin though
  *)
  Ext_list.map
    global_config.external_incls
    (fun x -> if Filename.is_relative x then Bsb_config.rev_lib_bs_prefix x else x)

let make_custom_rules
  ~(global_config : Bsb_ninja_global_vars.t)
  ~(has_postbuild : string option)
  ~(pp_file: string option)
  ~(has_builtin : bool)
  ~ppx_files
  ~(reason_react_jsx : Bsb_config_types.reason_react_jsx option)
  ~package_specs
  (custom_rules : command Map_string.t) :
  builtin =
  (** FIXME: We don't need set [-o ${out}] when building ast
      since the default is already good -- it does not*)
  (** NOTE(anmonteiro): The above comment is false, namespace needs `-o` *)
  let ns_flag =
    match global_config.namespace with None -> ""
    | Some n -> " -bs-ns " ^ n in
  let mk_ml_cmj_cmd
      ~(read_cmi : [`yes | `is_cmi | `no])
      ~is_dev
      ~postbuild : Buffer.t -> ?target:string -> string -> unit = fun buf ?(target="%{targets}") cur_dir ->
    let rel_incls ?namespace dirs =
      Bsb_build_util.rel_include_dirs
        ~per_proj_dir:global_config.src_root_dir
        ~cur_dir
        ?namespace
        dirs
    in
    Buffer.add_string buf "(action\n (progn ";
    Buffer.add_string buf "(dynamic-run ";
    Buffer.add_string buf global_config.bs_dep_parse;
    Buffer.add_string buf " %{dep_file}) (run ";
    Buffer.add_string buf global_config.bsc;
    Buffer.add_string buf ns_flag;
    if not has_builtin then
      Buffer.add_string buf " -nostdlib";
    if read_cmi = `yes then
      Buffer.add_string buf " -bs-read-cmi";
    if is_dev && global_config.g_dev_incls <> [] then begin
       let dev_incls = Bsb_build_util.include_dirs global_config.g_dev_incls in
        Buffer.add_string buf " ";
        Buffer.add_string buf dev_incls;
    end;
    Buffer.add_string buf " ";
    Buffer.add_string buf (rel_incls global_config.g_sourcedirs_incls);
    Buffer.add_string buf " ";
    Buffer.add_string buf (rel_incls ?namespace:global_config.namespace global_config.g_lib_incls);
    Buffer.add_string buf " ";
    Buffer.add_string buf (rel_incls (external_includes global_config));
    if is_dev then begin
      Buffer.add_string buf " ";
      Buffer.add_string buf (rel_incls global_config.g_dpkg_incls);
    end;
    if global_config.g_stdlib_incl <> [] then begin
      Buffer.add_string buf " ";
      Buffer.add_string buf (Bsb_build_util.include_dirs global_config.g_stdlib_incl)
    end;
    Buffer.add_string buf " ";
    Buffer.add_string buf global_config.warnings;
    if read_cmi <> `is_cmi then begin
      Buffer.add_string buf " -bs-package-name ";
      Buffer.add_string buf global_config.package_name;
      Buffer.add_string buf
        (Bsb_package_specs.package_flag_of_package_specs package_specs ~dirname:cur_dir)
    end;


    Ext_option.iter global_config.gentypeconfig (fun gentypeconfig ->
      Buffer.add_string buf " ";
      Buffer.add_string buf gentypeconfig);
    Buffer.add_string buf " -o ";
    Buffer.add_string buf target;
    Buffer.add_string buf " %{inputs}";
    Buffer.add_string buf ")))";
    begin match postbuild with
    | None -> ()
    | Some cmd ->
      Buffer.add_string buf " && ";
      Buffer.add_string buf cmd ;
      Buffer.add_string buf " $out_last"
    end ;
  in
  let mk_ast ~has_reason_react_jsx buf ?target _cur_dir : unit =
    Buffer.add_string buf "(action\n (run ";
    Buffer.add_string buf global_config.bsc;
    Buffer.add_string buf " ";
    Buffer.add_string buf global_config.warnings;
    Buffer.add_string buf " -bs-v ";
    Buffer.add_string buf Bs_version.version;
    (match ppx_files with
     | [ ] -> ()
     | _ ->
       Ext_list.iter ppx_files (fun (x: Bsb_config_types.ppx) ->
           match string_of_float (Unix.stat x.name).st_mtime with
           | exception _ -> ()
           | st ->
             Buffer.add_char buf ',';
             Buffer.add_string buf st;
         );
       Buffer.add_char buf ' ';
       Buffer.add_string buf (Bsb_build_util.ppx_flags ppx_files));
    (match pp_file with
     | None -> ()
     | Some flag ->
       Buffer.add_char buf ' ';
       Buffer.add_string buf (Bsb_build_util.pp_flag flag)
    );
    (match has_reason_react_jsx, reason_react_jsx with
     | false, _
     | _, None -> ()
     | _, Some Jsx_v3
       -> Buffer.add_string buf " -bs-jsx 3"
    );

    Buffer.add_char buf ' ';
    Buffer.add_string buf global_config.bsc_flags;
    Buffer.add_string buf " -absname -bs-ast -o %{targets} %{inputs}";
    Buffer.add_string buf "))"
  in
  let build_ast =
    define
      ~command:(mk_ast ~has_reason_react_jsx:false )
      "ast" in
  let build_ast_from_re =
    define
      ~command:(mk_ast  ~has_reason_react_jsx:true)
      "astj" in

  let copy_resources =
    define
      ~command:(fun buf ?target _cur_dir ->
        let s = if Ext_sys.is_windows_or_cygwin then
          "cmd.exe /C copy /Y $i $out >NUL"
        else "cp $i $out"
        in
        Buffer.add_string buf s
      )
      "copy_resource" in

  let build_bin_deps =
    define
      ~restat:()
      ~command:(fun buf ?target _cur_dir ->
        let s = Format.asprintf "(action (run %s -cwd %s %s %%{inputs}))"
          global_config.bsdep
          global_config.src_root_dir
          ns_flag
        in
        Buffer.add_string buf s)
      "deps" in
  let build_bin_deps_dev =
    define
      ~restat:()
      ~command:(fun buf ?target _cur_dir ->
        let s = Format.asprintf "(action (run %s -g -cwd %s %s %%{inputs}))"
          global_config.bsdep
          global_config.src_root_dir
          ns_flag
        in
        Buffer.add_string buf s)
      "deps_dev"
  in
  let aux ~name ~read_cmi  ~postbuild =
    define
      ~command:(mk_ml_cmj_cmd
                  ~read_cmi  ~is_dev:false
                  ~postbuild)
      ~dyndep:()
      ~restat:() (* Always restat when having mli *)
      name,
    define
      ~command:(mk_ml_cmj_cmd
                  ~read_cmi  ~is_dev:true
                  ~postbuild)
      ~dyndep:()
      ~restat:() (* Always restat when having mli *)
      (name ^ "_dev")
  in

  let mj, mj_dev =
    aux ~name:"mj" ~read_cmi:`yes ~postbuild:has_postbuild in
  let mij, mij_dev =
    aux
      ~read_cmi:`no
      ~name:"mij" ~postbuild:has_postbuild in
  let mi, mi_dev =
    aux
       ~read_cmi:`is_cmi  ~postbuild:None
      ~name:"mi" in
  let build_package =
    define
      ~command:(fun buf ?target _cur_dir ->
         let stdlib_incl =
           Bsb_build_util.include_dirs global_config.g_stdlib_incl
         in
         let s = global_config.bsc ^ Ext_string.single_space ^ stdlib_incl ^
         " -w -49 -color always -no-alias-deps %{inputs}"
         in
        Buffer.add_string buf "(action (run ";
        Buffer.add_string buf s;
        Buffer.add_string buf "))")
      ~restat:()
      "build_package"
  in
  {
    build_ast ;
    build_ast_from_re  ;
    (** platform dependent, on Win32,
        invoking cmd.exe
    *)
    copy_resources;
    (** Rules below all need restat *)
    build_bin_deps ;
    build_bin_deps_dev;
    mj  ;
    mj_dev  ;
    mij  ;
    mi  ;

    mij_dev;
    mi_dev ;

    build_package ;
    customs =
      Map_string.mapi custom_rules begin fun name command ->
        define ~command:(fun buf ?target _cur_dir ->
          let actual_command =
            Str.global_substitute Generators.regexp (fun match_ ->
              match Generators.(maybe_match ~group:1 match_, maybe_match ~group:2 match_) with
              | Some _, None -> "%{inputs}"
              | None, Some _ -> "%{targets}"
              | _ -> assert false)
            command
          in
          let s = Format.asprintf "(action (system %S))" actual_command in
          Buffer.add_string buf s)
        ("custom_" ^ name)
      end
  }


