// Generated by Melange
'use strict';

const Caml_exceptions = require("melange.js/caml_exceptions.js");
const Caml_js_exceptions = require("melange.js/caml_js_exceptions.js");
const Stdlib = require("melange/stdlib.js");
const Test_common = require("./test_common.js");

const Local = /* @__PURE__ */ Caml_exceptions.create("Test_exception.Local");

function f(param) {
  throw new Caml_js_exceptions.MelangeError(Local, {
      MEL_EXN_ID: Local,
      _1: 3
    });
}

function g(param) {
  throw new Caml_js_exceptions.MelangeError(Stdlib.Not_found, {
      MEL_EXN_ID: Stdlib.Not_found
    });
}

function h(param) {
  throw new Caml_js_exceptions.MelangeError(Test_common.U, {
      MEL_EXN_ID: Test_common.U,
      _1: 3
    });
}

function x(param) {
  throw new Caml_js_exceptions.MelangeError(Test_common.H, {
      MEL_EXN_ID: Test_common.H
    });
}

function xx(param) {
  throw new Caml_js_exceptions.MelangeError(Stdlib.Invalid_argument, {
      MEL_EXN_ID: Stdlib.Invalid_argument,
      _1: "x"
    });
}

const Nullary = /* @__PURE__ */ Caml_exceptions.create("Test_exception.Nullary");

const a = new Caml_js_exceptions.MelangeError(Nullary, {
    MEL_EXN_ID: Nullary
  });

module.exports = {
  Local,
  f,
  g,
  h,
  x,
  xx,
  Nullary,
  a,
}
/* No side effect */
