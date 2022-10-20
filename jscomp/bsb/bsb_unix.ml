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

(* it assume you have permissions, so always catch it to fail
    gracefully *)
let rec remove_dir_recursive dir =
  match Sys.is_directory dir with
  | true ->
      let files = Sys.readdir dir in
      for i = 0 to Array.length files - 1 do
        remove_dir_recursive (Filename.concat dir (Array.unsafe_get files i))
      done;
      Unix.rmdir dir
  | false -> Sys.remove dir
  | exception _ -> ()

let redirect =
  Luv.Process.
    [
      inherit_fd ~fd:stdout ~from_parent_fd:stdout ();
      inherit_fd ~fd:stderr ~from_parent_fd:stderr ();
      inherit_fd ~fd:stdin ~from_parent_fd:stdin ();
    ]

let default_on_exit (_ : Luv.Process.t) ~exit_status ~term_signal:(_ : int) =
  exit (Int64.to_int exit_status)

let dune_command ?(on_exit = default_on_exit) args =
  Bsb_log.info "@{<info>Running:@} %s@." (String.concat " " args);
  match
    Luv.Process.spawn ~on_exit ~redirect Literals.dune (Literals.dune :: args)
  with
  | Ok process -> process
  | Error `ENOENT ->
      Bsb_log.error
        "@{<error>Error:@} @{<filename>`dune`@} not found.@\n\
         Dune is required to build Melange projects.@.";
      exit 2
  | Error e ->
      Bsb_log.error
        "@{<error>Internal Error:@} @{<error>%s@} (%s). Please report this \
         message.@."
        (Luv.Error.err_name e) (Luv.Error.strerror e);
      exit 2
