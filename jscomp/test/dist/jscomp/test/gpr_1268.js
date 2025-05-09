// Generated by Melange
'use strict';

const Curry = require("melange.js/curry.js");

function f_add2(a, b, x, y) {
  return add(Curry._1(b, y), Curry._1(a, x));
}

function f(a, b, x, y) {
  return Curry._1(a, x) + Curry._1(b, y) | 0;
}

function f1(a, b, x, y) {
  return add(Curry._1(a, x), Curry._1(b, y));
}

function f2(x) {
  console.log(x);
}

function f3(x) {
  console.log(x);
}

function f4(x, y) {
  return add(y, x);
}

module.exports = {
  f_add2,
  f,
  f1,
  f2,
  f3,
  f4,
}
/* No side effect */
