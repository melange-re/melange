'use strict';

var Mt = require("./mt.js");
var Stdlib__no_aliases = require("../../lib/js/stdlib__no_aliases.js");

var ff = Stdlib__no_aliases.string_of_float;

function f(v) {
  return String(v);
}

Mt.from_pair_suites("To_string_test", {
      hd: [
        "File \"to_string_test.ml\", line 7, characters 2-9",
        (function (param) {
            return {
                    TAG: /* Eq */0,
                    _0: Stdlib__no_aliases.string_of_float(Stdlib__no_aliases.infinity),
                    _1: "inf"
                  };
          })
      ],
      tl: {
        hd: [
          "File \"to_string_test.ml\", line 8, characters 1-8",
          (function (param) {
              return {
                      TAG: /* Eq */0,
                      _0: Stdlib__no_aliases.string_of_float(Stdlib__no_aliases.neg_infinity),
                      _1: "-inf"
                    };
            })
        ],
        tl: /* [] */0
      }
    });

exports.ff = ff;
exports.f = f;
/*  Not a pure module */
