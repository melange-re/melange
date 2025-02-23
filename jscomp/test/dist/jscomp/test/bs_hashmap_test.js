// Generated by Melange
'use strict';

const Array_data_util = require("./array_data_util.js");
const Belt__Belt_Array = require("melange.belt/belt_Array.js");
const Belt__Belt_HashMap = require("melange.belt/belt_HashMap.js");
const Belt__Belt_Id = require("melange.belt/belt_Id.js");
const Belt__Belt_SortArray = require("melange.belt/belt_SortArray.js");
const Belt__Belt_internalBucketsType = require("melange.belt/belt_internalBucketsType.js");
const Caml = require("melange.js/caml.js");
const Mt = require("./mt.js");
const Stdlib__Hashtbl = require("melange/hashtbl.js");

const suites = {
  contents: /* [] */ 0
};

const test_id = {
  contents: 0
};

function eqx(loc, x, y) {
  Mt.eq_suites(test_id, suites, loc, x, y);
}

function b(loc, x) {
  Mt.bool_suites(test_id, suites, loc, x);
}

function eq(x, y) {
  return x === y;
}

const hash = Stdlib__Hashtbl.hash;

const cmp = Caml.caml_int_compare;

const Y = Belt__Belt_Id.hashable(hash, eq);

const empty = Belt__Belt_internalBucketsType.make(Y.hash, Y.eq, 30);

function add(prim0, prim1) {
  return prim0 + prim1 | 0;
}

Belt__Belt_HashMap.mergeMany(empty, [
  [
    1,
    1
  ],
  [
    2,
    3
  ],
  [
    3,
    3
  ],
  [
    2,
    2
  ]
]);

eqx("File \"jscomp/test/bs_hashmap_test.ml\", line 31, characters 6-13", Belt__Belt_HashMap.get(empty, 2), 2);

eqx("File \"jscomp/test/bs_hashmap_test.ml\", line 32, characters 6-13", empty.size, 3);

const u = Belt__Belt_Array.concat(Array_data_util.randomRange(30, 100), Array_data_util.randomRange(40, 120));

const v = Belt__Belt_Array.zip(u, u);

const xx = Belt__Belt_HashMap.fromArray(v, Y);

eqx("File \"jscomp/test/bs_hashmap_test.ml\", line 41, characters 6-13", xx.size, 91);

eqx("File \"jscomp/test/bs_hashmap_test.ml\", line 42, characters 6-13", Belt__Belt_SortArray.stableSortBy(Belt__Belt_HashMap.keysToArray(xx), cmp), Array_data_util.range(30, 120));

const u$1 = Belt__Belt_Array.concat(Array_data_util.randomRange(0, 100000), Array_data_util.randomRange(0, 100));

const v$1 = Belt__Belt_internalBucketsType.make(Y.hash, Y.eq, 40);

Belt__Belt_HashMap.mergeMany(v$1, Belt__Belt_Array.zip(u$1, u$1));

eqx("File \"jscomp/test/bs_hashmap_test.ml\", line 48, characters 6-13", v$1.size, 100001);

for (let i = 0; i <= 1000; ++i) {
  Belt__Belt_HashMap.remove(v$1, i);
}

eqx("File \"jscomp/test/bs_hashmap_test.ml\", line 52, characters 6-13", v$1.size, 99000);

for (let i$1 = 0; i$1 <= 2000; ++i$1) {
  Belt__Belt_HashMap.remove(v$1, i$1);
}

eqx("File \"jscomp/test/bs_hashmap_test.ml\", line 56, characters 6-13", v$1.size, 98000);

b("File \"jscomp/test/bs_hashmap_test.ml\", line 57, characters 4-11", Belt__Belt_Array.every(Array_data_util.range(2001, 100000), (function (x) {
  return Belt__Belt_HashMap.has(v$1, x);
})));

Mt.from_pair_suites("Bs_hashmap_test", suites.contents);

const $plus$plus = Belt__Belt_Array.concat;

module.exports = {
  suites,
  test_id,
  eqx,
  b,
  eq,
  hash,
  cmp,
  Y,
  empty,
  $plus$plus,
  add,
}
/* Y Not a pure module */
