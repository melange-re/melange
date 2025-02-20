// Generated by Melange
'use strict';

const Curry = require("melange.js/curry.js");
const Mt = require("./mt.js");
const Stdlib__Format = require("melange/format.js");
const Stdlib__Printf = require("melange/printf.js");

function print_pair(fmt, param) {
  Curry._2(Stdlib__Format.fprintf(fmt)({
    TAG: /* Format */ 0,
    _0: {
      TAG: /* Char_literal */ 12,
      _0: /* '(' */40,
      _1: {
        TAG: /* Int */ 4,
        _0: /* Int_d */ 0,
        _1: /* No_padding */ 0,
        _2: /* No_precision */ 0,
        _3: {
          TAG: /* Char_literal */ 12,
          _0: /* ',' */44,
          _1: {
            TAG: /* Int */ 4,
            _0: /* Int_d */ 0,
            _1: /* No_padding */ 0,
            _2: /* No_precision */ 0,
            _3: {
              TAG: /* Char_literal */ 12,
              _0: /* ')' */41,
              _1: /* End_of_format */ 0
            }
          }
        }
      }
    },
    _1: "(%d,%d)"
  }), param[0], param[1]);
}

const suites_0 = [
  "sprintf_simple",
  (function (param) {
    return {
      TAG: /* Eq */ 0,
      _0: "3232",
      _1: Curry._2(Stdlib__Printf.sprintf({
        TAG: /* Format */ 0,
        _0: {
          TAG: /* String */ 2,
          _0: /* No_padding */ 0,
          _1: {
            TAG: /* Int */ 4,
            _0: /* Int_d */ 0,
            _1: /* No_padding */ 0,
            _2: /* No_precision */ 0,
            _3: /* End_of_format */ 0
          }
        },
        _1: "%s%d"
      }), "32", 32)
    };
  })
];

const suites_1 = {
  hd: [
    "print_asprintf",
    (function (param) {
      return {
        TAG: /* Eq */ 0,
        _0: "xx",
        _1: Stdlib__Format.asprintf({
          TAG: /* Format */ 0,
          _0: {
            TAG: /* String_literal */ 11,
            _0: "xx",
            _1: /* End_of_format */ 0
          },
          _1: "xx"
        })
      };
    })
  ],
  tl: {
    hd: [
      "print_pair",
      (function (param) {
        return {
          TAG: /* Eq */ 0,
          _0: "(1,2)",
          _1: Curry._2(Stdlib__Format.asprintf({
            TAG: /* Format */ 0,
            _0: {
              TAG: /* Alpha */ 15,
              _0: /* End_of_format */ 0
            },
            _1: "%a"
          }), print_pair, [
            1,
            2
          ])
        };
      })
    ],
    tl: /* [] */ 0
  }
};

const suites = {
  hd: suites_0,
  tl: suites_1
};

const v = Stdlib__Format.asprintf({
  TAG: /* Format */ 0,
  _0: {
    TAG: /* String_literal */ 11,
    _0: "xx",
    _1: /* End_of_format */ 0
  },
  _1: "xx"
});

Mt.from_pair_suites("Printf_test", suites);

module.exports = {
  print_pair,
  suites,
  v,
}
/* v Not a pure module */
