'use strict';

var Caml = require("./caml.js");
var Caml_int64 = require("./caml_int64.js");
var Caml_format = require("./caml_format.js");
var Caml_js_exceptions = require("./caml_js_exceptions.js");
var Stdlib__no_aliases = require("./stdlib__no_aliases.js");

var zero = Caml_int64.zero;

var one = Caml_int64.one;

function succ(n) {
  return Caml_int64.add(n, Caml_int64.one);
}

function pred(n) {
  return Caml_int64.sub(n, Caml_int64.one);
}

function abs(n) {
  if (Caml.i64_ge(n, Caml_int64.zero)) {
    return n;
  } else {
    return Caml_int64.neg(n);
  }
}

var min_int = Caml_int64.min_int;

function lognot(n) {
  return Caml_int64.xor(n, Caml_int64.neg_one);
}

var max_int = Caml_int64.of_int32(Stdlib__no_aliases.Stdlib.max_int);

function unsigned_to_int(n) {
  if (Caml_int64.compare(zero, n) <= 0 && Caml_int64.compare(n, max_int) <= 0) {
    return Caml_int64.to_int32(n);
  }
  
}

function to_string(n) {
  return Caml_format.caml_int64_format("%d", n);
}

function of_string_opt(s) {
  try {
    return Caml_format.caml_int64_of_string(s);
  }
  catch (raw_exn){
    var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
    if (exn.RE_EXN_ID === Stdlib__no_aliases.Failure) {
      return ;
    }
    throw exn;
  }
}

var compare = Caml_int64.compare;

function equal(x, y) {
  return Caml_int64.compare(x, y) === 0;
}

function unsigned_compare(n, m) {
  return Caml_int64.compare(Caml_int64.sub(n, min_int), Caml_int64.sub(m, min_int));
}

function unsigned_div(n, d) {
  if (Caml.i64_lt(d, zero)) {
    if (unsigned_compare(n, d) < 0) {
      return zero;
    } else {
      return one;
    }
  }
  var q = Caml_int64.lsl_(Caml_int64.div(Caml_int64.lsr_(n, 1), d), 1);
  var r = Caml_int64.sub(n, Caml_int64.mul(q, d));
  if (unsigned_compare(r, d) >= 0) {
    return Caml_int64.add(q, Caml_int64.one);
  } else {
    return q;
  }
}

function unsigned_rem(n, d) {
  return Caml_int64.sub(n, Caml_int64.mul(unsigned_div(n, d), d));
}

var minus_one = Caml_int64.neg_one;

var max_int$1 = Caml_int64.max_int;

exports.zero = zero;
exports.one = one;
exports.minus_one = minus_one;
exports.unsigned_div = unsigned_div;
exports.unsigned_rem = unsigned_rem;
exports.succ = succ;
exports.pred = pred;
exports.abs = abs;
exports.max_int = max_int$1;
exports.min_int = min_int;
exports.lognot = lognot;
exports.unsigned_to_int = unsigned_to_int;
exports.of_string_opt = of_string_opt;
exports.to_string = to_string;
exports.compare = compare;
exports.unsigned_compare = unsigned_compare;
exports.equal = equal;
/* No side effect */
