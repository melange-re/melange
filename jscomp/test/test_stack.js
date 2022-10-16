'use strict';

var Caml_obj = require("melange/lib/js/caml_obj.js");

function v(x) {
  return Caml_obj.caml_equal(x.c, /* [] */0);
}

exports.v = v;
/* No side effect */
