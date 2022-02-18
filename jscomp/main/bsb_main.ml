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

open Cmdliner
open Bsb

let () = Bsb_log.setup ()
let bs_version_string = Bs_version.version

type cli_options = {
  print_version : bool;
  verbose : bool;
  watch_mode : bool;
  clean : bool;
  make_world : bool;
  install : bool;
  init_path : string option;
  theme : string;
  list_themes : bool;
  print_bsb_location : bool;
  websocket : bool;
  dune_args : string array;
}

let print_version_string () =
  print_string bs_version_string;
  print_newline ();
  exit 0

let ( // ) = Ext_path.combine

let output_dune_project_if_does_not_exist proj_dir =
  let dune_project = proj_dir // Literals.dune_project in
  if Sys.file_exists dune_project then ()
  else
    let ochan = open_out_bin dune_project in
    output_string ochan "(lang dune 2.8)\n";
    output_string ochan "(using action-plugin 0.1)\n";
    close_out ochan

let output_dune_file buf =
  (* <root>/dune.bsb generation *)
  let proj_dir = Bsb_global_paths.cwd in
  let dune_bsb = proj_dir // Literals.dune_bsb in
  Bsb_ninja_targets.revise_dune dune_bsb buf;

  (* <root>/dune generation *)
  let dune = proj_dir // Literals.dune in
  let buf = Buffer.create 256 in
  Buffer.add_string buf "\n(include ";
  Buffer.add_string buf Literals.dune_bsb;
  Buffer.add_string buf ")\n";
  Bsb_ninja_targets.revise_dune dune buf;
  output_dune_project_if_does_not_exist proj_dir

let dune_command_exit dune_args =
  let common_args = [| Literals.dune; "build"; "@" ^ Literals.bsb_world |] in
  let args = Array.append common_args dune_args in
  Bsb_log.info "@{<info>Running:@} %s@."
    (String.concat " " (Array.to_list args));
  Unix.execvp Literals.dune args

let build_whole_project () =
  let root_dir = Bsb_global_paths.cwd in
  let buf = Buffer.create 0x1000 in
  let config, dep_configs = Bsb_world.make_world_deps ~buf ~cwd:root_dir in
  Bsb_ninja_regen.regenerate_ninja ~package_kind:Toplevel ~buf ~root_dir ~config
    root_dir;
  output_dune_file buf;
  config :: dep_configs

let print_init_theme_notice () =
  prerr_endline
    "The subcommands -init, -theme and -themes are deprecated now. Use the \
     template at https://github.com/melange-re/melange-basic-template to start \
     a new project.";
  flush stderr

let run_bsb ({ make_world; install; watch_mode; dune_args; _ } as options) =
  let cwd = Bsb_global_paths.cwd in
  try
    if options.print_version then print_version_string ();
    if options.verbose then Bsb_log.verbose ();
    if options.clean then Bsb_clean.clean ~dune_args cwd;
    if options.print_bsb_location then
      print_endline (Filename.dirname Sys.executable_name);
    match (options.init_path, options.list_themes) with
    | Some _, _ | _, true -> print_init_theme_notice ()
    | None, false ->
        let generate_dune_bsb = make_world || install in
        if (not make_world) && not install then (if watch_mode then exit 0)
        else (
          (if generate_dune_bsb then
           let configs = build_whole_project () in
           Bsb_world.install_targets Bsb_global_paths.cwd configs);
          if watch_mode then exit 0
          else if make_world then dune_command_exit dune_args)
  with
  | Bsb_exception.Error e ->
      Bsb_exception.print Format.err_formatter e;
      Format.pp_print_newline Format.err_formatter ();
      exit 2
  | Ext_json_parse.Error (start, _, e) ->
      Format.fprintf Format.err_formatter
        "File %S, line %d\n@{<error>Error:@} %a@." start.pos_fname
        start.pos_lnum Ext_json_parse.report_error e;
      exit 2
  | Sys_error s ->
      Format.fprintf Format.err_formatter "@{<error>Error:@} %s@." s;
      exit 2
  | e -> Ext_pervasives.reraise e

module CLI = struct
  let version_flag =
    let doc = "Print version and exit" in
    Arg.(value & flag & info [ "v"; "version" ] ~doc)

  let verbose_flag =
    let doc = "Set the output (from bsb) to be verbose" in
    Arg.(value & flag & info [ "verbose" ] ~doc)

  let watch_mode_flag =
    let doc = "Currently does nothing. Enabled for compatibility." in
    Arg.(value & flag & info [ "w" ] ~doc)

  let clean_flag =
    let doc = "Clean all bs dependencies" in
    Arg.(value & flag & info [ "clean"; "clean-world" ] ~doc)

  let make_world_flag =
    let doc = "Build all dependencies and itself" in
    Arg.(value & flag & info [ "make-world" ] ~doc)

  let install_flag =
    let doc = "Generate the (dune) rules for building the project" in
    Arg.(value & flag & info [ "install" ] ~doc)

  let init_arg =
    let docv = "init path" in
    let doc =
      "Currently does nothing. Enabled for compatibility. Use the template at \
       https://github.com/melange-re/melange-basic-template to start a new \
       project."
    in
    Arg.(value & opt (some string) None & info [ "init" ] ~doc ~docv)

  let theme_arg =
    let docv = "theme" in
    let doc =
      "Currently does nothing. Enabled for compatibility. Use the template at \
       https://github.com/melange-re/melange-basic-template to start a new \
       project."
    in
    Arg.(value & opt string "basic" & info [ "theme" ] ~doc ~docv)

  let themes_flag =
    let doc =
      "Currently does nothing. Enabled for compatibility. Use the template at \
       https://github.com/melange-re/melange-basic-template to start a new \
       project."
    in
    Arg.(value & flag & info [ "themes" ] ~doc)

  let where_flag =
    let doc = "Show where bsb is located" in
    Arg.(value & flag & info [ "where" ] ~doc)

  let ws_flag =
    let doc = "Send build output to websocket" in
    Arg.(value & flag & info [ "ws" ] ~doc)

  let parse_options print_version verbose watch_mode clean make_world install
      init_path theme list_themes print_bsb_location websocket dune_args =
    {
      print_version;
      verbose;
      watch_mode;
      clean;
      make_world;
      install;
      init_path;
      theme;
      list_themes;
      print_bsb_location;
      websocket;
      dune_args;
    }

  let run dune_args =
    let make_bsb_options =
      Term.(
        const parse_options $ version_flag $ verbose_flag $ watch_mode_flag
        $ clean_flag $ make_world_flag $ install_flag $ init_arg $ theme_arg
        $ themes_flag $ where_flag $ ws_flag $ const dune_args)
    in
    (Term.(const run_bsb $ make_bsb_options), Term.info "bsb")
end

let () =
  let bsb_args, dune_args = Ext_cli_args.split_argv_at_separator Sys.argv in
  Term.(
    exit
    @@ eval ~argv:(Ext_cli_args.normalize_argv bsb_args) (CLI.run dune_args))
