'use strict';

var Curry = require("../../lib/js/curry");

function map(f, ls) {
  if (ls) {
    return /* :: */[
            f(ls[0]),
            map(f, ls[1])
          ];
  }
  else {
    return /* [] */0;
  }
}

function map2(f, ls) {
  return map(Curry.__1(f), ls);
}

function map3(ls) {
  return map(function (x) {
              return x + 1 | 0;
            }, ls);
}

function uu(f) {
  return function () {
    return Curry._1(f, /* () */0);
  };
}

function small_should_inline(x, y) {
  return x + y | 0;
}

function small_should_inline2(x, y) {
  return x + y | 0;
}

var b = small_should_inline2(1, 2);

function f(x, y) {
  console.log(/* tuple */[
        x,
        y
      ]);
  return x + y | 0;
}

function opt_f($staropt$star, y) {
  var x = $staropt$star ? $staropt$star[0] : 3;
  return f(x, y);
}

opt_f(/* None */0, 3);

var v = opt_f(/* Some */[2], 3);

var a = 3;

exports.map                  = map;
exports.map2                 = map2;
exports.map3                 = map3;
exports.uu                   = uu;
exports.small_should_inline  = small_should_inline;
exports.a                    = a;
exports.small_should_inline2 = small_should_inline2;
exports.b                    = b;
exports.f                    = f;
exports.opt_f                = opt_f;
exports.v                    = v;
/* small_should_inline2 Not a pure module */
