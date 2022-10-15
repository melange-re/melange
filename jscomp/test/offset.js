'use strict';

var $$Set = require("melange/jscomp/stdlib-412/stdlib_modules/set.js");
var $$String = require("melange/jscomp/stdlib-412/stdlib_modules/string.js");

var $$Set$1 = $$Set.Make({
      compare: $$String.compare
    });

var M = {
  x: 1,
  $$Set: $$Set$1
};

var x = 1;

exports.M = M;
exports.x = x;
exports.$$Set = $$Set$1;
/* Set Not a pure module */
