

import * as Sys from "./sys.js";
import * as Caml from "./caml.js";
import * as Caml_format from "./caml_format.js";
import * as Caml_js_exceptions from "./caml_js_exceptions.js";
import * as Stdlib__no_aliases from "./stdlib__no_aliases.js";

function succ(n) {
  return n + 1 | 0;
}

function pred(n) {
  return n - 1 | 0;
}

function abs(n) {
  if (n >= 0) {
    return n;
  } else {
    return -n | 0;
  }
}

function lognot(n) {
  return n ^ -1;
}

var unsigned_to_int;

if (Sys.word_size !== 32) {
  if (Sys.word_size !== 64) {
    throw {
          RE_EXN_ID: "Assert_failure",
          _1: [
            "int32.ml",
            69,
            6
          ],
          Error: new Error()
        };
  }
  var move = Caml_format.caml_int_of_string("0x1_0000_0000");
  unsigned_to_int = (function (n) {
      return n < 0 ? n + move | 0 : n;
    });
} else {
  var max_int = Stdlib__no_aliases.Stdlib.max_int;
  unsigned_to_int = (function (n) {
      if (0 <= n && n <= max_int) {
        return n;
      }
      
    });
}

function to_string(n) {
  return Caml_format.caml_int32_format("%d", n);
}

function of_string_opt(s) {
  try {
    return Caml_format.caml_int32_of_string(s);
  }
  catch (raw_exn){
    var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
    if (exn.RE_EXN_ID === Stdlib__no_aliases.Failure) {
      return ;
    }
    throw exn;
  }
}

var compare = Caml.caml_int_compare;

function equal(x, y) {
  return x === y;
}

function unsigned_compare(n, m) {
  return Caml.caml_int_compare(n - -2147483648 | 0, m - -2147483648 | 0);
}

function unsigned_div(n, d) {
  if (d < 0) {
    if (unsigned_compare(n, d) < 0) {
      return 0;
    } else {
      return 1;
    }
  }
  var q = (((n >>> 1) / d | 0) << 1);
  var r = n - Math.imul(q, d) | 0;
  if (unsigned_compare(r, d) >= 0) {
    return q + 1 | 0;
  } else {
    return q;
  }
}

function unsigned_rem(n, d) {
  return n - Math.imul(unsigned_div(n, d), d) | 0;
}

var zero = 0;

var one = 1;

var minus_one = -1;

var max_int$1 = 2147483647;

var min_int = -2147483648;

export {
  zero ,
  one ,
  minus_one ,
  unsigned_div ,
  unsigned_rem ,
  succ ,
  pred ,
  abs ,
  max_int$1 as max_int,
  min_int ,
  lognot ,
  unsigned_to_int ,
  of_string_opt ,
  to_string ,
  compare ,
  unsigned_compare ,
  equal ,
  
}
/* unsigned_to_int Not a pure module */
