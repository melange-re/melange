'use strict';

var Obj = require("./obj.js");
var Curry = require("./curry.js");
var Caml_exceptions = require("./caml_exceptions.js");
var Caml_external_polyfill = require("./caml_external_polyfill.js");

var Undefined = /* @__PURE__ */Caml_exceptions.create("CamlinternalLazy.Undefined");

function raise_undefined(param) {
  throw {
        RE_EXN_ID: Undefined,
        Error: new Error()
      };
}

function force_lazy_block(blk) {
  var closure = blk[0];
  blk[0] = raise_undefined;
  try {
    var result = Curry._1(closure, undefined);
    Caml_external_polyfill.resolve("caml_obj_make_forward")(blk, result);
    return result;
  }
  catch (e){
    blk[0] = (function (param) {
        throw e;
      });
    throw e;
  }
}

function force_val_lazy_block(blk) {
  var closure = blk[0];
  blk[0] = raise_undefined;
  var result = Curry._1(closure, undefined);
  Caml_external_polyfill.resolve("caml_obj_make_forward")(blk, result);
  return result;
}

function force(lzv) {
  var t = lzv.TAG | 0;
  if (t === Obj.forward_tag) {
    return lzv[0];
  } else if (t !== Obj.lazy_tag) {
    return lzv;
  } else {
    return force_lazy_block(lzv);
  }
}

function force_val(lzv) {
  var t = lzv.TAG | 0;
  if (t === Obj.forward_tag) {
    return lzv[0];
  } else if (t !== Obj.lazy_tag) {
    return lzv;
  } else {
    return force_val_lazy_block(lzv);
  }
}

exports.Undefined = Undefined;
exports.force_lazy_block = force_lazy_block;
exports.force_val_lazy_block = force_val_lazy_block;
exports.force = force;
exports.force_val = force_val;
/* No side effect */
