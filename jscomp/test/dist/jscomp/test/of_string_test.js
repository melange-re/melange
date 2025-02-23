// Generated by Melange
'use strict';

const Mt = require("./mt.js");
const Stdlib = require("melange/stdlib.js");

const suites_0 = [
  "string_of_float_1",
  (function (param) {
    return {
      TAG: /* Eq */ 0,
      _0: "10.",
      _1: Stdlib.string_of_float(10)
    };
  })
];

const suites_1 = {
  hd: [
    "string_of_int",
    (function (param) {
      return {
        TAG: /* Eq */ 0,
        _0: "10",
        _1: String(10)
      };
    })
  ],
  tl: {
    hd: [
      "valid_float_lexem",
      (function (param) {
        return {
          TAG: /* Eq */ 0,
          _0: "10.",
          _1: Stdlib.valid_float_lexem("10")
        };
      })
    ],
    tl: /* [] */ 0
  }
};

const suites = {
  hd: suites_0,
  tl: suites_1
};

Mt.from_pair_suites("Of_string_test", suites);

module.exports = {
  suites,
}
/*  Not a pure module */
