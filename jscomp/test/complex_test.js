'use strict';

var Mt = require("./mt.js");
var Complex = require("melange/lib/js/complex.js");

var suites_0 = [
  "basic_add",
  (function (param) {
      return {
              TAG: /* Eq */0,
              _0: {
                re: 2,
                im: 2
              },
              _1: Complex.add(Complex.add(Complex.add(Complex.one, Complex.one), Complex.i), Complex.i)
            };
    })
];

var suites = {
  hd: suites_0,
  tl: /* [] */0
};

Mt.from_pair_suites("Complex_test", suites);

exports.suites = suites;
/*  Not a pure module */
