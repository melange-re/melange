'use strict';

var Mt = require("./mt.js");
var Caml = require("melange/lib/js/caml.js");
var Belt_Id = require("melange/jscomp/others/belt_Id.js");
var Belt_Set = require("melange/jscomp/others/belt_Set.js");
var Caml_obj = require("melange/lib/js/caml_obj.js");
var Belt_List = require("melange/jscomp/others/belt_List.js");
var Belt_Array = require("melange/jscomp/others/belt_Array.js");
var Belt_SetDict = require("melange/jscomp/others/belt_SetDict.js");
var Belt_SortArray = require("melange/jscomp/others/belt_SortArray.js");
var Array_data_util = require("./array_data_util.js");

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

function t(loc, x) {
  Mt.throw_suites(test_id, suites, loc, x);
}

var IntCmp = Belt_Id.comparable(Caml.caml_int_compare);

var u0 = Belt_Set.fromArray(Array_data_util.range(0, 30), IntCmp);

var u1 = Belt_Set.remove(u0, 0);

var u2 = Belt_Set.remove(u1, 0);

var u3 = Belt_Set.remove(u2, 30);

var u4 = Belt_Set.remove(u3, 20);

var r = Array_data_util.randomRange(0, 30);

var u5 = Belt_Set.add(u4, 3);

var u6 = Belt_Set.removeMany(u5, r);

var u7 = Belt_Set.mergeMany(u6, [
      0,
      1,
      2,
      0
    ]);

var u8 = Belt_Set.removeMany(u7, [
      0,
      1,
      2,
      3
    ]);

var u9 = Belt_Set.mergeMany(u8, Array_data_util.randomRange(0, 20000));

var u10 = Belt_Set.mergeMany(u9, Array_data_util.randomRange(0, 200));

var u11 = Belt_Set.removeMany(u10, Array_data_util.randomRange(0, 200));

var u12 = Belt_Set.removeMany(u11, Array_data_util.randomRange(0, 1000));

var u13 = Belt_Set.removeMany(u12, Array_data_util.randomRange(0, 1000));

var u14 = Belt_Set.removeMany(u13, Array_data_util.randomRange(1000, 10000));

var u15 = Belt_Set.removeMany(u14, Array_data_util.randomRange(10000, 19999));

var u16 = Belt_Set.removeMany(u15, Array_data_util.randomRange(20000, 21000));

b("File \"bs_poly_set_test.ml\", line 35, characters 4-11", u0 !== u1);

b("File \"bs_poly_set_test.ml\", line 36, characters 4-11", u2 === u1);

eq("File \"bs_poly_set_test.ml\", line 37, characters 5-12", Belt_Set.size(u4), 28);

b("File \"bs_poly_set_test.ml\", line 38, characters 4-11", 29 === Belt_Set.maxUndefined(u4));

b("File \"bs_poly_set_test.ml\", line 39, characters 4-11", 1 === Belt_Set.minUndefined(u4));

b("File \"bs_poly_set_test.ml\", line 40, characters 4-11", u4 === u5);

b("File \"bs_poly_set_test.ml\", line 41, characters 4-11", Belt_Set.isEmpty(u6));

eq("File \"bs_poly_set_test.ml\", line 42, characters 6-13", Belt_Set.size(u7), 3);

b("File \"bs_poly_set_test.ml\", line 43, characters 4-11", !Belt_Set.isEmpty(u7));

b("File \"bs_poly_set_test.ml\", line 44, characters 4-11", Belt_Set.isEmpty(u8));

b("File \"bs_poly_set_test.ml\", line 47, characters 4-11", Belt_Set.has(u10, 20));

b("File \"bs_poly_set_test.ml\", line 48, characters 4-11", Belt_Set.has(u10, 21));

eq("File \"bs_poly_set_test.ml\", line 49, characters 5-12", Belt_Set.size(u10), 20001);

eq("File \"bs_poly_set_test.ml\", line 50, characters 5-12", Belt_Set.size(u11), 19800);

