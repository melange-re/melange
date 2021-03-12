'use strict';

var Seq = require("./seq.js");
var List = require("./list.js");
var Caml_obj = require("./caml_obj.js");
var Caml_option = require("./caml_option.js");
var Caml_exceptions = require("./caml_exceptions.js");

var Empty = /* @__PURE__ */Caml_exceptions.create("Stack.Empty");

function create(param) {
  return {
          c: /* [] */0,
          len: 0
        };
}

function clear(s) {
  s.c = /* [] */0;
  s.len = 0;
  
}

function copy(s) {
  return {
          c: s.c,
          len: s.len
        };
}

function push(x, s) {
  s.c = {
    hd: x,
    tl: s.c
  };
  s.len = s.len + 1 | 0;
  
}

function pop(s) {
  var match = s.c;
  if (match) {
    s.c = match.tl;
    s.len = s.len - 1 | 0;
    return match.hd;
  }
  throw {
        RE_EXN_ID: Empty,
        Error: new Error()
      };
}

function pop_opt(s) {
  var match = s.c;
  if (match) {
    s.c = match.tl;
    s.len = s.len - 1 | 0;
    return Caml_option.some(match.hd);
  }
  
}

function top(s) {
  var match = s.c;
  if (match) {
    return match.hd;
  }
  throw {
        RE_EXN_ID: Empty,
        Error: new Error()
      };
}

function top_opt(s) {
  var match = s.c;
  if (match) {
    return Caml_option.some(match.hd);
  }
  
}

function is_empty(s) {
  return Caml_obj.caml_equal(s.c, /* [] */0);
}

function length(s) {
  return s.len;
}

function iter(f, s) {
  return List.iter(f, s.c);
}

function fold(f, acc, s) {
  return List.fold_left(f, acc, s.c);
}

function to_seq(s) {
  return List.to_seq(s.c);
}

function add_seq(q, i) {
  return Seq.iter((function (x) {
                return push(x, q);
              }), i);
}

function of_seq(g) {
  var s = {
    c: /* [] */0,
    len: 0
  };
  add_seq(s, g);
  return s;
}

exports.Empty = Empty;
exports.create = create;
exports.push = push;
exports.pop = pop;
exports.pop_opt = pop_opt;
exports.top = top;
exports.top_opt = top_opt;
exports.clear = clear;
exports.copy = copy;
exports.is_empty = is_empty;
exports.length = length;
exports.iter = iter;
exports.fold = fold;
exports.to_seq = to_seq;
exports.add_seq = add_seq;
exports.of_seq = of_seq;
/* No side effect */
