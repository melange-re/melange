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

open Bsb_helper
open Cmdliner

let root_dir =
  let doc = "Directory for the project root" in
  let docv = "dir" in
  Arg.(required & opt (some string) None & info [ "root-dir" ] ~doc ~docv)

let proj_dir =
  let doc = "Directory for the current package being built" in
  let docv = "dir" in
  Arg.(required & opt (some string) None & info [ "proj-dir" ] ~doc ~docv)

let cwd =
  let doc = "Current working directory (i.e. which source dir)" in
  let docv = "dir" in
  Arg.(value & opt string (Sys.getcwd ()) & info [ "cwd" ] ~doc ~docv)

let namespace =
  let doc = "Melange namespace for the current dependency" in
  let docv = "namespace" in
  Arg.(value & opt (some string) None & info [ "n"; "bs-ns" ] ~doc ~docv)

let dev =
  let doc = "Whether we're building in dev mode" in
  Arg.(value & flag & info [ "g" ] ~doc)

let filenames =
  let docv = "filenames" in
  Arg.(value & pos_all string [] & info [] ~docv)

let main root_dir proj_dir cwd namespace is_dev filenames =
  let impl, intf =
    match filenames with
    | [ impl; intf ] -> (impl, intf)
    | [ impl ] -> (impl, "")
    | _ -> assert false
  in
  Bsb_helper_depfile_gen.emit_d ~root_dir ~proj_dir ~cur_dir:cwd ~is_dev
    namespace impl intf

let cmd =
  let term =
    Term.(const main $ root_dir $ proj_dir $ cwd $ namespace $ dev $ filenames)
  in
  let info = Cmd.info "meldep" in
  Cmd.v info term

let () =
  let argv = Ext_cli_args.normalize_argv Sys.argv in
  exit (Cmdliner.Cmd.eval ~argv cmd)
