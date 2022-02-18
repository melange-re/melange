'use strict';

var Caml_obj = require("../../lib/js/caml_obj.js");

var u = 0;

<<<<<<< HEAD
exports.u = u;
/* No side effect */
=======
var v0 = {
  x: 3,
  z: 2
};

var newrecord = Caml_obj.obj_dup(v0);

newrecord.x = 3;

var v2 = newrecord;

var v1 = {
  x: 3,
  z: 3
};

exports.f = f;
exports.v0 = v0;
exports.v2 = v2;
exports.v1 = v1;
/*  Not a pure module */
>>>>>>> c56e7390a (add test case)
