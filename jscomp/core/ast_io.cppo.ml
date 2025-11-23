(* Copyright (C) 2023 Antonio Nuno Monteiro
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

open Import

module Melange_ast_version =
#if OCAML_VERSION >= (5, 4, 0)
  Ppxlib_ast__.Versions.OCaml_504
#elif OCAML_VERSION >= (5, 3, 0)
  Ppxlib_ast__.Versions.OCaml_503
#elif OCAML_VERSION >= (5, 2, 0)
  Ppxlib_ast__.Versions.OCaml_502
#elif OCAML_VERSION >= (5, 1, 0)
  Ppxlib_ast__.Versions.OCaml_501
#else
  Ppxlib_ast__.Versions.OCaml_414
#endif

module Compiler_version = Ppxlib_ast.Compiler_version

module type OCaml_version = Ppxlib_ast.OCaml_version

module Intf_or_impl = struct
  type t =
    | Intf of Parsetree.signature
    | Impl of Parsetree.structure

  module Convert =
    Ppxlib_ast.Convert
      (Ppxlib_ast.Selected_ast)
      (Melange_ast_version)

  let ppxlib_impl : Ppxlib_ast.Ast.structure -> t =
   fun stru ->
    let melange_stru =
      let ocaml_51_stru = Convert.copy_structure stru in
      (Obj.magic ocaml_51_stru : Parsetree.structure)
    in
    Impl melange_stru

  let ppxlib_intf : Ppxlib_ast.Ast.signature -> t =
   fun sig_ ->
    let melange_sig =
      let ocaml_51_sig = Convert.copy_signature sig_ in
      (Obj.magic ocaml_51_sig : Parsetree.signature)
    in
    Intf melange_sig
end

type input_version = (module OCaml_version)

let fall_back_input_version = (module Compiler_version : OCaml_version)
(* This should only be used when the input version can't be determined due to
    loading or preprocessing errors *)

type t = {
  input_name : string;
  input_version : input_version;
  ast : Intf_or_impl.t;
}

type read_error =
  | Not_a_binary_ast
  | Unknown_version of string * input_version
  | Source_parse_error of Ppxlib_ast.Location_error.t * input_version
  | System_error of Ppxlib_ast.Location_error.t * input_version

type input_source = Stdin | File of string

type input_kind =
  | Possibly_source of {
      filename : string;
      parse_fun : Lexing.lexbuf -> Intf_or_impl.t;
    }
  | Necessarily_binary

let read_error_to_string (error : read_error) =
  match error with
  | Not_a_binary_ast -> "Error: Not a binary ast"
  | Unknown_version (s, _) -> "Error: Unknown version " ^ s
  | Source_parse_error (loc, _) ->
      "Source parse error:" ^ Ppxlib_ast.Location_error.message loc
  | System_error (loc, _) ->
      "System error: " ^ Ppxlib_ast.Location_error.message loc

let magic_length = String.length Astlib.Config.ast_impl_magic_number

let read_magic ic =
  let buf = Bytes.create magic_length in
  let len = input ic buf 0 magic_length in
  let s = Bytes.sub_string buf ~pos:0 ~len in
  if len = magic_length then Ok s else Error s

let set_input_lexbuf () =
  let set_input_lexbuf fn =
    (* set input lexbuf for error messages. *)
    let source = Io.read_file fn in
    let lexbuf = Lexing.from_string source in
    Location.input_lexbuf := Some lexbuf;
    Ocaml_common.Location.input_lexbuf := Some lexbuf;
    lexbuf
  in
  begin match set_input_lexbuf !Location.input_name with
  | (_ : Lexing.lexbuf) -> ()
  | exception Unix.Unix_error (Unix.ENOENT, _, _)
  | exception Sys_error _ -> ()
  end

let from_channel ch ~input_kind : (t, read_error) result =
  let input_version = (module Compiler_version : OCaml_version) in
  let module Convert = Ppxlib_ast.Convert in
  let module Find_version = Ppxlib_ast__.Versions.Find_version in
  let handle_non_binary () =
    match input_kind with
    | Possibly_source { filename; parse_fun } ->
        seek_in ch 0;
        let lexbuf = Lexing.from_channel ch in
        Location.init lexbuf filename;
        Ocaml_common.Location.init lexbuf filename;
        Location.input_lexbuf := Some lexbuf;
        Ocaml_common.Location.input_lexbuf:= Some lexbuf;
        let ast = parse_fun lexbuf in
        Ok { input_name = filename; input_version; ast }
    | Necessarily_binary -> Error Not_a_binary_ast
  in
  match read_magic ch with
  | Error _ -> handle_non_binary ()
  | Ok s -> (
      match Find_version.from_magic s with
      | Intf (module Input_version : OCaml_version) ->
          let input_name : string = input_value ch in
          Ocaml_common.Location.input_name := input_name;
          Location.input_name := input_name;
          set_input_lexbuf ();

          let ast = input_value ch in
          let module Input_to_ppxlib =
            Convert (Input_version) (Ppxlib_ast.Selected_ast)
          in
          Ok
            {
              input_name;
              input_version = (module Input_version : OCaml_version);
              ast =
                Intf_or_impl.ppxlib_intf (Input_to_ppxlib.copy_signature ast);
            }
      | Impl (module Input_version : OCaml_version) ->
          let input_name : string = input_value ch in
          Location.input_name := input_name;
          Ocaml_common.Location.input_name := input_name;
          set_input_lexbuf ();

          let ast = input_value ch in
          let module Input_to_ppxlib =
            Convert (Input_version) (Ppxlib_ast.Selected_ast)
          in
          Ok
            {
              input_name;
              input_version = (module Input_version : OCaml_version);
              ast =
                Intf_or_impl.ppxlib_impl (Input_to_ppxlib.copy_structure ast);
            }
      | Unknown ->
          if
            String.equal
              (String.sub s ~pos:0 ~len:9)
              (String.sub Astlib.Config.ast_impl_magic_number ~pos:0 ~len:9)
            || String.equal
                 (String.sub s ~pos:0 ~len:9)
                 (String.sub Astlib.Config.ast_intf_magic_number ~pos:0 ~len:9)
          then Error (Unknown_version (s, fall_back_input_version))
          else handle_non_binary ())

module In_ch = struct
  let create ?(binary = true) file =
    let flags = [ Open_rdonly ] in
    let flags = if binary then Open_binary :: flags else flags in
    open_in_gen flags 0o000 file

  let with_file ?binary filename ~f =
    let t = create ?binary filename in
    Fun.protect ~finally:(fun () -> close_in t) (fun () -> f t)
end

let read input_source ~input_kind =
  try
    match input_source with
    | Stdin -> from_channel stdin ~input_kind
    | File fn -> In_ch.with_file fn ~f:(from_channel ~input_kind)
  with exn -> (
    match Ppxlib_ast.Location_error.of_exn exn with
    | None -> raise exn
    | Some error -> Error (System_error (error, fall_back_input_version)))

let read_exn input_source ~input_kind =
  match read input_source ~input_kind with
  | Ok ret -> ret
  | Error e -> raise (Arg.Bad (read_error_to_string e))
