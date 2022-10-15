'use strict';

var $$Map = require("melange/lib/js/map.js");
var Caml = require("melange/lib/js/caml.js");
var List = require("melange/lib/js/list.js");
var Curry = require("melange/lib/js/curry.js");

var compare = Caml.caml_int_compare;

var IntMap = $$Map.Make({
      compare: compare
    });

List.fold_left((function (acc, param) {
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

/* IntMap Not a pure module */
