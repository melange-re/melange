'use strict';

var Char = require("../../lib/js/char.js");
var List = require("../../lib/js/list.js");
var Curry = require("../../lib/js/curry.js");

function l(prim) {
  console.log(prim);
}

var C$p = Char;

var prim = Char.chr(66);

console.log(prim);

var prim$1 = Char.chr(66);

console.log(prim$1);

var C3 = Char;

var prim$2 = Char.chr(66);

console.log(prim$2);

var f = List.length;

function g(x) {
  return List.length(List.map((function (prim) {
                    return prim + 1 | 0;
                  }), x));
}

function F(X) {
  return Char;
}

var C4 = Char;

var prim$3 = Char.chr(66);

console.log(prim$3);

function G(X) {
  return X;
}

var M = {};

var N = {
  x: 1
};

var N$p;

var M$p = {
  N: N,
  N$p: N$p
};

console.log(1);

var M$p$p = {
  N$p: N
};

console.log(M$p$p.N$p.x);

var M2 = {
  N: N,
  N$p: N$p
};

var M3 = {
  N$p: N
};

console.log(1);

var M3$p = {
  N$p: N
};

console.log(M3$p.N$p.x);

var N$1 = {
  x: 1
};

var M4 = {
  N$p: N$1
};

console.log(1);

function F0(X) {
  var N = {
    x: 1
  };
  return {
          N: N,
          N$p: undefined
        };
}

var N$2 = {
  x: 1
};

var M5 = {
  N$p: N$2
};

console.log(M5.N$p.x);

var D = {
  y: 3
};

var N$3 = {
  x: 1
};

var N$p$1;

var M6 = {
  D: D,
  N: N$3,
  N$p: N$p$1
};

console.log(1);

var M7 = {
  N$p: N$3
};

console.log(M7.N$p.x);

console.log(1);

var C$p$1;

var M8 = {
  C: undefined,
  C$p: C$p$1
};

var M9 = {
  C: Char,
  C$p: C$p$1
};

var prim$4 = Curry._1(Char.chr, 66);

console.log(prim$4);

var M10 = {
  C$p: Char
};

var prim$5 = Curry._1(M10.C$p.chr, 66);

console.log(prim$5);

var C;

var C$p$p$p = C$p;

var C$p$p = Char;

function G0(funarg) {
  var N = {
    x: 1
  };
  return {
          N$p: N
        };
}

var M1 = {
  N: N$3,
  N$p: N$p$1
};

exports.l = l;
exports.C = C;
exports.C$p = C$p;
exports.C$p$p$p = C$p$p$p;
exports.C$p$p = C$p$p;
exports.C3 = C3;
exports.f = f;
exports.g = g;
exports.F = F;
exports.C4 = C4;
exports.G = G;
exports.M = M;
exports.M$p = M$p;
exports.M$p$p = M$p$p;
exports.M2 = M2;
exports.M3 = M3;
exports.M3$p = M3$p;
exports.M4 = M4;
exports.F0 = F0;
exports.G0 = G0;
exports.M5 = M5;
exports.M6 = M6;
exports.M1 = M1;
exports.M7 = M7;
exports.M8 = M8;
exports.M9 = M9;
exports.M10 = M10;
/* prim Not a pure module */
