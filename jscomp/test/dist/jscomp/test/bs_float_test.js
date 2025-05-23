// Generated by Melange
'use strict';

const Belt__Belt_Float = require("melange.belt/belt_Float.js");
const Mt = require("./mt.js");

const suites = {
  contents: /* [] */ 0
};

const test_id = {
  contents: 0
};

function eq(loc, x, y) {
  Mt.eq_suites(test_id, suites, loc, x, y);
}

function b(loc, x) {
  Mt.bool_suites(test_id, suites, loc, x);
}

function $$throw(loc, x) {
  Mt.throw_suites(test_id, suites, loc, x);
}

function neq(loc, x, y) {
  test_id.contents = test_id.contents + 1 | 0;
  suites.contents = {
    hd: [
      loc + (" id " + String(test_id.contents)),
      (function (param) {
        return {
          TAG: /* Neq */ 1,
          _0: x,
          _1: y
        };
      })
    ],
    tl: suites.contents
  };
}

eq("File \"jscomp/test/bs_float_test.ml\", line 14, characters 5-12", 1, 1.0);

eq("File \"jscomp/test/bs_float_test.ml\", line 15, characters 5-12", -1, -1.0);

eq("File \"jscomp/test/bs_float_test.ml\", line 18, characters 5-12", 1, 1);

eq("File \"jscomp/test/bs_float_test.ml\", line 19, characters 5-12", 1, 1);

eq("File \"jscomp/test/bs_float_test.ml\", line 20, characters 5-12", 1, 1);

eq("File \"jscomp/test/bs_float_test.ml\", line 21, characters 5-12", -1, -1);

eq("File \"jscomp/test/bs_float_test.ml\", line 22, characters 5-12", -1, -1);

eq("File \"jscomp/test/bs_float_test.ml\", line 23, characters 5-12", -1, -1);

eq("File \"jscomp/test/bs_float_test.ml\", line 26, characters 5-12", Belt__Belt_Float.fromString("1"), 1.0);

eq("File \"jscomp/test/bs_float_test.ml\", line 27, characters 5-12", Belt__Belt_Float.fromString("-1"), -1.0);

eq("File \"jscomp/test/bs_float_test.ml\", line 28, characters 5-12", Belt__Belt_Float.fromString("1.7"), 1.7);

eq("File \"jscomp/test/bs_float_test.ml\", line 29, characters 5-12", Belt__Belt_Float.fromString("-1.0"), -1.0);

eq("File \"jscomp/test/bs_float_test.ml\", line 30, characters 5-12", Belt__Belt_Float.fromString("-1.5"), -1.5);

eq("File \"jscomp/test/bs_float_test.ml\", line 31, characters 5-12", Belt__Belt_Float.fromString("-1.7"), -1.7);

eq("File \"jscomp/test/bs_float_test.ml\", line 32, characters 5-12", Belt__Belt_Float.fromString("not a float"), undefined);

eq("File \"jscomp/test/bs_float_test.ml\", line 35, characters 5-12", String(1.0), "1");

eq("File \"jscomp/test/bs_float_test.ml\", line 36, characters 5-12", String(-1.0), "-1");

eq("File \"jscomp/test/bs_float_test.ml\", line 37, characters 5-12", String(-1.5), "-1.5");

eq("File \"jscomp/test/bs_float_test.ml\", line 41, characters 5-12", 2.0 + 3.0, 5.0);

eq("File \"jscomp/test/bs_float_test.ml\", line 42, characters 5-12", 2.0 - 3.0, -1.0);

eq("File \"jscomp/test/bs_float_test.ml\", line 43, characters 5-12", 2.0 * 3.0, 6.0);

eq("File \"jscomp/test/bs_float_test.ml\", line 44, characters 5-12", 3.0 / 2.0, 1.5);

Mt.from_pair_suites("File \"jscomp/test/bs_float_test.ml\", line 46, characters 23-30", suites.contents);

module.exports = {
  suites,
  test_id,
  eq,
  b,
  $$throw,
  neq,
}
/*  Not a pure module */
