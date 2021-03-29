(* Copyright (C) 2019- Hongbo Zhang, Authors of ReScript
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



exception Pp_error

module Make(T: Reason_toolchain_conf.Toolchain) = struct
 let setup_lexbuf ~parser filename =
  try
   let file_chan = open_in filename in
   seek_in file_chan 0;
   let lexbuf = Lexing.from_channel file_chan in
   Location.init lexbuf filename;
   parser lexbuf
  with
  | Reason_errors.Reason_error _ as rexn ->
    raise rexn
  | Sys_error _ as exn ->
    (* file doesn't exist *)
    raise exn
  | _ -> raise Pp_error

 let parse_implementation filename =
   let omp_ast = setup_lexbuf
     ~parser:T.implementation
     filename
   in
   let omp_ast =
     Reason_syntax_util.(apply_mapper_to_structure omp_ast (backport_letopt_mapper remove_stylistic_attrs_mapper))
   in
   Reason_toolchain.To_current.copy_structure omp_ast

 let parse_interface filename =
   let omp_ast = setup_lexbuf
     ~parser:T.interface
     filename
   in
   Reason_toolchain.To_current.copy_signature omp_ast

 let parse_implementation_with_comments filename =
   let omp_ast, comments = setup_lexbuf
     ~parser:T.implementation_with_comments
     filename
   in
   let omp_ast =
     Reason_syntax_util.(apply_mapper_to_structure omp_ast (backport_letopt_mapper remove_stylistic_attrs_mapper))
   in
   Reason_toolchain.To_current.copy_structure omp_ast, comments

 let parse_interface_with_comments filename =
   let omp_ast, comments = setup_lexbuf
     ~parser:T.interface_with_comments
     filename
   in
   Reason_toolchain.To_current.copy_signature omp_ast, comments

 let format_implementation_with_comments ~comments ast =
  let buf = Buffer.create 0x1000 in
  let fmt = Format.formatter_of_buffer buf in
  let ast = Reason_toolchain.From_current.copy_structure ast in
  T.print_implementation_with_comments fmt (ast, comments);
  Buffer.contents buf

 let format_interface_with_comments ~comments ast =
  let buf = Buffer.create 0x1000 in
  let fmt = Format.formatter_of_buffer buf in
  let ast = Reason_toolchain.From_current.copy_signature ast in
  T.print_interface_with_comments fmt (ast, comments);
  Buffer.contents buf

 let format ~parser ~printer filename =
   let parse_result = setup_lexbuf ~parser filename in
   let buf = Buffer.create 0x1000 in
   let fmt = Format.formatter_of_buffer buf in
   printer fmt parse_result;
   Buffer.contents buf

 let format_implementation filename =
   format
     ~parser:T.implementation_with_comments
     ~printer:T.print_implementation_with_comments
     filename

 let format_interface filename =
   format
     ~parser:T.interface_with_comments
     ~printer:T.print_interface_with_comments
     filename
end

 module RE = Make(Reason_toolchain.RE)
 module ML = Make(Reason_toolchain.ML)

let clean tmpfile =
  (if not !Clflags.verbose then try Sys.remove tmpfile with _ -> () )

