// Generated by Melange
'use strict';

const Caml_bytes = require("melange.js/caml_bytes.js");
const Mt = require("./mt.js");
const Stdlib__Bytes = require("melange/bytes.js");
const Stdlib__List = require("melange/list.js");
const Test_char = require("./test_char.js");

const suites_0 = [
  "caml_is_printable",
  (function (param) {
    return {
      TAG: /* Eq */ 0,
      _0: Test_char.caml_is_printable(/* 'a' */97),
      _1: true
    };
  })
];

const suites_1 = {
  hd: [
    "caml_string_of_bytes",
    (function (param) {
      const match = Stdlib__List.split(Stdlib__List.map((function (x) {
        const b = Caml_bytes.caml_create_bytes(x);
        Stdlib__Bytes.fill(b, 0, x, /* 'c' */99);
        return [
          Stdlib__Bytes.to_string(b),
          Caml_bytes.bytes_to_string(Stdlib__Bytes.init(x, (function (param) {
            return /* 'c' */99;
          })))
        ];
      }), {
        hd: 1000,
        tl: {
          hd: 1024,
          tl: {
            hd: 1025,
            tl: {
              hd: 4095,
              tl: {
                hd: 4096,
                tl: {
                  hd: 5000,
                  tl: {
                    hd: 10000,
                    tl: /* [] */ 0
                  }
                }
              }
            }
          }
        }
      }));
      return {
        TAG: /* Eq */ 0,
        _0: match[0],
        _1: match[1]
      };
    })
  ],
  tl: /* [] */ 0
};

const suites = {
  hd: suites_0,
  tl: suites_1
};

Mt.from_pair_suites("String_runtime_test", suites);

module.exports = {
  suites,
}
/*  Not a pure module */
