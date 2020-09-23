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






type t = {
  mutable used : bool;
  rule_name : string;
  name : ?target:string -> string -> Buffer.t -> string
}

let output_rule (x : t) ?target cur_dir oc =
 let _name = x.name ?target cur_dir oc in
 ()

let get_name (x : t) ?target cur_dir buf = x.name ?target cur_dir buf
let print_rule (buf : Buffer.t)
  ?(restat : unit option)
  ?dyndep
  ~command
  name  =
  Buffer.add_string buf command
  (* Ext_option.iter dyndep (fun f -> *)
      (* Buffer.add_string buf "  dyndep = "; Buffer.add_string buf f; Buffer.add_string buf  "\n" *)
    (* ); *)



(** allocate an unique name for such rule*)
let define
    ~command
    ?dyndep
    ?restat
    rule_name : t
  =

  let rec self = {
    used  = false;
    rule_name ;
    name = fun ?target cur_dir buf ->
      if not self.used then
        begin
          print_rule buf  ?dyndep ?restat ~command:(command ?target cur_dir) rule_name;
          (* self.used <- true *)
        end ;
      rule_name
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
  ml_cmj_js : t;
  ml_cmj_js_dev : t;
  ml_cmj_cmi_js : t ;
  ml_cmj_cmi_js_dev : t ;
  ml_cmi : t;
  ml_cmi_dev : t ;

  build_package : t ;
  customs : t Map_string.t
}


;;

