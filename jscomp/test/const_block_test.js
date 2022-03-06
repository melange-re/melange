'use strict';

var Mt = require("./mt.js");
var Caml_array = require("../../lib/js/caml_array.js");

var a = [
  0,
  1,
  2
];

var b = [
  0,
  1,
  2
];

var c = [
  0,
  1,
  2,
  3,
  4,
  5
];

function f(param) {
  Caml_array.set(a, 0, 3.0);
  Caml_array.set(b, 0, 3);
}

function h(param) {
  return c;
}

function g(param) {
  f(undefined);
  return {
          TAG: /* Eq */0,
          _0: [
            Caml_array.get(a, 0),
            Caml_array.get(b, 0)
          ],
          _1: [
            3.0,
            3
          ]
        };
}

var suites_0 = [
  "const_block_test",
  g
];

var suites_1 = {
  hd: [
    "avoid_mutable_inline_test",
    (function (param) {
        Caml_array.set(c, 0, 3);
        Caml_array.set(c, 1, 4);
        return {
                TAG: /* Eq */0,
                _0: [
                  3,
                  4,
                  2,
                  3,
                  4,
                  5
                ],
                _1: c
              };
      })
  ],
  tl: /* [] */0
};

var suites = {
  hd: suites_0,
  tl: suites_1
};

Mt.from_pair_suites("Const_block_test", suites);

var v = [
  0,
  1,
  2,
  3,
  4,
  5
];

exports.a = a;
exports.b = b;
exports.c = c;
exports.v = v;
exports.f = f;
exports.h = h;
/*  Not a pure module */
