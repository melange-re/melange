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

let[@mel.as MelangeError] melangeError =
  [%mel.raw
    {|
function MelangeError(message, cause) {
  var _this = Error.call(this, message, { cause: cause });

  if (_this.cause == null) {
    Object.defineProperty(_this, 'cause', {
      configurable : true,
      enumerable : false,
      writable : true,
      value : cause
    });
  }
  Object.defineProperty(_this, 'name', {
    configurable : true,
    enumerable : false,
    writable : true,
    value : 'MelangeError'
  })

  return _this;
}
|}]

[%%mel.raw {|
MelangeError.prototype = Error.prototype;
|}]
