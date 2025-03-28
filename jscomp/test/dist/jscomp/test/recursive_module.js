// Generated by Melange
'use strict';

const Caml_external_polyfill = require("melange.js/caml_external_polyfill.js");
const Caml_js_exceptions = require("melange.js/caml_js_exceptions.js");
const Caml_module = require("melange.js/caml_module.js");
const CamlinternalLazy = require("melange/camlinternalLazy.js");
const Curry = require("melange.js/curry.js");
const Mt = require("./mt.js");
const Stdlib = require("melange/stdlib.js");
const Stdlib__Lazy = require("melange/lazy.js");

const suites = {
  contents: /* [] */ 0
};

const test_id = {
  contents: 0
};

function eq(loc, x, y) {
  Mt.eq_suites(test_id, suites, loc, x, y);
}

const Xx = {
  f: (function (prim0, prim1) {
    return Caml_external_polyfill.resolve("caml_hfiehi")(prim0, prim1);
  })
};

const Int3 = Caml_module.init_mod([
  "jscomp/test/recursive_module.ml",
  27,
  6
], {
  TAG: /* Module */ 0,
  _0: [[
      /* Function */ 0,
      "u"
    ]]
});

Caml_module.update_mod({
  TAG: /* Module */ 0,
  _0: [[
      /* Function */ 0,
      "u"
    ]]
}, Int3, Int3);

const Inta = Caml_module.init_mod([
  "jscomp/test/recursive_module.ml",
  31,
  6
], {
  TAG: /* Module */ 0,
  _0: [[
      /* Lazy */ 1,
      "a"
    ]]
});

const Intb = Caml_module.init_mod([
  "jscomp/test/recursive_module.ml",
  36,
  6
], {
  TAG: /* Module */ 0,
  _0: [[
      /* Lazy */ 1,
      "a"
    ]]
});

const a = {
  LAZY_DONE: false,
  VAL: (function () {
    return CamlinternalLazy.force(Intb.a);
  })
};

Caml_module.update_mod({
  TAG: /* Module */ 0,
  _0: [[
      /* Lazy */ 1,
      "a"
    ]]
}, Inta, {
  a: a
});

const a$1 = {
  LAZY_DONE: false,
  VAL: (function () {
    return CamlinternalLazy.force(Inta.a) + 1 | 0;
  })
};

Caml_module.update_mod({
  TAG: /* Module */ 0,
  _0: [[
      /* Lazy */ 1,
      "a"
    ]]
}, Intb, {
  a: a$1
});

let tmp;

try {
  tmp = CamlinternalLazy.force(Intb.a);
}
catch (raw_exn){
  const exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
  if (exn.MEL_EXN_ID === Stdlib__Lazy.Undefined) {
    tmp = -1;
  } else {
    throw exn;
  }
}

eq("File \"jscomp/test/recursive_module.ml\", line 41, characters 3-10", -1, tmp);

const Inta$1 = Caml_module.init_mod([
  "jscomp/test/recursive_module.ml",
  48,
  8
], {
  TAG: /* Module */ 0,
  _0: [[
      /* Lazy */ 1,
      "a"
    ]]
});

const Intb$1 = Caml_module.init_mod([
  "jscomp/test/recursive_module.ml",
  53,
  8
], {
  TAG: /* Module */ 0,
  _0: [[
      /* Lazy */ 1,
      "a"
    ]]
});

const a$2 = {
  LAZY_DONE: false,
  VAL: (function () {
    return CamlinternalLazy.force(Intb$1.a) + 1 | 0;
  })
};

Caml_module.update_mod({
  TAG: /* Module */ 0,
  _0: [[
      /* Lazy */ 1,
      "a"
    ]]
}, Inta$1, {
  a: a$2
});

const a$3 = {
  LAZY_DONE: true,
  VAL: 2
};

Caml_module.update_mod({
  TAG: /* Module */ 0,
  _0: [[
      /* Lazy */ 1,
      "a"
    ]]
}, Intb$1, {
  a: a$3
});

const A = {
  Inta: Inta$1,
  Intb: Intb$1
};

eq("File \"jscomp/test/recursive_module.ml\", line 58, characters 6-13", CamlinternalLazy.force(Inta$1.a), 3);

let tmp$1;

try {
  Curry._1(Int3.u, 3);
  tmp$1 = 3;
}
catch (raw_exn$1){
  const exn$1 = Caml_js_exceptions.internalToOCamlException(raw_exn$1);
  if (exn$1.MEL_EXN_ID === Stdlib.Undefined_recursive_module) {
    tmp$1 = 4;
  } else {
    throw exn$1;
  }
}

eq("File \"jscomp/test/recursive_module.ml\", line 60, characters 6-13", 4, tmp$1);

Mt.from_pair_suites("Recursive_module", suites.contents);

let Int32;

const uuu = Xx.f;

module.exports = {
  suites,
  test_id,
  eq,
  Int32,
  Xx,
  uuu,
  Int3,
  Inta,
  Intb,
  A,
}
/* Int3 Not a pure module */
