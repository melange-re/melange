module Js = Jsoo_runtime.Js

module Reason : sig
  val parseRE : Js.t -> Ppxlib.Parsetree.structure * Reason_comment.t list
  val parseML : Js.t -> Ppxlib.Parsetree.structure * Reason_comment.t list
  val printRE : Ppxlib.Parsetree.structure * Reason_comment.t list -> Js.t
  val printML : Ppxlib.Parsetree.structure * Reason_comment.t list -> Js.t
end

(*
Creates a Js object for given location report
*)
val warning_error_to_js : Location.report -> Js.t
