'use strict';

var Curry = require("./curry.js");
var Caml_option = require("./caml_option.js");

function empty(param) {
  return /* Nil */0;
}

function $$return(x, param) {
  return /* Cons */{
          _0: x,
          _1: empty
        };
}

function cons(x, next, param) {
  return /* Cons */{
          _0: x,
          _1: next
        };
}

function append(seq1, seq2, param) {
  var match = Curry._1(seq1, undefined);
  if (!match) {
    return Curry._1(seq2, undefined);
  }
  var next = match._1;
  return /* Cons */{
          _0: match._0,
          _1: (function (param) {
              return append(next, seq2, param);
            })
        };
}

function map(f, seq, param) {
  var match = Curry._1(seq, undefined);
  if (!match) {
    return /* Nil */0;
  }
  var next = match._1;
  return /* Cons */{
          _0: Curry._1(f, match._0),
          _1: (function (param) {
              return map(f, next, param);
            })
        };
}

function filter_map(f, _seq, _param) {
  while(true) {
    var seq = _seq;
    var match = Curry._1(seq, undefined);
    if (!match) {
      return /* Nil */0;
    }
    var next = match._1;
    var y = Curry._1(f, match._0);
    if (y !== undefined) {
      return /* Cons */{
              _0: Caml_option.valFromOption(y),
              _1: (function(next){
              return function (param) {
                return filter_map(f, next, param);
              }
              }(next))
            };
    }
    _param = undefined;
    _seq = next;
    continue ;
  };
}

function filter(f, _seq, _param) {
  while(true) {
    var seq = _seq;
    var match = Curry._1(seq, undefined);
    if (!match) {
      return /* Nil */0;
    }
    var next = match._1;
    var x = match._0;
    if (Curry._1(f, x)) {
      return /* Cons */{
              _0: x,
              _1: (function(next){
              return function (param) {
                return filter(f, next, param);
              }
              }(next))
            };
    }
    _param = undefined;
    _seq = next;
    continue ;
  };
}

function flat_map(f, seq, param) {
  var match = Curry._1(seq, undefined);
  if (match) {
    return flat_map_app(f, Curry._1(f, match._0), match._1, undefined);
  } else {
    return /* Nil */0;
  }
}

function flat_map_app(f, seq, tail, param) {
  var match = Curry._1(seq, undefined);
  if (!match) {
    return flat_map(f, tail, undefined);
  }
  var next = match._1;
  return /* Cons */{
          _0: match._0,
          _1: (function (param) {
              return flat_map_app(f, next, tail, param);
            })
        };
}

function fold_left(f, acc, seq) {
  var _acc = acc;
  var _seq = seq;
  while(true) {
    var seq$1 = _seq;
    var acc$1 = _acc;
    var match = Curry._1(seq$1, undefined);
    if (!match) {
      return acc$1;
    }
    var acc$2 = Curry._2(f, acc$1, match._0);
    _seq = match._1;
    _acc = acc$2;
    continue ;
  };
}

function iter(f, seq) {
  var _seq = seq;
  while(true) {
    var seq$1 = _seq;
    var match = Curry._1(seq$1, undefined);
    if (!match) {
      return ;
    }
    Curry._1(f, match._0);
    _seq = match._1;
    continue ;
  };
}

function unfold(f, u, param) {
  var match = Curry._1(f, u);
  if (match === undefined) {
    return /* Nil */0;
  }
  var u$p = match[1];
  return /* Cons */{
          _0: match[0],
          _1: (function (param) {
              return unfold(f, u$p, param);
            })
        };
}

exports.empty = empty;
exports.$$return = $$return;
exports.cons = cons;
exports.append = append;
exports.map = map;
exports.filter = filter;
exports.filter_map = filter_map;
exports.flat_map = flat_map;
exports.fold_left = fold_left;
exports.iter = iter;
exports.unfold = unfold;
/* No side effect */
