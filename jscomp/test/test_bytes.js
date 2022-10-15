'use strict';

var Bytes = require("melange/jscomp/stdlib-412/stdlib_modules/bytes.js");
var Caml_bytes = require("melange/lib/js/caml_bytes.js");

var f = Bytes.unsafe_to_string;

var ff = Caml_bytes.bytes_to_string;

exports.f = f;
exports.ff = ff;
/* No side effect */
