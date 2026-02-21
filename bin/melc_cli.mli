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

open Melstd

type t = {
  include_dirs : string list;
  hidden_include_dirs : string list;
  alerts : string list;
  warnings : string list;
  output_name : string option;
  ppx : string list;
  open_modules : string list;
  bs_package_output : string list;
  mel_module_system : Module_system.t option;
  bs_syntax_only : bool;
  bs_package_name : string option;
  bs_module_name : string option;
  as_ppx : bool;
  as_pp : bool;
  no_alias_deps : bool;
  bs_gentype : string option;
  unboxed_types : bool;
  bs_unsafe_empty_array : bool;
  nostdlib : bool;
  color : string option;
  bs_eval : string option;
  bs_cmi_only : bool;
  bs_no_version_header : bool;
  bs_cross_module_opt : bool option;
  bs_diagnose : bool;
  where : bool;
  verbose : bool;
  keep_locs : bool option;
  bs_no_check_div_by_zero : bool;
  bs_noassertfalse : bool;
  noassert : bool;
  bs_loc : bool;
  impl : string option;
  intf : string option;
  intf_suffix : string option;
  cmi_file : string option;
  g : bool;
  source_map : bool;
  source_map_include_sources : bool;
  opaque : bool;
  preamble : string option;
  strict_sequence : bool;
  strict_formats : bool;
  dtypedtree : bool;
  dparsetree : bool;
  drawlambda : bool;
  dsource : bool;
  version : bool;
  pp : string option;
  absname : bool;
  bin_annot : bool option;
  i : bool;
  nopervasives : bool;
  modules : bool;
  nolabels : bool;
  principal : bool;
  rectypes : bool;
  short_paths : bool;
  unsafe : bool;
  warn_help : bool;
  warn_error : string list;
  bs_stop_after_cmj : bool;
  runtime : string option;
  filenames : string list;
  store_occurrences : bool;
}

val cmd : t Cmdliner.Term.t
val normalize_argv : string array -> string array
