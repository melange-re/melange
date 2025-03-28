// Generated by Melange
'use strict';

const Curry = require("melange.js/curry.js");

const v = {
  contents: 0
};

function reset(param) {
  v.contents = 0;
}

function incr(param) {
  v.contents = v.contents + 1 | 0;
}

const vv = {
  contents: 0
};

function reset2(param) {
  vv.contents = 0;
}

function incr2(param) {
  v.contents = v.contents + 1 | 0;
}

function f(a, b, d, e) {
  const h = Curry._1(a, b);
  const u = Curry._1(d, h);
  const v = Curry._1(e, h);
  return u + v | 0;
}

function kf(cb, v) {
  Curry._1(cb, v);
  return v + v | 0;
}

function ikf(v) {
  return kf((function (prim) {
    
  }), v);
}

module.exports = {
  v,
  reset,
  incr,
  reset2,
  incr2,
  f,
  kf,
  ikf,
}
/* No side effect */