eq("File \"bs_poly_set_test.ml\", line 51, characters 5-12", Belt_Set.size(u12), 19000);

eq("File \"bs_poly_set_test.ml\", line 53, characters 5-12", Belt_Set.size(u13), Belt_Set.size(u12));

eq("File \"bs_poly_set_test.ml\", line 54, characters 5-12", Belt_Set.size(u14), 10000);

eq("File \"bs_poly_set_test.ml\", line 55, characters 5-12", Belt_Set.size(u15), 1);

b("File \"bs_poly_set_test.ml\", line 56, characters 4-11", Belt_Set.has(u15, 20000));

b("File \"bs_poly_set_test.ml\", line 57, characters 4-11", !Belt_Set.has(u15, 2000));

b("File \"bs_poly_set_test.ml\", line 58, characters 4-11", Belt_Set.isEmpty(u16));

var u17 = Belt_Set.fromArray(Array_data_util.randomRange(0, 100), IntCmp);

var u18 = Belt_Set.fromArray(Array_data_util.randomRange(59, 200), IntCmp);

var u19 = Belt_Set.union(u17, u18);

var u20 = Belt_Set.fromArray(Array_data_util.randomRange(0, 200), IntCmp);

var u21 = Belt_Set.intersect(u17, u18);

var u22 = Belt_Set.diff(u17, u18);

var u23 = Belt_Set.diff(u18, u17);

var u24 = Belt_Set.union(u18, u17);

var u25 = Belt_Set.add(u22, 59);

var u26 = Belt_Set.add(Belt_Set.make(IntCmp), 3);

var ss = Belt_Array.makeByAndShuffle(100, (function (i) {
        return (i << 1);
      }));

var u27 = Belt_Set.fromArray(ss, IntCmp);

var u28 = Belt_Set.union(u27, u26);

var u29 = Belt_Set.union(u26, u27);

b("File \"bs_poly_set_test.ml\", line 72, characters 4-11", Belt_Set.eq(u28, u29));

b("File \"bs_poly_set_test.ml\", line 73, characters 4-11", Caml_obj.caml_equal(Belt_Set.toArray(u29), Belt_SortArray.stableSortBy(Belt_Array.concat(ss, [3]), Caml.caml_int_compare)));

b("File \"bs_poly_set_test.ml\", line 74, characters 4-11", Belt_Set.eq(u19, u20));

eq("File \"bs_poly_set_test.ml\", line 75, characters 5-12", Belt_Set.toArray(u21), Array_data_util.range(59, 100));

eq("File \"bs_poly_set_test.ml\", line 76, characters 5-12", Belt_Set.toArray(u22), Array_data_util.range(0, 58));

b("File \"bs_poly_set_test.ml\", line 77, characters 4-11", Belt_Set.eq(u24, u19));

eq("File \"bs_poly_set_test.ml\", line 78, characters 5-12", Belt_Set.toArray(u23), Array_data_util.range(101, 200));

b("File \"bs_poly_set_test.ml\", line 79, characters 4-11", Belt_Set.subset(u23, u18));

b("File \"bs_poly_set_test.ml\", line 80, characters 4-11", !Belt_Set.subset(u18, u23));

b("File \"bs_poly_set_test.ml\", line 81, characters 4-11", Belt_Set.subset(u22, u17));

b("File \"bs_poly_set_test.ml\", line 82, characters 4-11", Belt_Set.subset(u21, u17) && Belt_Set.subset(u21, u18));

b("File \"bs_poly_set_test.ml\", line 83, characters 4-11", 47 === Belt_Set.getUndefined(u22, 47));

b("File \"bs_poly_set_test.ml\", line 84, characters 4-11", Caml_obj.caml_equal(47, Belt_Set.get(u22, 47)));

b("File \"bs_poly_set_test.ml\", line 85, characters 4-11", Belt_Set.getUndefined(u22, 59) === undefined);

b("File \"bs_poly_set_test.ml\", line 86, characters 4-11", undefined === Belt_Set.get(u22, 59));

