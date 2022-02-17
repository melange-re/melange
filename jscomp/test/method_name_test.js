'use strict';

var Mt = require("./mt.js");

var suites = {
  contents: /* [] */0
};

var test_id = {
  contents: 0
};

function eq(loc, x, y) {
  test_id.contents = test_id.contents + 1 | 0;
  suites.contents = {
    hd: [
      loc + (" id " + String(test_id.contents)),
      (function (param) {
          return {
                  TAG: /* Eq */0,
                  _0: x,
                  _1: y
                };
        })
    ],
    tl: suites.contents
  };
}

function f(x, i, file, v) {
  x.case(i);
  x.case(i, v);
  x.open(file);
  x.open(file);
  return x.MAX_LENGTH;
}

function ff(x, i, v) {
  x.make = v;
  x.make_config = v;
  x.case(i);
  return x._open(3);
}

var u = {
  "Content'type": "x"
};

var h = {
  open: 3,
  end: 32
};

function hg(x) {
  return x.open + x.end | 0;
}

eq("File \"method_name_test.ml\", line 39, characters 12-19", 35, hg(h));

Mt.from_pair_suites("Method_name_test", suites.contents);

exports.suites = suites;
exports.test_id = test_id;
exports.eq = eq;
exports.f = f;
exports.ff = ff;
exports.u = u;
exports.h = h;
exports.hg = hg;
/*  Not a pure module */
