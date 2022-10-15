'use strict';

var Mt = require("./mt.js");
var $$Map = require("melange/lib/js/map.js");
var Caml = require("melange/lib/js/caml.js");
var List = require("melange/lib/js/list.js");
var Curry = require("melange/lib/js/curry.js");

var compare = Caml.caml_int_compare;

var IntMap = $$Map.Make({
      compare: compare
    });

var m = List.fold_left((function (acc, param) {
        return Curry._3(IntMap.add, param[0], param[1], acc);
      }), IntMap.empty, {
      hd: [
        10,
        /* 'a' */97
      ],
      tl: {
        hd: [
          3,
          /* 'b' */98
        ],
        tl: {
          hd: [
            7,
            /* 'c' */99
          ],
          tl: {
            hd: [
              20,
              /* 'd' */100
            ],
            tl: /* [] */0
          }
        }
      }
    });

var compare$1 = Caml.caml_string_compare;

var SMap = $$Map.Make({
      compare: compare$1
    });

var s = List.fold_left((function (acc, param) {
        return Curry._3(SMap.add, param[0], param[1], acc);
      }), SMap.empty, {
      hd: [
        "10",
        /* 'a' */97
      ],
      tl: {
        hd: [
          "3",
          /* 'b' */98
        ],
        tl: {
          hd: [
            "7",
            /* 'c' */99
          ],
          tl: {
            hd: [
              "20",
              /* 'd' */100
            ],
            tl: /* [] */0
          }
        }
      }
    });

Mt.from_pair_suites("Map_find_test", {
      hd: [
        "int",
        (function (param) {
            return {
                    TAG: /* Eq */0,
                    _0: Curry._2(IntMap.find, 10, m),
                    _1: /* 'a' */97
                  };
          })
      ],
      tl: {
        hd: [
          "string",
          (function (param) {
              return {
                      TAG: /* Eq */0,
                      _0: Curry._2(SMap.find, "10", s),
                      _1: /* 'a' */97
                    };
            })
        ],
        tl: /* [] */0
      }
    });

/* IntMap Not a pure module */