eq("File \"bs_poly_set_test.ml\", line 88, characters 5-12", Belt_Set.size(u25), 60);

b("File \"bs_poly_set_test.ml\", line 89, characters 4-11", Belt_Set.minimum(Belt_Set.make(IntCmp)) === undefined);

b("File \"bs_poly_set_test.ml\", line 90, characters 4-11", Belt_Set.maximum(Belt_Set.make(IntCmp)) === undefined);

b("File \"bs_poly_set_test.ml\", line 91, characters 4-11", Belt_Set.minUndefined(Belt_Set.make(IntCmp)) === undefined);

b("File \"bs_poly_set_test.ml\", line 92, characters 4-11", Belt_Set.maxUndefined(Belt_Set.make(IntCmp)) === undefined);

function testIterToList(xs) {
  var v = {
    contents: /* [] */0
  };
  Belt_Set.forEach(xs, (function (x) {
          v.contents = {
            hd: x,
            tl: v.contents
          };
        }));
  return Belt_List.reverse(v.contents);
}

function testIterToList2(xs) {
  var v = {
    contents: /* [] */0
  };
  Belt_SetDict.forEach(Belt_Set.getData(xs), (function (x) {
          v.contents = {
            hd: x,
            tl: v.contents
          };
        }));
  return Belt_List.reverse(v.contents);
}

var u0$1 = Belt_Set.fromArray(Array_data_util.randomRange(0, 20), IntCmp);

var u1$1 = Belt_Set.remove(u0$1, 17);

var u2$1 = Belt_Set.add(u1$1, 33);

b("File \"bs_poly_set_test.ml\", line 109, characters 4-11", Belt_List.every2(testIterToList(u0$1), Belt_List.makeBy(21, (function (i) {
                return i;
              })), (function (x, y) {
            return x === y;
          })));

b("File \"bs_poly_set_test.ml\", line 110, characters 4-11", Belt_List.every2(testIterToList2(u0$1), Belt_List.makeBy(21, (function (i) {
                return i;
              })), (function (x, y) {
            return x === y;
          })));

b("File \"bs_poly_set_test.ml\", line 111, characters 4-11", Belt_List.every2(testIterToList(u0$1), Belt_Set.toList(u0$1), (function (x, y) {
            return x === y;
          })));

b("File \"bs_poly_set_test.ml\", line 112, characters 4-11", Belt_Set.some(u0$1, (function (x) {
            return x === 17;
          })));

b("File \"bs_poly_set_test.ml\", line 113, characters 4-11", !Belt_Set.some(u1$1, (function (x) {
            return x === 17;
          })));

b("File \"bs_poly_set_test.ml\", line 114, characters 4-11", Belt_Set.every(u0$1, (function (x) {
            return x < 24;
          })));

b("File \"bs_poly_set_test.ml\", line 115, characters 4-11", Belt_SetDict.every(Belt_Set.getData(u0$1), (function (x) {
            return x < 24;
          })));

b("File \"bs_poly_set_test.ml\", line 116, characters 4-11", !Belt_Set.every(u2$1, (function (x) {
            return x < 24;
          })));

b("File \"bs_poly_set_test.ml\", line 117, characters 4-11", !Belt_Set.every(Belt_Set.fromArray([
              1,
              2,
              3
            ], IntCmp), (function (x) {
            return x === 2;
          })));

b("File \"bs_poly_set_test.ml\", line 118, characters 4-11", Belt_Set.cmp(u1$1, u0$1) < 0);

b("File \"bs_poly_set_test.ml\", line 119, characters 4-11", Belt_Set.cmp(u0$1, u1$1) > 0);

var a0 = Belt_Set.fromArray(Array_data_util.randomRange(0, 1000), IntCmp);

var a1 = Belt_Set.keep(a0, (function (x) {
        return x % 2 === 0;
      }));

var a2 = Belt_Set.keep(a0, (function (x) {
        return x % 2 !== 0;
      }));

var match = Belt_Set.partition(a0, (function (x) {
        return x % 2 === 0;
      }));

