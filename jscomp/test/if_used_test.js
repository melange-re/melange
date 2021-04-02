'use strict';

var Curry = require("../../lib/js/curry.js");
var CamlinternalOO = require("../../lib/js/camlinternalOO.js");

function point_init($$class) {
  var x_init = CamlinternalOO.new_variable($$class, "");
  var ids = CamlinternalOO.new_methods_variables($$class, [
        "move",
        "get_x",
        "*dummy method*"
      ], ["x"]);
  var move = ids[0];
  var get_x = ids[1];
  var x = ids[3];
  CamlinternalOO.set_methods($$class, [
        get_x,
        (function (self$neg1) {
            return self$neg1[x];
          }),
        move,
        (function (self$neg1, d) {
            self$neg1[x] = self$neg1[x] + d | 0;
            
          })
      ]);
  return function (env, self, x_init$1) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[x_init] = x_init$1;
    self$1[x] = x_init$1;
    return self$1;
  };
}

var point = CamlinternalOO.make_class([
      "move",
      "get_x"
    ], point_init);

var p = Curry._2(point[0], undefined, 7);

exports.point = point;
exports.p = p;
/* point Not a pure module */
