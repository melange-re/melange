'use strict';

var Sys = require("../../lib/js/sys.js");
var Curry = require("../../lib/js/curry.js");
var Caml_oo = require("../../lib/js/caml_oo.js");
var Caml_obj = require("../../lib/js/caml_obj.js");
var Caml_oo_curry = require("../../lib/js/caml_oo_curry.js");
var CamlinternalOO = require("../../lib/js/camlinternalOO.js");

var shared = [
  "incr",
  "get_money"
];

var shared$1 = [
  "incr",
  "get_money",
  "*dummy method*"
];

var shared$2 = ["x"];

function x0_init($$class) {
  var v = CamlinternalOO.new_variable($$class, "");
  var ids = CamlinternalOO.new_methods_variables($$class, ["*dummy method*"], shared$2);
  var x = ids[1];
  return function (env, self, v$1) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[v] = v$1;
    self$1[x] = v$1 + 2 | 0;
    return self$1;
  };
}

var x0 = CamlinternalOO.make_class(0, x0_init);

function x_init($$class) {
  var v = CamlinternalOO.new_variable($$class, "");
  var ids = CamlinternalOO.new_methods_variables($$class, [
        "get_x",
        "*dummy method*"
      ], shared$2);
  var get_x = ids[0];
  var x = ids[2];
  CamlinternalOO.set_method($$class, get_x, (function (self$2) {
          return self$2[x];
        }));
  return function (env, self, v$1) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[v] = v$1;
    self$1[x] = v$1;
    return self$1;
  };
}

var x = CamlinternalOO.make_class(["get_x"], x_init);

var v = Curry._2(x[0], undefined, 3);

var u = Caml_oo.caml_set_oo_id(Caml_obj.caml_obj_dup(v));

if (Caml_oo_curry.js1(291546447, 1, v) !== 3) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "class_repr.ml",
          30,
          9
        ],
        Error: new Error()
      };
}

if (Caml_oo_curry.js1(291546447, 2, u) !== 3) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "class_repr.ml",
          32,
          9
        ],
        Error: new Error()
      };
}

function xx_init($$class) {
  var x = CamlinternalOO.new_variable($$class, "");
  var ids = CamlinternalOO.new_methods_variables($$class, shared$1, ["money"]);
  var incr = ids[0];
  var get_money = ids[1];
  var money = ids[3];
  CamlinternalOO.set_methods($$class, [
        get_money,
        (function (self$3) {
            return self$3[money];
          }),
        incr,
        (function (self$3) {
            var copy = Caml_oo.caml_set_oo_id(Caml_obj.caml_obj_dup(self$3));
            copy[money] = 2 * self$3[x] + Curry._1(self$3[0][get_money], self$3);
            return copy;
          })
      ]);
  return function (env, self, x$1) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[x] = x$1;
    self$1[money] = x$1;
    return self$1;
  };
}

var xx = CamlinternalOO.make_class(shared, xx_init);

var v1 = Curry._2(xx[0], undefined, 3);

var v2 = Caml_oo_curry.js1(-977586732, 3, v1);

if (Caml_oo_curry.js1(-804710761, 4, v1) !== 3) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "class_repr.ml",
          44,
          9
        ],
        Error: new Error()
      };
}

if (typeof Sys.backend_type !== "number" && Sys.backend_type._0 === "BS") {
  console.log([
        Caml_oo_curry.js1(-804710761, 7, v1),
        Caml_oo_curry.js1(-804710761, 8, v2)
      ]);
}

if (Caml_oo_curry.js1(-804710761, 9, v2) !== 9) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "class_repr.ml",
          59,
          9
        ],
        Error: new Error()
      };
}

function point_init($$class) {
  var ids = CamlinternalOO.new_methods_variables($$class, [
        "get_x5",
        "get_x",
        "*dummy method*"
      ], shared$2);
  var get_x5 = ids[0];
  var get_x = ids[1];
  var x = ids[3];
  CamlinternalOO.set_methods($$class, [
        get_x,
        (function (self$4) {
            return self$4[x];
          }),
        get_x5,
        (function (self$4) {
            return Curry._1(self$4[0][get_x], self$4) + 5 | 0;
          })
      ]);
  return function (env, self) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[x] = 0;
    return self$1;
  };
}

var point = CamlinternalOO.make_class([
      "get_x",
      "get_x5"
    ], point_init);

var v$1 = Curry._1(point[0], undefined);

if (Caml_oo_curry.js1(590348294, 10, v$1) !== 5) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "class_repr.ml",
          106,
          2
        ],
        Error: new Error()
      };
}

function xx0_init($$class) {
  var x = CamlinternalOO.new_variable($$class, "");
  var ids = CamlinternalOO.new_methods_variables($$class, shared$1, [
        "money",
        "a0",
        "a1",
        "a2"
      ]);
  var incr = ids[0];
  var get_money = ids[1];
  var money = ids[3];
  var a0 = ids[4];
  var a1 = ids[5];
  var a2 = ids[6];
  CamlinternalOO.set_methods($$class, [
        get_money,
        (function (self$5) {
            return self$5[money];
          }),
        incr,
        (function (self$5) {
            var copy = Caml_oo.caml_set_oo_id(Caml_obj.caml_obj_dup(self$5));
            copy[money] = 2 * self$5[x] + Curry._1(self$5[0][get_money], self$5);
            copy[a0] = 2;
            return copy;
          })
      ]);
  return function (env, self, x$1) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[x] = x$1;
    self$1[money] = x$1;
    self$1[a0] = 0;
    self$1[a1] = 1;
    self$1[a2] = 2;
    return self$1;
  };
}

var xx0 = CamlinternalOO.make_class(shared, xx0_init);

exports.x0 = x0;
exports.x = x;
exports.u = u;
exports.xx = xx;
exports.v1 = v1;
exports.v2 = v2;
exports.point = point;
exports.v = v$1;
exports.xx0 = xx0;
/* x0 Not a pure module */
