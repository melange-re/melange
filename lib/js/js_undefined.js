'use strict';

var Caml_option = require("./caml_option.js");
var Caml_exceptions = require("./caml_exceptions.js");

function test(x) {
  return x === undefined;
}

function testAny(x) {
  return x === undefined;
}

function getExn(f) {
  if (f !== undefined) {
    return f;
  } else {
    throw Caml_exceptions.stacktrace(new Error("Js.Undefined.getExn"));
  }
}

function bind(x, f) {
  if (x !== undefined) {
    return f(x);
  }
  
}

function iter(x, f) {
  if (x !== undefined) {
    return f(x);
  } else {
    return /* () */0;
  }
}

function fromOption(x) {
  if (x !== undefined) {
    return Caml_option.valFromOption(x);
  }
  
}

var from_opt = fromOption;

exports.test = test;
exports.testAny = testAny;
exports.getExn = getExn;
exports.bind = bind;
exports.iter = iter;
exports.fromOption = fromOption;
exports.from_opt = from_opt;
/* No side effect */
