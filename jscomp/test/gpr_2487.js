'use strict';

var Belt_Array = require("melange/jscomp/others/belt_Array.js");

var b = Belt_Array.eq([
      1,
      2,
      3
    ], [
      1,
      2,
      3
    ], (function (prim0, prim1) {
        return prim0 === prim1;
      }));

exports.b = b;
/* b Not a pure module */
