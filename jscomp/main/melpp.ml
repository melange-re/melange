(* Copyright (C) 2023- Authors of Melange
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

let output_deps_set name set =
  output_string stdout name;
  output_string stdout ": ";
  Depend.String.Set.iter
    (fun s ->
      if s <> "" && s.[0] <> '*' then (
        output_string stdout s;
        output_string stdout " "))
    set;
  output_string stdout "\n"

let after_parsing_sig ast =
  Ast_config.iter_on_bs_config_sigi ast;
  if !Js_config.modules then
    output_deps_set !Location.input_name
      (Ast_extract.read_parse_and_extract Mli ast);
  output_string stdout Config.ast_intf_magic_number;
  output_value stdout (!Location.input_name : string);
  output_value stdout ast

let after_parsing_impl (ast : Parsetree.structure) =
  Ast_config.iter_on_bs_config_stru ast;
  if !Js_config.modules then
    output_deps_set !Location.input_name
      (Ast_extract.read_parse_and_extract Ml ast);
  output_string stdout Config.ast_impl_magic_number;
  output_value stdout (!Location.input_name : string);
  output_value stdout ast

let define_variable s =
  let module Pp = Rescript_cpp in
  match Ext_string.split ~keep_empty:true s '=' with
  | [ key; v ] ->
      if not (Pp.define_key_value key v) then
        raise (Arg.Bad ("illegal definition: " ^ s))
  | _ -> raise (Arg.Bad ("illegal definition: " ^ s))

let main =
  let main interface defines unsafe filename =
    Ext_list.iter defines define_variable;
    if unsafe then Clflags.unsafe := unsafe;
    match
      ( interface,
        Ext_file_extensions.classify_input
          (Ext_filename.get_extension_maybe filename) )
    with
    | true, _ | _, Mli ->
        Pparse_driver.parse_interface filename |> after_parsing_sig
    | _, Ml -> Pparse_driver.parse_implementation filename |> after_parsing_impl
    | _, _ -> assert false
  in
  fun interface defines unsafe filename ->
    try `Ok (main interface defines unsafe filename) with
    | Arg.Bad msg -> `Error (false, msg)
    | x ->
        Location.report_exception Format.err_formatter x;
        exit 2

module Cli = struct
  open Cmdliner

  let interface =
    let docv = "interface" in
    Arg.(value & flag & info [ "i"; "interface" ] ~docv)

  let defines =
    let doc = "Define conditional variable e.g, -D DEBUG=true" in
    Arg.(value & opt_all string [] & info [ "D" ] ~doc)

  let unsafe =
    let doc = "Do not compile bounds checking on array and string access" in
    Arg.(value & flag & info [ "unsafe" ] ~doc)

  let filename =
    let docv = "filename" in
    Arg.(required & pos 0 (some' string) None & info [] ~docv)

  let cmd =
    let open Cmdliner in
    let term = Term.(const main $ interface $ defines $ unsafe $ filename) in
    let info = Cmd.info "melpp" in
    Cmd.v info (Term.ret term)
end

let () =
  Bs_conditional_initial.setup_env ();
  let argv = Ext_cli_args.normalize_argv Sys.argv in
  exit (Cmdliner.Cmd.eval ~argv Cli.cmd)
