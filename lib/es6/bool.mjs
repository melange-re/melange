

import * as Caml_primitive from "./caml_primitive.mjs";

function equal(prim, prim$1) {
  return prim === prim$1;
}

var compare = Caml_primitive.caml_int_compare;

function to_float(param) {
  if (param) {
    return 1;
  } else {
    return 0;
  }
}

function to_string(param) {
  if (param) {
    return "true";
  } else {
    return "false";
  }
}

function not(prim) {
  return !prim;
}

function to_int(prim) {
  return prim;
}

export {
  not ,
  equal ,
  compare ,
  to_int ,
  to_float ,
  to_string ,
  
}
/* No side effect */
