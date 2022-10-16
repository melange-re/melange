'use strict';

var Mt = require("./mt.js");
var Belt_Array = require("melange/lib/js/belt_Array.js");
var Belt_SetInt = require("melange/lib/js/belt_SetInt.js");
var Array_data_util = require("./array_data_util.js");
var Belt_HashSetInt = require("melange/lib/js/belt_HashSetInt.js");
var Belt_SortArrayInt = require("melange/lib/js/belt_SortArrayInt.js");
var Belt_internalBucketsType = require("melange/lib/js/belt_internalBucketsType.js");

var suites = {
  contents: /* [] */0
};

var test_id = {
  contents: 0
};

function eq(loc, x, y) {
  Mt.eq_suites(test_id, suites, loc, x, y);
}

function b(loc, x) {
  Mt.bool_suites(test_id, suites, loc, x);
}

function add(x, y) {
  return x + y | 0;
}

function sum2(h) {
  var v = {
    contents: 0
  };
  Belt_HashSetInt.forEach(h, (function (x) {
          v.contents = v.contents + x | 0;
        }));
  return v.contents;
}

var u = Belt_Array.concat(Array_data_util.randomRange(30, 100), Array_data_util.randomRange(40, 120));

var v = Belt_HashSetInt.fromArray(u);

eq("File \"bs_hashset_int_test.ml\", line 19, characters 5-12", v.size, 91);

var xs = Belt_SetInt.toArray(Belt_SetInt.fromArray(Belt_HashSetInt.toArray(v)));

eq("File \"bs_hashset_int_test.ml\", line 21, characters 5-12", xs, Array_data_util.range(30, 120));

eq("File \"bs_hashset_int_test.ml\", line 23, characters 5-12", Belt_HashSetInt.reduce(v, 0, add), 6825);

eq("File \"bs_hashset_int_test.ml\", line 24, characters 5-12", sum2(v), 6825);

var u$1 = Belt_Array.concat(Array_data_util.randomRange(0, 100000), Array_data_util.randomRange(0, 100));

var v$1 = Belt_internalBucketsType.make(undefined, undefined, 40);

Belt_HashSetInt.mergeMany(v$1, u$1);

eq("File \"bs_hashset_int_test.ml\", line 30, characters 5-12", v$1.size, 100001);

for(var i = 0; i <= 1000; ++i){
  Belt_HashSetInt.remove(v$1, i);
}

eq("File \"bs_hashset_int_test.ml\", line 34, characters 5-12", v$1.size, 99000);

for(var i$1 = 0; i$1 <= 2000; ++i$1){
  Belt_HashSetInt.remove(v$1, i$1);
}

eq("File \"bs_hashset_int_test.ml\", line 38, characters 5-12", v$1.size, 98000);

var u0 = Belt_HashSetInt.fromArray(Array_data_util.randomRange(0, 100000));

var u1 = Belt_HashSetInt.copy(u0);

eq("File \"bs_hashset_int_test.ml\", line 46, characters 5-12", Belt_HashSetInt.toArray(u0), Belt_HashSetInt.toArray(u1));

for(var i$2 = 0; i$2 <= 2000; ++i$2){
  Belt_HashSetInt.remove(u1, i$2);
}

for(var i$3 = 0; i$3 <= 1000; ++i$3){
  Belt_HashSetInt.remove(u0, i$3);
}

var v0 = Belt_Array.concat(Array_data_util.range(0, 1000), Belt_HashSetInt.toArray(u0));

var v1 = Belt_Array.concat(Array_data_util.range(0, 2000), Belt_HashSetInt.toArray(u1));

Belt_SortArrayInt.stableSortInPlace(v0);

Belt_SortArrayInt.stableSortInPlace(v1);

eq("File \"bs_hashset_int_test.ml\", line 57, characters 5-12", v0, v1);

var h = Belt_HashSetInt.fromArray(Array_data_util.randomRange(0, 1000000));

var histo = Belt_HashSetInt.getBucketHistogram(h);

b("File \"bs_hashset_int_test.ml\", line 62, characters 4-11", histo.length <= 10);

Mt.from_pair_suites("Bs_hashset_int_test", suites.contents);

var $plus$plus = Belt_Array.concat;

exports.suites = suites;
exports.test_id = test_id;
exports.eq = eq;
exports.b = b;
exports.$plus$plus = $plus$plus;
exports.add = add;
exports.sum2 = sum2;
/* u Not a pure module */
