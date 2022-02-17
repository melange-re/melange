'use strict';

var Mt = require("./mt.js");
var Curry = require("../../lib/js/curry.js");
var Caml_oo = require("../../lib/js/caml_oo.js");
var Caml_obj = require("../../lib/js/caml_obj.js");
var Caml_oo_curry = require("../../lib/js/caml_oo_curry.js");
var CamlinternalOO = require("../../lib/js/camlinternalOO.js");

var shared = ["repr"];

var shared$1 = [
  "leq",
  "value"
];

var suites = {
  contents: /* [] */0
};

var test_id = {
  contents: 0
};

function eq(loc, x, y) {
  return Mt.eq_suites(test_id, suites, loc, x, y);
}

function comparable_1($$class) {
  CamlinternalOO.get_method_labels($$class, [
        "leq",
        "*dummy method*"
      ]);
  return function (env, self) {
    return CamlinternalOO.create_object_opt(self, $$class);
  };
}

var comparable = [
  undefined,
  comparable_1,
  undefined,
  undefined
];

function money_init($$class) {
  var x = CamlinternalOO.new_variable($$class, "");
  var ids = CamlinternalOO.new_methods_variables($$class, [
        "value",
        "leq",
        "*dummy method*"
      ], shared);
  var value = ids[0];
  var leq = ids[1];
  var repr = ids[3];
  var inh = CamlinternalOO.inherits($$class, 0, ["leq"], 0, comparable, true);
  var obj_init = inh[0];
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
  return function (env, self, x$1) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[x] = x$1;
    Curry._1(obj_init, self$1);
    self$1[repr] = x$1;
    return CamlinternalOO.run_initializers_opt(self, self$1, $$class);
  };
}

var money = CamlinternalOO.make_class(shared$1, money_init);

function money2_init($$class) {
  var x = CamlinternalOO.new_variable($$class, "");
  var ids = CamlinternalOO.get_method_labels($$class, [
        "value",
        "times",
        "leq",
        "*dummy method*"
      ]);
  var times = ids[1];
  var inh = CamlinternalOO.inherits($$class, shared, 0, shared$1, money, true);
  var obj_init = inh[0];
  var repr = inh[1];
  CamlinternalOO.set_method($$class, times, (function (self$3, k) {
          var copy = Caml_oo.caml_set_oo_id(Caml_obj.caml_obj_dup(self$3));
          copy[repr] = k * self$3[repr];
          return copy;
        }));
  return function (env, self, x$1) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[x] = x$1;
    Curry._2(obj_init, self$1, x$1);
    return CamlinternalOO.run_initializers_opt(self, self$1, $$class);
  };
}

var money2 = CamlinternalOO.make_class([
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

var tmp = min(Curry._2(money[0], undefined, 1.0), Curry._2(money[0], undefined, 3.0));

eq("File \"class8_test.ml\", line 30, characters 5-12", 1, Caml_oo_curry.js1(834174833, 3, tmp));

var tmp$1 = min(Curry._2(money2[0], undefined, 5.0), Curry._2(money2[0], undefined, 3));

eq("File \"class8_test.ml\", line 35, characters 5-12", 3, Caml_oo_curry.js1(834174833, 4, tmp$1));

Mt.from_pair_suites("Class8_test", suites.contents);

exports.suites = suites;
exports.test_id = test_id;
exports.eq = eq;
exports.comparable = comparable;
exports.money = money;
exports.money2 = money2;
exports.min = min;
/* money Not a pure module */
