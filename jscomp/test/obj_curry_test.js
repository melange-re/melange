'use strict';

var Caml_oo_curry = require("../../lib/js/caml_oo_curry.js");
var CamlinternalOO = require("../../lib/js/camlinternalOO.js");

function f(o) {
  return Caml_oo_curry.js4(23297, 1, o, 1, 2, 3);
}

var $$class = CamlinternalOO.create_table(["hi"]);

var hi = CamlinternalOO.get_method_label($$class, "hi");

var a = f((CamlinternalOO.set_method($$class, hi, (function (self$1, x, y, z) {
              return (x + y | 0) + z | 0;
            })), CamlinternalOO.init_class($$class), CamlinternalOO.create_object_opt(undefined, $$class)));

exports.f = f;
exports.a = a;
/* a Not a pure module */
