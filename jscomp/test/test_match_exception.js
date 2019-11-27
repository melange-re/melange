'use strict';

var Curry = require("../../lib/js/curry.js");
var Caml_exceptions = require("../../lib/js/caml_exceptions.js");
var Caml_builtin_exceptions = require("../../lib/js/caml_builtin_exceptions.js");

function f(g, x) {
  try {
    return Curry._1(g, x);
  }
  catch (exn){
    if (exn === Caml_builtin_exceptions.not_found) {
      return 3;
    } else {
      throw Caml_exceptions.stacktrace(exn);
    }
  }
}

exports.f = f;
/* No side effect */
