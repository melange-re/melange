'use strict';

var Stdlib = require("melange/jscomp/stdlib-412/stdlib.js");

var u = 3;

function f(param) {
  return Stdlib.invalid_arg("hi");
}

exports.u = u;
exports.f = f;
/* No side effect */
