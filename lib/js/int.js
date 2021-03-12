'use strict';

var Caml_format = require("./caml_format.js");
var Caml_primitive = require("./caml_primitive.js");

function abs(x) {
  if (x >= 0) {
    return x;
  } else {
    return -x | 0;
  }
}

var min_int = -2147483648;

function lognot(x) {
  return x ^ -1;
}

function equal(prim, prim$1) {
  return prim === prim$1;
}

var compare = Caml_primitive.caml_int_compare;

function to_string(x) {
  return Caml_format.caml_format_int("%d", x);
}

var zero = 0;

var one = 1;

var minus_one = -1;

var max_int = 2147483647;

exports.zero = zero;
exports.one = one;
exports.minus_one = minus_one;
exports.abs = abs;
exports.max_int = max_int;
exports.min_int = min_int;
exports.lognot = lognot;
exports.equal = equal;
exports.compare = compare;
exports.to_string = to_string;
/* No side effect */
