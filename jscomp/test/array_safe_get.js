'use strict';

var Caml_array = require("../../lib/js/caml_array.js");
var Caml_js_exceptions = require("../../lib/js/caml_js_exceptions.js");
var Stdlib__no_aliases = require("../../lib/js/stdlib__no_aliases.js");

var x = [
  1,
  2
];

var y;

try {
  y = Caml_array.get(x, 3);
}
catch (raw_msg){
  var msg = Caml_js_exceptions.internalToOCamlException(raw_msg);
  if (msg.RE_EXN_ID === Stdlib__no_aliases.Invalid_argument) {
    console.log(msg._1);
    y = 0;
  } else {
    throw msg;
  }
}

exports.x = x;
exports.y = y;
/* y Not a pure module */