var a4 = match[1];

var a3 = match[0];

b("File \"bs_poly_set_test.ml\", line 129, characters 4-11", Belt_Set.eq(a1, a3));

b("File \"bs_poly_set_test.ml\", line 130, characters 4-11", Belt_Set.eq(a2, a4));

eq("File \"bs_poly_set_test.ml\", line 131, characters 5-12", Belt_Set.getExn(a0, 3), 3);

eq("File \"bs_poly_set_test.ml\", line 132, characters 5-12", Belt_Set.getExn(a0, 4), 4);

t("File \"bs_poly_set_test.ml\", line 133, characters 4-11", (function (param) {
        Belt_Set.getExn(a0, 1002);
      }));

t("File \"bs_poly_set_test.ml\", line 134, characters 4-11", (function (param) {
        Belt_Set.getExn(a0, -1);
      }));

eq("File \"bs_poly_set_test.ml\", line 135, characters 5-12", Belt_Set.size(a0), 1001);

b("File \"bs_poly_set_test.ml\", line 136, characters 4-11", !Belt_Set.isEmpty(a0));

var match$1 = Belt_Set.split(a0, 200);

var match$2 = match$1[0];

b("File \"bs_poly_set_test.ml\", line 138, characters 4-11", match$1[1]);

eq("File \"bs_poly_set_test.ml\", line 139, characters 5-12", Belt_Set.toArray(match$2[0]), Belt_Array.makeBy(200, (function (i) {
            return i;
          })));

eq("File \"bs_poly_set_test.ml\", line 140, characters 5-12", Belt_Set.toList(match$2[1]), Belt_List.makeBy(800, (function (i) {
            return i + 201 | 0;
          })));

var a7 = Belt_Set.remove(a0, 200);

var match$3 = Belt_Set.split(a7, 200);

var match$4 = match$3[0];

var a9 = match$4[1];

var a8 = match$4[0];

b("File \"bs_poly_set_test.ml\", line 143, characters 4-11", !match$3[1]);

eq("File \"bs_poly_set_test.ml\", line 144, characters 5-12", Belt_Set.toArray(a8), Belt_Array.makeBy(200, (function (i) {
            return i;
          })));

eq("File \"bs_poly_set_test.ml\", line 145, characters 5-12", Belt_Set.toList(a9), Belt_List.makeBy(800, (function (i) {
            return i + 201 | 0;
          })));

eq("File \"bs_poly_set_test.ml\", line 146, characters 5-12", Belt_Set.minimum(a8), 0);

eq("File \"bs_poly_set_test.ml\", line 147, characters 5-12", Belt_Set.minimum(a9), 201);

Belt_List.forEach({
      hd: a0,
      tl: {
        hd: a1,
        tl: {
          hd: a2,
          tl: {
            hd: a3,
            tl: {
              hd: a4,
              tl: /* [] */0
            }
          }
        }
      }
    }, Belt_Set.checkInvariantInternal);

var a = Belt_Set.fromArray([], IntCmp);

b("File \"bs_poly_set_test.ml\", line 153, characters 4-11", Belt_Set.isEmpty(Belt_Set.keep(a, (function (x) {
                return x % 2 === 0;
              }))));

var match$5 = Belt_Set.split(Belt_Set.make(IntCmp), 0);

var match$6 = match$5[0];

b("File \"bs_poly_set_test.ml\", line 157, characters 4-11", Belt_Set.isEmpty(match$6[0]));

b("File \"bs_poly_set_test.ml\", line 158, characters 4-11", Belt_Set.isEmpty(match$6[1]));

b("File \"bs_poly_set_test.ml\", line 159, characters 4-11", !match$5[1]);

Mt.from_pair_suites("Bs_poly_set_test", suites.contents);

exports.suites = suites;
exports.test_id = test_id;
exports.eq = eq;
exports.b = b;
exports.t = t;
exports.IntCmp = IntCmp;
exports.testIterToList = testIterToList;
exports.testIterToList2 = testIterToList2;
/* IntCmp Not a pure module */
