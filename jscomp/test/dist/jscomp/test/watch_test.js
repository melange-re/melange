// Generated by Melange
'use strict';

const Fs = require("fs");

function test(path) {
  Fs.watch(path, {
    recursive: true
  }).on("change", (function ($$event, string_buffer) {
    console.log([
      $$event,
      string_buffer
    ]);
  })).close();
}

module.exports = {
  test,
}
/* fs Not a pure module */
