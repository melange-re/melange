// Generated by Melange
'use strict';

const Mt = require("./mt.js");

console.log(JSON.stringify({
  hd: 1,
  tl: {
    hd: 2,
    tl: {
      hd: 3,
      tl: /* [] */ 0
    }
  }
}));

console.log("hey");

const suites_0 = [
  "anything_to_string",
  (function (param) {
    return {
      TAG: /* Eq */ 0,
      _0: "3",
      _1: String(3)
    };
  })
];

const suites = {
  hd: suites_0,
  tl: /* [] */ 0
};

Mt.from_pair_suites("Lib_js_test", suites);

module.exports = {
  suites,
}
/*  Not a pure module */
