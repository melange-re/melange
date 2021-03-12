'use strict';

var Obj = require("./obj.js");
var Caml_external_polyfill = require("./caml_external_polyfill.js");

function register(name, v) {
  return Caml_external_polyfill.resolve("caml_register_named_value")(name, v);
}

function register_exception(name, exn) {
  var slot = (exn.TAG | 0) === Obj.object_tag ? exn : exn[0];
  return Caml_external_polyfill.resolve("caml_register_named_value")(name, slot);
}

exports.register = register;
exports.register_exception = register_exception;
/* No side effect */
