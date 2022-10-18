(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
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

type install_dir = {
  package_name : string;
  package_path : string;
  dir : string;
}

type dependency = {
  package_name : Bsb_pkg_types.t;
  package_path : string;
  package_dirs : string list;
  package_install_dirs : install_dir list;
}

type dependencies = dependency list
type reason_react_jsx = Jsx_v3
(* string option  *)

type gentype_config = { path : string (* resolved *) }
type command = string
type ppx = { name : string; args : string list }
type ppx_config = { ppxlib : ppx list; ppx_files : ppx list }

type t = {
  dir : string;
  package_name : string;
  (* [captial-package] *)
  namespace : string option;
  (* CapitalPackage *)
  bsc_flags : string list;
  ppx_config : ppx_config;
  pp_file : string option;
  bs_dependencies : dependencies;
  bs_dev_dependencies : dependencies;
  built_in_dependency : bool;
  warning : Bsb_warning.t;
  (*TODO: maybe we should always resolve bs-platform
    so that we can calculate correct relative path in
    [.merlin]
  *)
  js_post_build_cmd : string option;
  package_specs : Bsb_package_specs.t;
  file_groups : Bsb_file_groups.t;
  generate_merlin : bool;
  reason_react_jsx : reason_react_jsx option;
  (* whether apply PPX transform or not*)
  generators : command Map_string.t;
  cut_generators : bool;
  (* note when used as a dev mode, we will always ignore it *)
  gentype_config : gentype_config option;
}
