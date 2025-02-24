open Ppxlib
module Js := Jsoo_runtime.Js

val feed_string_with_newline : string -> Lexing.lexbuf
val parseRE : Js.t -> Parsetree.structure * Reason_comment.t list
val parseML : Js.t -> Parsetree.structure * Reason_comment.t list
val printRE : Parsetree.structure * Reason_comment.t list -> Js.t
val printML : Parsetree.structure * Reason_comment.t list -> Js.t

val warning_error_to_js : Ocaml_common.Location.report -> Js.t
(** Creates a Js object for given location report *)
