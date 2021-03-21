'use strict';

var Belt_Array = require("../../lib/js/belt_Array.js");

var b = Belt_Array.eq([
      1,
      2,
      3
    ], [
      1,
      2,
      3
    ], (function (prim, prim$1) {
        return prim === prim$1;
      }));

exports.b = b;
/* b Not a pure module */
