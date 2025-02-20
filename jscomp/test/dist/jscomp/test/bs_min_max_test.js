// Generated by Melange
'use strict';

const Caml = require("melange.js/caml.js");
const Caml_int64 = require("melange.js/caml_int64.js");
const Caml_obj = require("melange.js/caml_obj.js");
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

function b(param, param$1) {
  return Mt.bool_suites(test_id, suites, param, param$1);
}

function f(x, y) {
  return Caml.caml_int_compare(x + y | 0, y + x | 0);
}

function f2(x, y) {
  return Caml.caml_int_compare(x + y | 0, y);
}

const f3 = Caml.caml_int_compare;

function f4(x, y) {
  if (x < y) {
    return x;
  } else {
    return y;
  }
}

const f5_min = Caml_obj.caml_min;

const f5_max = Caml_obj.caml_max;

b("File \"jscomp/test/bs_min_max_test.ml\", line 28, characters 4-11", Caml.i64_eq(Caml.i64_min(Caml_int64.zero, Caml_int64.one), Caml_int64.zero));

b("File \"jscomp/test/bs_min_max_test.ml\", line 29, characters 4-11", Caml.i64_eq(Caml.i64_max([
  0,
  22
], Caml_int64.one), [
  0,
  22
]));

b("File \"jscomp/test/bs_min_max_test.ml\", line 30, characters 4-11", Caml.i64_eq(Caml.i64_max([
  -1,
  4294967293
], [
  0,
  3
]), [
  0,
  3
]));

eq("File \"jscomp/test/bs_min_max_test.ml\", line 31, characters 5-12", Caml_obj.caml_min(undefined, 3), undefined);

eq("File \"jscomp/test/bs_min_max_test.ml\", line 32, characters 5-12", Caml_obj.caml_min(3, undefined), undefined);

eq("File \"jscomp/test/bs_min_max_test.ml\", line 33, characters 5-12", Caml_obj.caml_max(3, undefined), 3);

eq("File \"jscomp/test/bs_min_max_test.ml\", line 34, characters 5-12", Caml_obj.caml_max(undefined, 3), 3);

b("File \"jscomp/test/bs_min_max_test.ml\", line 35, characters 4-11", Caml_obj.caml_greaterequal(5, undefined));

b("File \"jscomp/test/bs_min_max_test.ml\", line 36, characters 4-11", Caml_obj.caml_lessequal(undefined, 5));

b("File \"jscomp/test/bs_min_max_test.ml\", line 37, characters 4-11", undefined !== 5);

b("File \"jscomp/test/bs_min_max_test.ml\", line 38, characters 4-11", undefined !== 5);

Mt.from_pair_suites("Bs_min_max_test", suites.contents);

module.exports = {
  suites,
  test_id,
  eq,
  b,
  f,
  f2,
  f3,
  f4,
  f5_min,
  f5_max,
}
/*  Not a pure module */
