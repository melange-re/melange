'use strict';

var Mt = require("./mt.js");
var Curry = require("../../lib/js/curry.js");

var suites = {
  contents: /* [] */0
};

var test_id = {
  contents: 0
};

function eq(loc, x, y) {
  Mt.eq_suites(test_id, suites, loc, x, y);
}

var X = {};

function xx(obj, a0, a1, a2, a3, a4, a5) {
  return (Curry._2(a4, Curry._2(a2, Curry._2(a0, obj, a1), a3), a5) - 1 | 0) - 3 | 0;
}

eq("File \"gpr_3536_test.ml\", line 29, characters 12-19", 5, 5);

eq("File \"gpr_3536_test.ml\", line 32, characters 6-13", xx(3, (function (prim0, prim1) {
            return prim0 - prim1 | 0;
          }), 2, (function (prim0, prim1) {
            return prim0 + prim1 | 0;
          }), 4, (function (prim0, prim1) {
            return Math.imul(prim0, prim1);
          }), 3), 11);

Mt.from_pair_suites("Gpr_3536_test", suites.contents);

var v = 5;

var u = /* Some */{
  _0: 3
};

exports.suites = suites;
exports.test_id = test_id;
exports.eq = eq;
exports.v = v;
exports.X = X;
exports.u = u;
exports.xx = xx;
/*  Not a pure module */
