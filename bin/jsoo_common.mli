module Js = Jsoo_runtime.Js

type js_error = Js.t

module Reason : sig
  val parseRE : Js.t -> Ppxlib.Parsetree.structure * Reason_comment.t list
  val parseML : Js.t -> Ppxlib.Parsetree.structure * Reason_comment.t list
  val printRE : Ppxlib.Parsetree.structure * Reason_comment.t list -> Js.t
  val printML : Ppxlib.Parsetree.structure * Reason_comment.t list -> Js.t
end

(*
Creates a Js Error object for given location report
*)
val mk_js_error : Location.report -> js_error
