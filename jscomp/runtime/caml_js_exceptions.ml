type js_error = { cause : exn }

(**
   This function has to be in this module Since
   [Error] is defined here
*)
(*
let internalToOCamlException (e : Obj.t) =
  if
    (not (Js.testAny e))
    && Caml_exceptions.caml_is_extension (Obj.magic e : js_error).cause
  then (Obj.magic e : js_error).cause
  else Error (Any e)
 *)

let[@mel.as MelangeError] melangeError =
  [%mel.raw
    {|
function MelangeError(message, payload) {
  var cause = payload != null ? payload : { MEL_EXN_ID: message };
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
  Object.assign(_this, cause);

  return _this;
}
|}]

[%%mel.raw {|
MelangeError.prototype = Error.prototype;
|}]

external internalMakeExn : string -> exn = "MelangeError" [@@mel.new]
external set : 'a -> string -> 'b -> unit = "" [@@mel.set_index]

let internalAnyToExn : 'a -> exn =
 fun any ->
  if Caml_exceptions.caml_is_extension any then Obj.magic any
  else
    let exn = internalMakeExn "Js__Js_exn.Error/1" in
    set exn "_1" any;
    exn

let internalToOCamlException = internalAnyToExn

(* let internalFromExtension =
 fun (_ext : 'a) : exn -> [%raw "new MelangeError(_ext.MEL_EXN_ID, _ext)"] *)
