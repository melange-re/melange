'use strict';

var Curry = require("melange/lib/js/curry.js");
var Belt_Array = require("melange/lib/js/belt_Array.js");

var N = {};

function forEach(xs, f) {
  Belt_Array.forEach(xs, (function (x) {
          Curry._1(f.i, x);
        }));
}

var Y = {
  forEach: forEach
};

function f(X) {
  return function (xs) {
    X.forEach(xs, {
          i: (function (x) {
              console.log(x.x);
            })
        });
  };
}

function g(X) {
  return function (xs) {
    Belt_Array.forEach(xs, (function (x) {
            console.log(x);
          }));
  };
}

var g_result = g(Y)([]);

exports.N = N;
exports.Y = Y;
exports.f = f;
exports.g = g;
exports.g_result = g_result;
/* g_result Not a pure module */
