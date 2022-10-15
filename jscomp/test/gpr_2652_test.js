'use strict';

var $$Buffer = require("melange/jscomp/stdlib-412/stdlib_modules/buffer.js");

var foo = $$Buffer.contents;

function bar(str) {
  return Buffer.from(str);
}

exports.foo = foo;
exports.bar = bar;
/* No side effect */
