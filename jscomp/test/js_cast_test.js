'use strict';

var Mt = require("./mt.js");

var suites = {
  contents: /* [] */0
};

var counter = {
  contents: 0
};

function add_test(loc, test) {
  counter.contents = counter.contents + 1 | 0;
  var id = loc + (" id " + String(counter.contents));
  suites.contents = {
    hd: [
      id,
      test
    ],
    tl: suites.contents
  };
}

function eq(loc, x, y) {
  add_test(loc, (function (param) {
          return {
                  TAG: /* Eq */0,
                  _0: x,
                  _1: y
                };
        }));
}

eq("File \"js_cast_test.ml\", line 13, characters 12-19", true, 1);

eq("File \"js_cast_test.ml\", line 15, characters 12-19", false, 0);

eq("File \"js_cast_test.ml\", line 17, characters 12-19", 0, 0.0);

eq("File \"js_cast_test.ml\", line 19, characters 12-19", 1, 1.0);

eq("File \"js_cast_test.ml\", line 21, characters 12-19", 123456789, 123456789.0);

Mt.from_pair_suites("Js_cast_test", suites.contents);

exports.suites = suites;
exports.add_test = add_test;
exports.eq = eq;
/*  Not a pure module */
