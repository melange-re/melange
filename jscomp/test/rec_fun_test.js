'use strict';

var Mt = require("./mt.js");
var Curry = require("../../lib/js/curry.js");
var Caml_obj = require("../../lib/js/caml_obj.js");

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

var called = {
  contents: 0
};

function g(param) {
  var v = {};
  var next = function (i, b) {
    called.contents = called.contents + 1 | 0;
    if (b) {
      Curry._2(v.contents, i, false);
    }
    return i + 1 | 0;
  };
  Caml_obj.update_dummy(v, {
        contents: next
      });
  console.log(String(next(0, true)));
}

g(undefined);

var x = {};

var y = {};

Caml_obj.update_dummy(x, {
      hd: 1,
      tl: y
    });

Caml_obj.update_dummy(y, {
      hd: 2,
      tl: x
    });

eq("File \"rec_fun_test.ml\", line 27, characters 6-13", called.contents, 2);

Mt.from_pair_suites("Rec_fun_test", suites.contents);

exports.suites = suites;
exports.test_id = test_id;
exports.eq = eq;
exports.called = called;
exports.g = g;
exports.x = x;
exports.y = y;
/*  Not a pure module */
