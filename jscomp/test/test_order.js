'use strict';

var Caml = require("melange/lib/js/caml.js");

var compare = Caml.caml_int_compare;

exports.compare = compare;
/* No side effect */
