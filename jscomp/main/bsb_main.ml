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

let () = Bsb_log.setup ()
let separator = "--"
let bs_version_string = Bs_version.version

let print_version_string () =
  print_string bs_version_string;
  print_newline ();
  exit 0

let (//) = Ext_path.combine

let output_dune_project_if_does_not_exist proj_dir =
  let dune_project = proj_dir // Literals.dune_project in
  if Sys.file_exists dune_project then ()
  else
    let ochan = open_out_bin dune_project in
    output_string ochan "(lang dune 2.8)\n";
    output_string ochan "(using action-plugin 0.1)\n";
    close_out ochan

let output_dune_file buf =
  let proj_dir =  Bsb_global_paths.cwd in
  let dune_bsb = proj_dir // Literals.dune_bsb in
  Buffer.add_string buf "\n(data_only_dirs node_modules)";
  Bsb_ninja_targets.revise_dune dune_bsb buf;
  let dune = proj_dir // Literals.dune in

  let buf = Buffer.create 256 in
  Buffer.add_string buf "\n(include ";
  Buffer.add_string buf Literals.dune_bsb;
  Buffer.add_string buf ")\n";
  Bsb_ninja_targets.revise_dune dune buf;

  output_dune_project_if_does_not_exist proj_dir

let dune_command_exit dune_args  =
  let common_args = [|Literals.dune; "build"; ("@" ^ Literals.bsb_world)|] in
  let args =
    if Array.length dune_args = 0 then
      common_args
    else
      Array.append common_args dune_args
  in
  Bsb_log.info "@{<info>Running:@} %s@." (String.concat " " (Array.to_list args));
  Unix.execvp Literals.dune args


(**
   Cache files generated:
   - .bsdircache in project root dir
   - .bsdeps in builddir

   What will happen, some flags are really not good
   ninja -C _build
*)
let usage = "Usage : bsb.exe <bsb-options> -- <ninja_options>\n\
             For ninja options, try bsb.exe --  -h.  \n\
             Note they are supposed to be internals and not reliable.\n\
             ninja will be loaded either by just running `bsb.exe' or `bsb.exe .. -- ..`\n\
             It is always recommended to run ninja via bsb.exe"

let handle_anonymous_arg ~rev_args =
  match rev_args with
  | [] -> ()
  | arg:: _ ->
    Bsc_args.bad_arg ("Unknown arg \"" ^ arg ^ "\"")

let install_target config =
  Bsb_world.install_targets Bsb_global_paths.cwd config

let build_whole_project ~buf =
  let root_dir = Bsb_global_paths.cwd in
  Bsb_world.make_world_deps ~buf ~cwd:root_dir None;
  let config = Bsb_ninja_regen.regenerate_ninja
    ~package_kind:Toplevel
    ~buf
    ~root_dir
    root_dir
  in
  output_dune_file buf;
  config

let run_bsb version verbose watch clean make_world install init theme themes where ws dune_args =
  let cwd = Bsb_global_paths.cwd in
  try begin
    if version then print_version_string ();
    if verbose then Bsb_log.verbose ();
    if clean then Bsb_clean.clean cwd;
    if themes then Bsb_theme_init.list_themes ();
    if where then print_endline (Filename.dirname Sys.executable_name);
    match init with
    | Some path -> Bsb_theme_init.init_sample_project ~cwd ~theme path
    | None ->
      let generate_dune_bsb = make_world || install in
      if not make_world && not install then
        (if watch then exit 0)
      else begin
        if generate_dune_bsb then begin
          let buf = Buffer.create 0x1000 in
          let cfg = build_whole_project ~buf in
          install_target cfg;
        end;
        if watch then exit 0
        else if make_world then dune_command_exit [||] (*dune_args*)
      end
  end
  with
  | Bsb_exception.Error e ->
    Bsb_exception.print Format.err_formatter e ;
    Format.pp_print_newline Format.err_formatter ();
    exit 2
  | Ext_json_parse.Error (start,_,e) ->
    Format.fprintf Format.err_formatter
      "File %S, line %d\n\
       @{<error>Error:@} %a@."
      start.pos_fname start.pos_lnum
      Ext_json_parse.report_error e ;
    exit 2
  | Bsb_arg.Bad s
  | Sys_error s ->
    Format.fprintf Format.err_formatter
      "@{<error>Error:@} %s@."
      s ;
    exit 2
  | e -> Ext_pervasives.reraise e

let print_list list =
  List.iter print_endline list

let cmd dune_args =
  let version_flag =
    let doc = "Print version and exit" in
    Arg.(value & flag & info ["v"; "version"] ~doc)
  in

  let verbose_flag =
    let doc = "Set the output (from bsb) to be verbose" in
    Arg.(value & flag & info ["verbose"] ~doc)
  in
  
  let watch_mode_flag =
    let doc = "Currently does nothing. Enabled for compatibility." in
    Arg.(value & flag & info ["w"] ~doc)
  in

  let clean_flag =
    let doc = "Clean all bs dependencies" in
    Arg.(value & flag & info ["clean"; "clean-world"] ~doc)
  in

  let make_world_flag =
    let doc = "Build all dependencies and itself" in
    Arg.(value & flag & info ["make-world"] ~doc)
  in

  let install_flag =
    let doc = "Generate the (dune) rules for building the project" in
    Arg.(value & flag & info ["install"] ~doc)
  in

  let init_arg =
    let docv = "init path" in
    let doc =
      "Init sample project to get started. \n\
       Note: (`bsb -init sample` will create a sample project while \n\
       `bsb -init .` will reuse current directory)" in
    Arg.(value & opt (some string) None & info ["init"] ~doc ~docv)
  in

  let theme_arg =
    let docv = "theme" in
    let doc =
      "The theme for project initialization. \n\
       default is basic: \n\
       https://github.com/melange-re/melange/tree/master/jscomp/bsb/templates" in
    Arg.(value & opt string "basic" & info ["theme"] ~doc ~docv)
  in

  let themes_flag =
    let doc = "List all available themes" in
    Arg.(value & flag & info ["themes"] ~doc)
  in

  let where_flag =
    let doc = "Show where bsb is located" in
    Arg.(value & flag & info ["where"] ~doc)
  in

  let ws_flag =
    let doc = "Send build output to websocket" in
    Arg.(value & flag & info ["ws"] ~doc)
  in

  let info = Term.info "bsb" in
  let default_cmd =
    Term.(const run_bsb
          $ version_flag
          $ verbose_flag
          $ watch_mode_flag
          $ clean_flag
          $ make_world_flag
          $ install_flag
          $ init_arg
          $ theme_arg
          $ themes_flag
          $ where_flag
          $ ws_flag
          $ const dune_args) in
  default_cmd, info

let normalize_argv argv =
  Array.map (fun s ->
      if String.length s <= 2 then s
      else if s.[0] = '-' && s.[1] <> '-'
      then "-" ^ s
      else s
    ) argv

let split_argv_at_separator argv =
  let len = Array.length argv in
  let i = Ext_array.rfind_with_index argv Ext_string.equal separator in
  if i < 0 then
    argv, [||]
  else
    Array.sub argv 0 i,
    Array.sub argv (i + 1) (len - i - 1)

let () =
  let bsb_args, dune_args = split_argv_at_separator Sys.argv in
  Term.(exit @@ eval ~argv:(normalize_argv bsb_args) (cmd dune_args))
