'use strict';

var Mt = require("./mt.js");
var Caml = require("melange/lib/js/caml.js");
var Belt_Id = require("melange/jscomp/others/belt_Id.js");
var Belt_Map = require("melange/jscomp/others/belt_Map.js");
var Belt_Set = require("melange/jscomp/others/belt_Set.js");
var Belt_List = require("melange/jscomp/others/belt_List.js");
var Belt_Array = require("melange/jscomp/others/belt_Array.js");
var Belt_MapDict = require("melange/jscomp/others/belt_MapDict.js");
var Belt_SetDict = require("melange/jscomp/others/belt_SetDict.js");
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

function b(loc, v) {
  Mt.bool_suites(test_id, suites, loc, v);
}

var Icmp = Belt_Id.comparable(Caml.caml_int_compare);

var Icmp2 = Belt_Id.comparable(Caml.caml_int_compare);

var Ic3 = Belt_Id.comparable(Caml.caml_int_compare);

var m0 = Belt_Map.make(Icmp);

var m00 = Belt_Set.make(Ic3);

var I2 = Belt_Id.comparable(function (x, y) {
      return Caml.caml_int_compare(y, x);
    });

var m = Belt_Map.make(Icmp2);

var m2 = Belt_Map.make(I2);

var data = Belt_Map.getData(m);

Belt_Map.getId(m2);

var m_dict = Belt_Map.getId(m);

for(var i = 0; i <= 100000; ++i){
  data = Belt_MapDict.set(data, i, i, m_dict.cmp);
}

var newm = Belt_Map.packIdData(m_dict, data);

console.log(newm);

var m11 = Belt_MapDict.set(undefined, 1, 1, Icmp.cmp);

Belt_Map.make(Icmp);

console.log(m11);

var v = Belt_Set.make(Icmp2);

var m_dict$1 = Belt_Map.getId(m);

var cmp = m_dict$1.cmp;

var data$1 = Belt_Set.getData(v);

for(var i$1 = 0; i$1 <= 100000; ++i$1){
  data$1 = Belt_SetDict.add(data$1, i$1, cmp);
}

console.log(data$1);

function f(param) {
  return Belt_Map.fromArray(param, Icmp);
}

function $eq$tilde(a, b) {
  return function (param) {
    return Belt_Map.eq(a, b, param);
  };
}

var u0 = f(Belt_Array.map(Array_data_util.randomRange(0, 39), (function (x) {
            return [
                    x,
                    x
                  ];
          })));

var u1 = Belt_Map.set(u0, 39, 120);

b("File \"bs_map_set_dict_test.ml\", line 80, characters 4-11", Belt_Array.every2(Belt_Map.toArray(u0), Belt_Array.map(Array_data_util.range(0, 39), (function (x) {
                return [
                        x,
                        x
                      ];
              })), (function (param, param$1) {
            if (param[0] === param$1[0]) {
              return param[1] === param$1[1];
            } else {
              return false;
            }
          })));

b("File \"bs_map_set_dict_test.ml\", line 85, characters 4-11", Belt_List.every2(Belt_Map.toList(u0), Belt_List.fromArray(Belt_Array.map(Array_data_util.range(0, 39), (function (x) {
                    return [
                            x,
                            x
                          ];
                  }))), (function (param, param$1) {
            if (param[0] === param$1[0]) {
              return param[1] === param$1[1];
            } else {
              return false;
            }
          })));

eq("File \"bs_map_set_dict_test.ml\", line 90, characters 5-12", Belt_Map.get(u0, 39), 39);

eq("File \"bs_map_set_dict_test.ml\", line 91, characters 5-12", Belt_Map.get(u1, 39), 120);

var u = f(Belt_Array.makeByAndShuffle(10000, (function (x) {
            return [
                    x,
                    x
                  ];
          })));

eq("File \"bs_map_set_dict_test.ml\", line 97, characters 4-11", Belt_Array.makeBy(10000, (function (x) {
            return [
                    x,
                    x
                  ];
          })), Belt_Map.toArray(u));

Mt.from_pair_suites("Bs_map_set_dict_test", suites.contents);

var vv;

var vv2;

exports.suites = suites;
exports.test_id = test_id;
exports.eq = eq;
exports.b = b;
exports.Icmp = Icmp;
exports.Icmp2 = Icmp2;
exports.Ic3 = Ic3;
exports.m0 = m0;
exports.m00 = m00;
exports.I2 = I2;
exports.m = m;
exports.m2 = m2;
exports.vv = vv;
exports.vv2 = vv2;
exports.f = f;
exports.$eq$tilde = $eq$tilde;
/* Icmp Not a pure module */
