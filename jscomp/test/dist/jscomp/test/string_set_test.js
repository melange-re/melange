// Generated by Melange
'use strict';

const Mt = require("./mt.js");
const String_set = require("./string_set.js");

const suites = {
  contents: /* [] */ 0
};

const test_id = {
  contents: 0
};

function eq(loc, x, y) {
  test_id.contents = test_id.contents + 1 | 0;
  suites.contents = {
    hd: [
      loc + (" id " + String(test_id.contents)),
      (function (param) {
        return {
          TAG: /* Eq */ 0,
          _0: x,
          _1: y
        };
      })
    ],
    tl: suites.contents
  };
}

let s = String_set.empty;

for (let i = 0; i <= 99999; ++i) {
  s = String_set.add(String(i), s);
}

eq("File \"jscomp/test/string_set_test.ml\", line 16, characters 5-12", String_set.cardinal(s), 100000);

Mt.from_pair_suites("String_set_test", suites.contents);

module.exports = {
  suites,
  test_id,
  eq,
}
/*  Not a pure module */
