'use strict';

var Mt = require("./mt.js");
var $$Map = require("melange/jscomp/stdlib-412/stdlib_modules/map.js");
var Caml = require("melange/lib/js/caml.js");
var List = require("melange/jscomp/stdlib-412/stdlib_modules/list.js");
var Curry = require("melange/lib/js/curry.js");
var $$String = require("melange/jscomp/stdlib-412/stdlib_modules/string.js");

var compare = Caml.caml_int_compare;

var Int = {
  compare: compare
};

var Int_map = $$Map.Make(Int);

var String_map = $$Map.Make({
      compare: $$String.compare
    });

function of_list(kvs) {
  return List.fold_left((function (acc, param) {
                return Curry._3(Int_map.add, param[0], param[1], acc);
              }), Int_map.empty, kvs);
}

var int_map_suites_0 = [
  "add",
  (function (param) {
      var v = of_list({
            hd: [
              1,
              /* '1' */49
            ],
            tl: {
              hd: [
                2,
                /* '3' */51
              ],
              tl: {
                hd: [
                  3,
                  /* '4' */52
                ],
                tl: /* [] */0
              }
            }
          });
      return {
              TAG: /* Eq */0,
              _0: Curry._1(Int_map.cardinal, v),
              _1: 3
            };
    })
];

var int_map_suites_1 = {
  hd: [
    "equal",
    (function (param) {
        var v = of_list({
              hd: [
                1,
                /* '1' */49
              ],
              tl: {
                hd: [
                  2,
                  /* '3' */51
                ],
                tl: {
                  hd: [
                    3,
                    /* '4' */52
                  ],
                  tl: /* [] */0
                }
              }
            });
        var u = of_list({
              hd: [
                2,
                /* '3' */51
              ],
              tl: {
                hd: [
                  3,
                  /* '4' */52
                ],
                tl: {
                  hd: [
                    1,
                    /* '1' */49
                  ],
                  tl: /* [] */0
                }
              }
            });
        return {
                TAG: /* Eq */0,
                _0: Curry._3(Int_map.compare, Caml.caml_int_compare, u, v),
                _1: 0
              };
      })
  ],
  tl: {
    hd: [
      "equal2",
      (function (param) {
          var v = of_list({
                hd: [
                  1,
                  /* '1' */49
                ],
                tl: {
                  hd: [
                    2,
                    /* '3' */51
                  ],
                  tl: {
                    hd: [
                      3,
                      /* '4' */52
                    ],
                    tl: /* [] */0
                  }
                }
              });
          var u = of_list({
                hd: [
                  2,
                  /* '3' */51
                ],
                tl: {
                  hd: [
                    3,
                    /* '4' */52
                  ],
                  tl: {
                    hd: [
                      1,
                      /* '1' */49
                    ],
                    tl: /* [] */0
                  }
                }
              });
          return {
                  TAG: /* Eq */0,
                  _0: true,
                  _1: Curry._3(Int_map.equal, (function (x, y) {
                          return x === y;
                        }), u, v)
                };
        })
    ],
    tl: {
      hd: [
        "iteration",
        (function (param) {
            var m = String_map.empty;
            for(var i = 0; i <= 10000; ++i){
              m = Curry._3(String_map.add, String(i), String(i), m);
            }
            var v = -1;
            for(var i$1 = 0; i$1 <= 10000; ++i$1){
              if (Curry._2(String_map.find, String(i$1), m) !== String(i$1)) {
                v = i$1;
              }
              
            }
            return {
                    TAG: /* Eq */0,
                    _0: v,
                    _1: -1
                  };
          })
      ],
      tl: /* [] */0
    }
  }
};

var int_map_suites = {
  hd: int_map_suites_0,
  tl: int_map_suites_1
};

Mt.from_pair_suites("Map_test", int_map_suites);

/* Int_map Not a pure module */
