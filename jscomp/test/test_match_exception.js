'use strict';

var Curry = require("melange/lib/js/curry.js");
var Stdlib = require("melange/jscomp/stdlib-412/stdlib.js");
var Caml_js_exceptions = require("melange/lib/js/caml_js_exceptions.js");

function f(g, x) {
  try {
    return Curry._1(g, x);
  }
  catch (raw_exn){
    var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
    if (exn.RE_EXN_ID === Stdlib.Not_found) {
      return 3;
    }
    throw exn;
  }
}

exports.f = f;
/* No side effect */
