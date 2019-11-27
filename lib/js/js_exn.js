'use strict';

var Caml_exceptions = require("./caml_exceptions.js");
var Caml_js_exceptions = require("./caml_js_exceptions.js");

function raiseError(str) {
  throw Caml_exceptions.stacktrace(new Error(str));
}

function raiseEvalError(str) {
  throw Caml_exceptions.stacktrace(new EvalError(str));
}

function raiseRangeError(str) {
  throw Caml_exceptions.stacktrace(new RangeError(str));
}

function raiseReferenceError(str) {
  throw Caml_exceptions.stacktrace(new ReferenceError(str));
}

function raiseSyntaxError(str) {
  throw Caml_exceptions.stacktrace(new SyntaxError(str));
}

function raiseTypeError(str) {
  throw Caml_exceptions.stacktrace(new TypeError(str));
}

function raiseUriError(str) {
  throw Caml_exceptions.stacktrace(new URIError(str));
}

var $$Error$1 = Caml_js_exceptions.$$Error;

exports.$$Error = $$Error$1;
exports.raiseError = raiseError;
exports.raiseEvalError = raiseEvalError;
exports.raiseRangeError = raiseRangeError;
exports.raiseReferenceError = raiseReferenceError;
exports.raiseSyntaxError = raiseSyntaxError;
exports.raiseTypeError = raiseTypeError;
exports.raiseUriError = raiseUriError;
/* No side effect */
