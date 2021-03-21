

import * as Caml from "./caml.js";
import * as Caml_format from "./caml_format.js";

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

var compare = Caml.caml_int_compare;

function to_string(x) {
  return Caml_format.caml_format_int("%d", x);
}

var zero = 0;

var one = 1;

var minus_one = -1;

var max_int = 2147483647;

export {
  zero ,
  one ,
  minus_one ,
  abs ,
  max_int ,
  min_int ,
  lognot ,
  equal ,
  compare ,
  to_string ,
  
}
/* No side effect */
