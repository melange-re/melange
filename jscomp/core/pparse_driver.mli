module Ast_io : sig
  module Compiler_version = Ppxlib_ast.Compiler_version

  module type OCaml_version = Ppxlib_ast.OCaml_version

  type input_version = (module OCaml_version)

  val fall_back_input_version : (module OCaml_version)

  type 'a t = {
    input_name : string;
    input_version : input_version;
    kind : 'a Ml_binary.kind;
    ast : 'a;
  }

  type read_error =
    | Not_a_binary_ast
    | Unknown_version of string * input_version
    | Source_parse_error of Ppxlib_ast.Location_error.t * input_version
    | System_error of Ppxlib_ast.Location_error.t * input_version

  type input_source = Stdin | File of string
  (* | Channel of in_channel *)

  type 'a input_kind =
    | Possibly_source of {
        filename : string;
        kind : 'a Ml_binary.kind;
        parse_fun : Lexing.lexbuf -> 'a;
      }
    | Necessarily_binary

  val read :
    input_source ->
    kind:'a Ml_binary.kind ->
    input_kind:'a input_kind ->
    ('a t, read_error) result
end

val parse_implementation : string -> Parsetree.structure
val parse_interface : string -> Parsetree.signature
