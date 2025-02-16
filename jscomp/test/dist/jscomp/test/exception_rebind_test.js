// Generated by Melange
'use strict';

const Caml_exceptions = require("melange.js/caml_exceptions.js");
const Exception_def = require("./exception_def.js");
const Stdlib = require("melange/stdlib.js");

const E = /* @__PURE__ */ Caml_exceptions.create("Exception_rebind_test.A.E");

const A = {
  E: E
};

const B = {
  F: E
};

const A0 = /* @__PURE__ */ Caml_exceptions.create("Exception_rebind_test.A0");

const u0 = {
  MEL_EXN_ID: Stdlib.Invalid_argument,
  _1: "x"
};

const u1 = {
  MEL_EXN_ID: Stdlib.Invalid_argument,
  _1: "x"
};

const u2 = {
  MEL_EXN_ID: Stdlib.Not_found
};

const H = Exception_def.A;

const H0 = Stdlib.Invalid_argument;

const H1 = Stdlib.Invalid_argument;

module.exports = {
  A,
  B,
  H,
  A0,
  H0,
  H1,
  u0,
  u1,
  u2,
}
/* Exception_def Not a pure module */
