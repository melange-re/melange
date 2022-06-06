(* Copyright (C) 2017 Hongbo Zhang, Authors of ReScript
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

let ( // ) = Ext_path.combine

let clean_bs_garbage proj_dir =
  Bsb_log.info "@{<info>Cleaning:@} in %s@." proj_dir;
  let try_remove x =
    let x = proj_dir // x in
    if Sys.file_exists x then Bsb_unix.remove_dir_recursive x
  in
  let try_revise_dune dune_file =
    if Sys.file_exists dune_file then
      let buf = Buffer.create 0 in
      Bsb_ninja_targets.revise_dune dune_file buf
  in
  try
    (* TODO: revise merlin too *)
    try_revise_dune (proj_dir // Literals.dune);
    try_remove (proj_dir // Literals.dune_mel)
  with e ->
    Bsb_log.warn "@{<warning>Failed@} to clean due to %s" (Printexc.to_string e)

let clean_self ~dune_args proj_dir =
  let args = "clean" :: dune_args in
  Bsb_unix.dune_command args
    ~on_exit:(fun _process ~exit_status:_ ~term_signal:_ ->
      clean_bs_garbage proj_dir)

let load_import_map proj_dir =
  let json =
    Ext_json_parse.parse_json_from_file (proj_dir // Literals.bsconfig_json)
  in
  Bsb_path_resolver.extract_paths_from_importmap proj_dir json

let clean ~dune_args proj_dir =
  load_import_map proj_dir;
  clean_self ~dune_args proj_dir
