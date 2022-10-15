'use strict';

var Gpr_3865_bar = require("./gpr_3865_bar.js");
var Gpr_3865_foo = require("./gpr_3865_foo.js");

var B = Gpr_3865_bar.Make(Gpr_3865_foo);

console.log(Gpr_3865_foo.$$return);

console.log(B.$$return);

exports.B = B;
/* B Not a pure module */
