// Generated by Melange
'use strict';

const Curry = require("melange.js/curry.js");

function g(x) {
  return Curry._1(x, x);
}

const loop = g(g);

exports.g = g;
exports.loop = loop;
/* loop Not a pure module */