let make_custom_rules
  ~(global_config : Bsb_ninja_global_vars.t)
  ~(has_postbuild : bool)
  ~(has_ppx : bool)
  ~(reason_react_jsx : Bsb_config_types.reason_react_jsx option)
  ~(digest : string)
  ~(refmt : string option) (* set refmt path when needed *)
  (custom_rules : command Map_string.t) :
  builtin =
  (** FIXME: We don't need set [-o ${out}] when building ast
      since the default is already good -- it does not*)
  (** NOTE(anmonteiro): The above comment is false, namespace needs `-o` *)
  let buf = Ext_buffer.create 100 in
  let mk_ml_cmj_cmd
      ~read_cmi
      ~is_dev
      ~postbuild : ?target:string -> string -> string = fun ?(target="%{targets}") cur_dir ->
    Ext_buffer.clear buf;
    Ext_buffer.add_string buf global_config.bsc;
    Ext_buffer.add_ninja_prefix_var buf "-nostdlib";
    Ext_buffer.add_ninja_prefix_var buf global_config.g_pkg_flg;
    if read_cmi then
      Ext_buffer.add_string buf " -bs-read-cmi";
    if is_dev && global_config.g_dev_incls <> [] then begin
       let dev_incls = Bsb_build_util.include_dirs global_config.g_dev_incls in
        Ext_buffer.add_ninja_prefix_var buf dev_incls;
    end;
    Ext_buffer.add_ninja_prefix_var buf
      (Bsb_build_util.sourcedir_include_dirs
        ~per_proj_dir:global_config.src_root_dir
        ~cur_dir
        ?namespace:global_config.namespace
        global_config.g_sourcedirs_incls);
    Ext_buffer.add_ninja_prefix_var buf global_config.g_lib_incls;
    if is_dev then
      Ext_buffer.add_ninja_prefix_var buf global_config.g_dpkg_incls;
    if global_config.g_stdlib_incl <> [] then
      Ext_buffer.add_ninja_prefix_var buf (Bsb_build_util.include_dirs global_config.g_stdlib_incl);
    Ext_buffer.add_ninja_prefix_var buf global_config.warnings;
    Ext_buffer.add_ninja_prefix_var buf global_config.bsc_flags;
    Ext_option.iter global_config.gentypeconfig (fun gentypeconfig ->
      Ext_buffer.add_ninja_prefix_var buf gentypeconfig);
    Ext_buffer.add_ninja_prefix_var buf "-o";
    Ext_buffer.add_ninja_prefix_var buf target;
    Ext_buffer.add_ninja_prefix_var buf "%{inputs}";
    if postbuild then
      Ext_buffer.add_string buf " $postbuild";
    Ext_buffer.contents buf
  in
  let mk_ast ?pp_flags ~has_ppx ~has_reason_react_jsx ?target _cur_dir : string =
    Ext_buffer.clear buf ;
    Ext_buffer.add_ninja_prefix_var buf global_config.bsc;
    Ext_buffer.add_ninja_prefix_var buf global_config.warnings;
    (match refmt with
    | None -> ()
    | Some x ->
      Ext_buffer.add_string buf " -bs-refmt ";
      Ext_buffer.add_string buf (Ext_filename.maybe_quote x);
    );
    Ext_option.iter pp_flags (fun pp_flags ->
      Ext_buffer.add_ninja_prefix_var buf pp_flags);
    (match has_reason_react_jsx, reason_react_jsx with
     | false, _
     | _, None -> ()
     | _, Some Jsx_v3
       -> Ext_buffer.add_string buf " -bs-jsx 3"
    );
    if has_ppx then
      Ext_buffer.add_ninja_prefix_var buf global_config.ppx_flags;
    Ext_buffer.add_ninja_prefix_var buf global_config.bsc_flags;
    Ext_buffer.add_string buf " -o %{targets} -bs-syntax-only -bs-binary-ast %{inputs}";
    Ext_buffer.contents buf
  in
  let build_ast =
    define
      ~command:(mk_ast ?pp_flags:global_config.pp_flags ~has_ppx ~has_reason_react_jsx:false )
      "build_ast" in
  let build_ast_from_re =
    define
      ~command:(mk_ast ?pp_flags:global_config.pp_flags ~has_ppx ~has_reason_react_jsx:true)
      "build_ast_from_re" in

  let copy_resources =
    define
      ~command:(fun ?target _cur_dir ->
        if Ext_sys.is_windows_or_cygwin then
          "cmd.exe /C copy /Y $in $out > null"
        else "cp %{deps} %{targets}"
      )
      "copy_resource" in
  let build_bin_deps =
    define
      ~restat:()
      ~command:(fun ?target _cur_dir ->
        global_config.bsdep ^ " -cwd " ^ global_config.src_root_dir ^
        " -hash " ^ digest ^ Ext_string.single_space ^
        global_config.g_ns ^ " %{inputs}")
      "mk_deps" in
  let build_bin_deps_dev =
    define
      ~restat:()
      ~command:(fun ?target _cur_dir ->
         global_config.bsdep ^ " -cwd " ^ global_config.src_root_dir ^
         " -g -hash " ^ digest ^ Ext_string.single_space ^
         global_config.g_ns ^ " %{inputs}")
        "mk_deps_dev" in
  let aux ~name ~read_cmi  ~postbuild =
    let postbuild = has_postbuild && postbuild in
    define
      ~command:(mk_ml_cmj_cmd
                  ~read_cmi  ~is_dev:false
                  ~postbuild)
      ~dyndep:"$in_e.d"
      ~restat:() (* Always restat when having mli *)
      name,
    define
      ~command:(mk_ml_cmj_cmd
                  ~read_cmi  ~is_dev:true
                  ~postbuild)
      ~dyndep:"$in_e.d"
      ~restat:() (* Always restat when having mli *)
      (name ^ "_dev")
  in
  let ml_cmj_js, ml_cmj_js_dev =
    aux ~name:"ml_cmj_only" ~read_cmi:true ~postbuild:true in
  let ml_cmj_cmi_js, ml_cmj_cmi_js_dev =
    aux
      ~read_cmi:false
      ~name:"ml_cmj_cmi" ~postbuild:true in
  let ml_cmi, ml_cmi_dev =
    aux
       ~read_cmi:false  ~postbuild:false
      ~name:"ml_cmi" in
  let build_package =
    define
      ~command:(fun ?target _cur_dir ->
         let stdlib_incl =
           Bsb_build_util.include_dirs global_config.g_stdlib_incl
         in
         global_config.bsc ^ Ext_string.single_space ^ stdlib_incl ^
         " -w -49 -color always -no-alias-deps %{inputs}")
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
    ml_cmj_js ;
    ml_cmj_js_dev ;
    ml_cmj_cmi_js ;
    ml_cmi ;

    ml_cmj_cmi_js_dev;
    ml_cmi_dev;

    build_package ;
    customs =
      Map_string.mapi custom_rules begin fun name command ->
        define ~command:(fun ?target _cur_dir -> command) ("custom_" ^ name)
      end
  }


