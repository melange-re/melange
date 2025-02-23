// Generated by Melange
'use strict';

const Caml_array = require("melange.js/caml_array.js");
const Curry = require("melange.js/curry.js");
const Mt = require("./mt.js");
const Stdlib__Array = require("melange/array.js");
const Stdlib__Queue = require("melange/queue.js");

function Test(Queue) {
  const to_array = function (q) {
    const v = Caml_array.make(Curry._1(Queue.length, q), 0);
    Curry._3(Queue.fold, (function (i, e) {
      Caml_array.set(v, i, e);
      return i + 1 | 0;
    }), 0, q);
    return v;
  };
  const queue_1 = function (x) {
    const q = Curry._1(Queue.create, undefined);
    Stdlib__Array.iter((function (x) {
      Curry._2(Queue.add, x, q);
    }), x);
    return to_array(q);
  };
  return {
    to_array: to_array,
    queue_1: queue_1
  };
}

function to_array(q) {
  const v = Caml_array.make(q.length, 0);
  Stdlib__Queue.fold((function (i, e) {
    Caml_array.set(v, i, e);
    return i + 1 | 0;
  }), 0, q);
  return v;
}

function queue_1(x) {
  const q = {
    length: 0,
    first: /* Nil */ 0,
    last: /* Nil */ 0
  };
  Stdlib__Array.iter((function (x) {
    Stdlib__Queue.add(x, q);
  }), x);
  return to_array(q);
}

const T1 = {
  to_array: to_array,
  queue_1: queue_1
};

const suites_0 = [
  "File \"jscomp/test/queue_test.ml\", line 25, characters 2-9",
  (function (param) {
    const x = [
      3,
      4,
      5,
      2
    ];
    return {
      TAG: /* Eq */ 0,
      _0: x,
      _1: queue_1(x)
    };
  })
];

const suites = {
  hd: suites_0,
  tl: /* [] */ 0
};

Mt.from_pair_suites("Queue_test", suites);

module.exports = {
  Test,
  T1,
  suites,
}
/*  Not a pure module */
