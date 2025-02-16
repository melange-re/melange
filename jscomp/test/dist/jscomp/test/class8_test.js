// Generated by Melange
'use strict';

const Caml_obj = require("melange.js/caml_obj.js");
const Caml_oo = require("melange.js/caml_oo.js");
const Caml_oo_curry = require("melange.js/caml_oo_curry.js");
const CamlinternalOO = require("melange/camlinternalOO.js");
const Curry = require("melange.js/curry.js");
const Mt = require("./mt.js");

const shared = ["repr"];

const shared$1 = [
  "leq",
  "value"
];

const suites = {
  contents: /* [] */ 0
};

const test_id = {
  contents: 0
};

function eq(loc, x, y) {
  Mt.eq_suites(test_id, suites, loc, x, y);
}

function comparable_1($$class) {
  CamlinternalOO.get_method_label($$class, "leq");
  return function (env, self) {
    return CamlinternalOO.create_object_opt(self, $$class);
  };
}

const comparable = [
  undefined,
  comparable_1,
  undefined
];

function money_init($$class) {
  const ids = CamlinternalOO.new_methods_variables($$class, [
    "value",
    "leq"
  ], shared);
  const value = ids[0];
  const leq = ids[1];
  const repr = ids[2];
  const inh = CamlinternalOO.inherits($$class, 0, ["leq"], 0, comparable, true);
  const obj_init = inh[0];
  CamlinternalOO.set_methods($$class, [
    value,
    (function (self$2) {
      return self$2[repr];
    }),
    leq,
    (function (self$2, p) {
      return self$2[repr] <= Caml_oo_curry.js1(834174833, 1, p);
    })
  ]);
  return function (env, self, x) {
    const self$1 = CamlinternalOO.create_object_opt(self, $$class);
    Curry._1(obj_init, self$1);
    self$1[repr] = x;
    return CamlinternalOO.run_initializers_opt(self, self$1, $$class);
  };
}

const money = CamlinternalOO.make_class(shared$1, money_init);

function money2_init($$class) {
  const ids = CamlinternalOO.get_method_labels($$class, [
    "value",
    "times",
    "leq"
  ]);
  const times = ids[1];
  const inh = CamlinternalOO.inherits($$class, shared, 0, shared$1, money, true);
  const obj_init = inh[0];
  const repr = inh[1];
  CamlinternalOO.set_method($$class, times, (function (self$3, k) {
    const copy = Caml_oo.caml_set_oo_id(Caml_obj.caml_obj_dup(self$3));
    copy[repr] = k * self$3[repr];
    return copy;
  }));
  return function (env, self, x) {
    const self$1 = CamlinternalOO.create_object_opt(self, $$class);
    Curry._2(obj_init, self$1, x);
    return CamlinternalOO.run_initializers_opt(self, self$1, $$class);
  };
}

const money2 = CamlinternalOO.make_class([
  "leq",
  "times",
  "value"
], money2_init);

function min(x, y) {
  if (Caml_oo_curry.js2(5393368, 2, x, y)) {
    return x;
  } else {
    return y;
  }
}

const tmp = min(Curry._2(money[0], undefined, 1.0), Curry._2(money[0], undefined, 3.0));

eq("File \"jscomp/test/class8_test.ml\", line 30, characters 5-12", 1, Caml_oo_curry.js1(834174833, 3, tmp));

const tmp$1 = min(Curry._2(money2[0], undefined, 5.0), Curry._2(money2[0], undefined, 3));

eq("File \"jscomp/test/class8_test.ml\", line 35, characters 5-12", 3, Caml_oo_curry.js1(834174833, 4, tmp$1));

Mt.from_pair_suites("Class8_test", suites.contents);

module.exports = {
  suites,
  test_id,
  eq,
  comparable,
  money,
  money2,
  min,
}
/* money Not a pure module */
