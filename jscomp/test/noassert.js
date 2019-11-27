'use strict';

var Caml_exceptions = require("../../lib/js/caml_exceptions.js");
var Caml_builtin_exceptions = require("../../lib/js/caml_builtin_exceptions.js");

function f(param) {
  throw Caml_exceptions.stacktrace([
            Caml_builtin_exceptions.assert_failure,
            /* tuple */[
              "noassert.ml",
              5,
              11
            ]
          ]);
}

function h(param) {
  return 0;
}

exports.f = f;
exports.h = h;
/* No side effect */
