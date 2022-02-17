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

function f(h) {
  return h.x.y.z;
}

function f2(h) {
  return h.x.y.z;
}

function f3(h, x, y) {
  return h.paint(x, y).draw(x, y);
}

function f4(h, x, y) {
  h.paint = [
    x,
    y
  ];
  h.paint.draw = [
    x,
    y
  ];
}

eq("File \"chain_code_test.ml\", line 28, characters 5-12", 32, ({
        x: {
          y: {
            z: 32
          }
        }
      }).x.y.z);

Mt.from_pair_suites("Chain_code_test", suites.contents);

exports.suites = suites;
exports.test_id = test_id;
exports.eq = eq;
exports.f = f;
exports.f2 = f2;
exports.f3 = f3;
exports.f4 = f4;
/*  Not a pure module */
