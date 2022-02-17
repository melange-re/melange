'use strict';

var Mt = require("./mt.js");
var Caml_int32 = require("../../lib/js/caml_int32.js");
var Caml_int64 = require("../../lib/js/caml_int64.js");

var suites = {
  contents: /* [] */0
};

var test_id = {
  contents: 0
};

function eq(loc, x, y) {
  test_id.contents = test_id.contents + 1 | 0;
  suites.contents = {
    hd: [
      loc + (" id " + String(test_id.contents)),
      (function (param) {
          return {
                  TAG: /* Eq */0,
                  _0: x,
                  _1: y
                };
        })
    ],
    tl: suites.contents
  };
}

var a0;

try {
  Caml_int32.div(0, 0);
  a0 = 0;
}
catch (exn){
  a0 = 1;
}

var a1;

try {
  Caml_int32.mod_(0, 0);
  a1 = 0;
}
catch (exn$1){
  a1 = 1;
}

var a4;

try {
  Caml_int32.div(0, 0);
  a4 = 0;
}
catch (exn$2){
  a4 = 1;
}

var a5;

try {
  Caml_int32.mod_(0, 0);
  a5 = 0;
}
catch (exn$3){
  a5 = 1;
}

var a6;

try {
  Caml_int64.div(Caml_int64.zero, Caml_int64.zero);
  a6 = 0;
}
catch (exn$4){
  a6 = 1;
}

var a7;

try {
  Caml_int64.mod_(Caml_int64.zero, Caml_int64.zero);
  a7 = 0;
}
catch (exn$5){
  a7 = 1;
}

eq("File \"gpr_1760_test.ml\", line 30, characters 5-12", [
      a0,
      a1,
      a4,
      a5,
      a6,
      a7
    ], [
      1,
      1,
      1,
      1,
      1,
      1
    ]);

Mt.from_pair_suites("Gpr_1760_test", suites.contents);

exports.suites = suites;
exports.test_id = test_id;
exports.eq = eq;
exports.a0 = a0;
exports.a1 = a1;
exports.a4 = a4;
exports.a5 = a5;
exports.a6 = a6;
exports.a7 = a7;
/* a0 Not a pure module */
