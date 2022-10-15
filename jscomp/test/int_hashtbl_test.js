'use strict';

var Mt = require("./mt.js");
var Caml = require("melange/lib/js/caml.js");
var List = require("melange/lib/js/list.js");
var $$Array = require("melange/lib/js/array.js");
var Curry = require("melange/lib/js/curry.js");
var Hashtbl = require("melange/lib/js/hashtbl.js");

function f(H) {
  var tbl = Curry._1(H.create, 17);
  Curry._3(H.add, tbl, 1, /* '1' */49);
  Curry._3(H.add, tbl, 2, /* '2' */50);
  return List.sort((function (param, param$1) {
                return Caml.caml_int_compare(param[0], param$1[0]);
              }), Curry._3(H.fold, (function (k, v, acc) {
                    return {
                            hd: [
                              k,
                              v
                            ],
                            tl: acc
                          };
                  }), tbl, /* [] */0));
}

function g(H) {
  return function (count) {
    var tbl = Curry._1(H.create, 17);
    for(var i = 0; i <= count; ++i){
      Curry._3(H.replace, tbl, (i << 1), String(i));
    }
    for(var i$1 = 0; i$1 <= count; ++i$1){
      Curry._3(H.replace, tbl, (i$1 << 1), String(i$1));
    }
    var v = Curry._3(H.fold, (function (k, v, acc) {
            return {
                    hd: [
                      k,
                      v
                    ],
                    tl: acc
                  };
          }), tbl, /* [] */0);
    return $$Array.of_list(List.sort((function (param, param$1) {
                      return Caml.caml_int_compare(param[0], param$1[0]);
                    }), v));
  };
}

var hash = Hashtbl.hash;

function equal(x, y) {
  return x === y;
}

var Int_hash = Hashtbl.Make({
      equal: equal,
      hash: hash
    });

var suites_0 = [
  "simple",
  (function (param) {
      return {
              TAG: /* Eq */0,
              _0: {
                hd: [
                  1,
                  /* '1' */49
                ],
                tl: {
                  hd: [
                    2,
                    /* '2' */50
                  ],
                  tl: /* [] */0
                }
              },
              _1: f(Int_hash)
            };
    })
];

var suites_1 = {
  hd: [
    "more_iterations",
    (function (param) {
        return {
                TAG: /* Eq */0,
                _0: $$Array.init(1001, (function (i) {
                        return [
                                (i << 1),
                                String(i)
                              ];
                      })),
                _1: g(Int_hash)(1000)
              };
      })
  ],
  tl: /* [] */0
};

var suites = {
  hd: suites_0,
  tl: suites_1
};

Mt.from_pair_suites("Int_hashtbl_test", suites);

exports.f = f;
exports.g = g;
exports.Int_hash = Int_hash;
exports.suites = suites;
/* Int_hash Not a pure module */
