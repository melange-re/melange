'use strict';

var Format = require("melange/lib/js/format.js");

function write_runtime_coverage(channel) {
  Format.formatter_of_out_channel(channel);
}

exports.write_runtime_coverage = write_runtime_coverage;
/* Format Not a pure module */
