// Generated by Melange
'use strict';

var List = require("melange/jscomp/stdlib-412/stdlib_modules/list.js");

var b = List.length({
      hd: 1,
      tl: {
        hd: 2,
        tl: {
          hd: 3,
          tl: /* [] */0
        }
      }
    });

var a = b - 1 | 0;

console.log("hello, res");

exports.a = a;
/* b Not a pure module */