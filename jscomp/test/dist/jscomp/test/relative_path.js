// Generated by Melange
'use strict';

const FileJs = require("./File.js");

const foo = FileJs.foo;

function foo2(prim) {
  return FileJs.foo2(prim);
}

const bar = foo;

module.exports = {
  foo,
  foo2,
  bar,
}
/* foo Not a pure module */
