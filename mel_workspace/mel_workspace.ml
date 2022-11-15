(* Copyright (C) 2022- Authors of Melange
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

let ( // ) = Filename.concat
let cwd = Sys.getcwd ()

let dune_build_dir =
  lazy
    (match Sys.getenv_opt "DUNE_BUILD_DIR" with
    | Some value -> value // "default"
    | None -> "_build" // "default")

let ppx_exe = "ppx.exe"

let is_dep_inside_workspace ~root_dir ~package_dir =
  String.starts_with ~prefix:root_dir package_dir

let to_workspace_proj_dir ~package_name = Literals.node_modules // package_name

let virtual_proj_dir ~root_dir ~package_dir ~package_name =
  if is_dep_inside_workspace ~root_dir ~package_dir then package_dir
  else root_dir // to_workspace_proj_dir ~package_name

let absolute_artifacts_dir ?(include_dune_build_dir = false) ~package_name
    ~root_dir proj_dir =
  if not (is_dep_inside_workspace ~root_dir ~package_dir:proj_dir) then
    if include_dune_build_dir then
      root_dir // Lazy.force dune_build_dir // Literals.melange_eobjs_dir
      // to_workspace_proj_dir ~package_name
    else
      root_dir // Literals.melange_eobjs_dir
      // to_workspace_proj_dir ~package_name
  else
    let rel_package_dir_from_root =
      Ext_path.rel_normalized_absolute_path ~from:root_dir proj_dir
    in
    let path =
      if include_dune_build_dir then
        root_dir // Lazy.force dune_build_dir // Literals.melange_eobjs_dir
        // rel_package_dir_from_root
      else root_dir // Literals.melange_eobjs_dir // rel_package_dir_from_root
    in
    Ext_path.normalize_absolute_path path

let rel_artifacts_dir ?include_dune_build_dir ~package_name ~root_dir ~proj_dir
    from =
  let proj_dir =
    virtual_proj_dir ~root_dir ~package_dir:proj_dir ~package_name
  in
  let absolute =
    absolute_artifacts_dir ?include_dune_build_dir ~package_name ~root_dir
      proj_dir
  in
  let from = if Filename.is_relative from then proj_dir // from else from in
  Ext_path.rel_normalized_absolute_path ~from absolute

let rel_root_artifacts_dir ~root_dir from =
  rel_artifacts_dir ~package_name:"root" ~root_dir ~proj_dir:root_dir from
