open Melange_mini_stdlib

type t = Any : 'a -> t [@@unboxed]
type 'a js_error = { cause : 'a }

exception Error of t

(**
   This function has to be in this module Since
   [Error] is defined here
*)
let internalToOCamlException (e : Obj.t) =
  if Caml_exceptions.caml_is_extension (Obj.magic e : _ js_error).cause then
    (Obj.magic (Obj.magic e : _ js_error).cause : exn)
  else Error (Any e)

let caml_as_js_exn exn = match exn with Error t -> Some t | _ -> None
