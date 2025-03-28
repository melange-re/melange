// Generated by Melange
'use strict';

const Caml = require("melange.js/caml.js");
const Curry = require("melange.js/curry.js");
const Mt = require("./mt.js");
const Stdlib__Array = require("melange/array.js");
const Stdlib__Hashtbl = require("melange/hashtbl.js");
const Stdlib__List = require("melange/list.js");

function f(H) {
  const tbl = Curry._1(H.create, 17);
  Curry._3(H.add, tbl, 1, /* '1' */49);
  Curry._3(H.add, tbl, 2, /* '2' */50);
  return Stdlib__List.sort((function (param, param$1) {
    return Caml.caml_int_compare(param[0], param$1[0]);
  }), Curry._3(H.fold, (function (k, v, acc) {
    return {
      hd: [
        k,
        v
      ],
      tl: acc
    };
  }), tbl, /* [] */ 0));
}

function g(H, count) {
  const tbl = Curry._1(H.create, 17);
  for (let i = 0; i <= count; ++i) {
    Curry._3(H.replace, tbl, (i << 1), String(i));
  }
  for (let i$1 = 0; i$1 <= count; ++i$1) {
    Curry._3(H.replace, tbl, (i$1 << 1), String(i$1));
  }
  const v = Curry._3(H.fold, (function (k, v, acc) {
    return {
      hd: [
        k,
        v
      ],
      tl: acc
    };
  }), tbl, /* [] */ 0);
  return Stdlib__Array.of_list(Stdlib__List.sort((function (param, param$1) {
    return Caml.caml_int_compare(param[0], param$1[0]);
  }), v));
}

const hash = Stdlib__Hashtbl.hash;

function equal(x, y) {
  return x === y;
}

const Int_hash = Stdlib__Hashtbl.Make({
  equal: equal,
  hash: hash
});

const suites_0 = [
  "simple",
  (function (param) {
    return {
      TAG: /* Eq */ 0,
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
          tl: /* [] */ 0
        }
      },
      _1: f(Int_hash)
    };
  })
];

const suites_1 = {
  hd: [
    "more_iterations",
    (function (param) {
      return {
        TAG: /* Eq */ 0,
        _0: Stdlib__Array.init(1001, (function (i) {
          return [
            (i << 1),
            String(i)
          ];
        })),
        _1: g(Int_hash, 1000)
      };
    })
  ],
  tl: /* [] */ 0
};

const suites = {
  hd: suites_0,
  tl: suites_1
};

Mt.from_pair_suites("Int_hashtbl_test", suites);

module.exports = {
  f,
  g,
  Int_hash,
  suites,
}
/* Int_hash Not a pure module */
