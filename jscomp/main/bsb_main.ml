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

let () =  Bsb_log.setup ()
let current_theme = ref "basic"
let generate_theme_with_path = ref None
let separator = "--"
let watch_mode = ref false
let make_world = ref false
let generate_dune_bsb = ref false
let do_install = ref false
let bs_version_string = Bs_version.version
let print_version_string () =
  print_string bs_version_string;
  print_newline ();
  exit 0
type spec = Bsb_arg.spec

let call_spec f : spec = Unit (Unit_call f )
let  unit_set_spec b : spec = Unit (Unit_set b)


let bsb_main_flags : (string * spec * string) array =
  [|
    "-v", call_spec print_version_string,
    "Print version and exit";
    "-version", call_spec print_version_string,
    "Print version and exit";
    "-verbose", call_spec Bsb_log.verbose,
    "Set the output(from bsb) to be verbose";
    "-w", unit_set_spec watch_mode,
    "Watch mode" ;
    (* XXX(anmonteiro): the two commands below do the same, and are kept for
       CLI compatibility. *)
    (* TODO(anmonteiro): They should probably call `dune clean`. It could get
       confusing why running `bsb -clean-world -make-world` doesn't rebuild
       anything after a project is built (`Bsb_clean.clean` only removes the
       files `bsb` wrote, it doesn't call `dune clean`). *)
    "-clean-world", call_spec (fun _ ->
        Bsb_clean.clean  Bsb_global_paths.cwd),
    "Clean all bs dependencies";
    "-clean", call_spec (fun _ ->
        Bsb_clean.clean  Bsb_global_paths.cwd),
    "Clean only current project";
    "-make-world", unit_set_spec make_world,
    "Build all dependencies and itself ";
    "-install", unit_set_spec do_install,
    "Generate the (dune) rules for building the project";
    "-init", String (String_call (fun path -> generate_theme_with_path := Some path)),
    "Init sample project to get started. \n\
     Note (`bsb -init sample` will create a sample project while \n\
     `bsb -init .` will reuse current directory)";
    "-theme", String (String_set current_theme),
    "The theme for project initialization. \n\
    default is basic:\n\
    https://github.com/rescript-lang/rescript-compiler/tree/master/jscomp/bsb/templates";

    "-themes", call_spec Bsb_theme_init.list_themes,
    "List all available themes";
    "-where",
    call_spec (fun _ ->
        print_endline (Filename.dirname Sys.executable_name)),
    "Show where bsb.exe is located";
    (* Below flags are only for bsb script, it is not available for bsb.exe
        we make it at this time to make `bsb -help` easier *)
    "-ws", call_spec ignore,
    "[host:]port \n\
     specify a websocket number (and optionally, a host). \n\
     When a build finishes, we send a message to that port. \n\
     For tools that listen on build completion." ;

  |]

let (//) = Ext_path.combine

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
  Bsb_ninja_targets.revise_dune dune buf


let ninja_command_exit dune_args  =
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


let program_exit () =
  exit 0

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

let maybe_generate_config = function
  | None ->
    Bsb_config_parse.interpret_json
      ~package_kind:Toplevel
      ~per_proj_dir:Bsb_global_paths.cwd
  | Some config -> config

(* see discussion #929, if we catch the exception, we don't have stacktrace... *)
let () =
  let config = ref None in
  let argv = Sys.argv in
  let buf = Buffer.create 0x1000 in
  try begin
    let i =  Ext_array.rfind_with_index argv Ext_string.equal separator in
    if i < 0 then
      begin
        Bsb_arg.parse_exn ~usage ~argv bsb_main_flags handle_anonymous_arg;
        (* first, check whether we're in boilerplate generation mode, aka -init foo -theme bar *)
        match !generate_theme_with_path with
        | Some path -> Bsb_theme_init.init_sample_project ~cwd:Bsb_global_paths.cwd ~theme:!current_theme  path
        | None ->
          (* [-make-world] should never be combined with [-package-specs] *)
          let make_world = !make_world in
          let do_install = !do_install in
          generate_dune_bsb := make_world || do_install;
          if not make_world && not do_install then
            (* [regenerate_ninja] is not triggered in this case
               There are several cases we wish ninja will not be triggered.
               [bsb -clean-world]
               [bsb -regen ]
            *)
            (if !watch_mode then
                program_exit ()) (* bsb -verbose hit here *)
          else begin
            (if !generate_dune_bsb then
              config := Some (build_whole_project ~buf));
             if !watch_mode then begin
               program_exit ()
               (* ninja is not triggered in this case
                  There are several cases we wish ninja will not be triggered.
                  [bsb -clean-world]
                  [bsb -regen ]
               *)
             end else begin
               if do_install then
                 install_target (maybe_generate_config !config);
               if make_world then begin
                 ninja_command_exit [||]
               end
             end
          end
      end
    else
       (* -make-world all dependencies fall into this category *)
      begin
        Bsb_arg.parse_exn
        ~usage
        ~argv:argv
        ~finish:i
        bsb_main_flags handle_anonymous_arg;
        let ninja_args = Array.sub argv (i + 1) (Array.length argv - i - 1) in
        (* [-make-world] should never be combined with [-package-specs] *)
        generate_dune_bsb := !make_world || !do_install;
        (if !generate_dune_bsb then
          config := Some (build_whole_project ~buf));
        if !do_install then
          install_target (maybe_generate_config !config);
        if !watch_mode then program_exit ()
        else if !make_world then begin
          ninja_command_exit ninja_args
        end
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
