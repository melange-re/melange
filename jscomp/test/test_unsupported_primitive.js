'use strict';

var Stdlib = require("melange/lib/js/stdlib.js");
var Caml_external_polyfill = require("melange/lib/js/caml_external_polyfill.js");

function to_buffer(buff, ofs, len, v, flags) {
  if (ofs < 0 || len < 0 || ofs > (buff.length - len | 0)) {
    return Stdlib.invalid_arg("Marshal.to_buffer: substring out of bounds");
  } else {
    return Caml_external_polyfill.resolve("caml_output_value_to_buffer")(buff, ofs, len, v, flags);
  }
}

exports.to_buffer = to_buffer;
/* No side effect */
