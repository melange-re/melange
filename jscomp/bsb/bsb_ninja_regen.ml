(* Copyright (C) 2017 Authors of BuckleScript
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

(** Regenerate ninja file by need based on [.bsdeps]
    return None if we dont need regenerate
    otherwise return Some info
*)
let regenerate_ninja
    ~(package_kind : Bsb_package_kind.t)
    ~buf
    ~root_dir
    per_proj_dir
  : Bsb_config_types.t =
  let lib_artifacts_dir = Bsb_config.lib_bs in
  let lib_bs_dir =  per_proj_dir // lib_artifacts_dir  in
  let config : Bsb_config_types.t =
    Bsb_config_parse.interpret_json
      ~package_kind
      ~per_proj_dir
  in
  (* create directory, lib/bs, lib/js, lib/es6 etc *)
  Bsb_build_util.mkp lib_bs_dir;
  (* PR2184: we still need record empty dir
      since it may add files in the future *)
  Bsb_merlin_gen.merlin_file_gen ~per_proj_dir config;
  Bsb_ninja_gen.output_ninja_and_namespace_map
    ~buf ~per_proj_dir ~root_dir ~package_kind config;

  config

