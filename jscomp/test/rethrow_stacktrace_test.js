'use strict';

var Caml_exceptions = require("../../lib/js/caml_exceptions.js");
var Caml_js_exceptions = require("../../lib/js/caml_js_exceptions.js");
var Caml_builtin_exceptions = require("../../lib/js/caml_builtin_exceptions.js");

function g(param) {
  (("no inlining"));
  throw Caml_exceptions.stacktrace(Caml_builtin_exceptions.not_found);
}

function f(param) {
  (("no inlining"));
  return g(/* () */0);
}

function rethrow(e) {
  throw Caml_exceptions.stacktrace(e);
}

function test(param) {
  try {
    return f(/* () */0);
  }
  catch (e){
    throw Caml_exceptions.stacktrace(e);
  }
}

try {
  test(/* () */0);
}
catch (raw_exn){
  var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
  console.log(exn.stack);
}

exports.g = g;
exports.f = f;
exports.rethrow = rethrow;
exports.test = test;
/*  Not a pure module */
