'use strict';

var Seq = require("melange/lib/js/seq.js");
var Curry = require("melange/lib/js/curry.js");
var Stdlib = require("melange/lib/js/stdlib.js");
var $$String = require("melange/lib/js/string.js");
var Caml_option = require("melange/lib/js/caml_option.js");

function is_empty(param) {
  if (param) {
    return false;
  } else {
    return true;
  }
}

var v = Curry._1(is_empty, /* Empty */0);

exports.v = v;
/* M Not a pure module */
