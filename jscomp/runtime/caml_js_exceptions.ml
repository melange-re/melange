open Melange_mini_stdlib

type t = Any : 'a -> t [@@unboxed]
type js_error = { cause : exn }

exception Error of t

(**
   This function has to be in this module Since
   [Error] is defined here
*)
let internalToOCamlException (e : Obj.t) =
  if
    (not (Js_internal.testAny e))
    && Caml_exceptions.caml_is_extension (Obj.magic e : js_error).cause
  then (Obj.magic e : js_error).cause
  else Error (Any e)

let caml_as_js_exn exn = match exn with Error t -> Some t | _ -> None
