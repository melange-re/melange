'use strict';

var Mt = require("./mt.js");
var $$Array = require("melange/lib/js/array.js");
var Curry = require("melange/lib/js/curry.js");
var Queue = require("melange/lib/js/queue.js");
var Caml_array = require("melange/lib/js/caml_array.js");

function Test(Queue) {
  var to_array = function (q) {
    var v = Caml_array.make(Curry._1(Queue.length, q), 0);
    Curry._3(Queue.fold, (function (i, e) {
            Caml_array.set(v, i, e);
            return i + 1 | 0;
          }), 0, q);
    return v;
  };
  var queue_1 = function (x) {
    var q = Curry._1(Queue.create, undefined);
    $$Array.iter((function (x) {
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
  var v = Caml_array.make(Queue.length(q), 0);
  Queue.fold((function (i, e) {
          Caml_array.set(v, i, e);
          return i + 1 | 0;
        }), 0, q);
  return v;
}

function queue_1(x) {
  var q = Queue.create(undefined);
  $$Array.iter((function (x) {
          Queue.add(x, q);
        }), x);
  return to_array(q);
}

var T1 = {
  to_array: to_array,
  queue_1: queue_1
};

var suites_0 = [
  "File \"queue_test.ml\", line 25, characters 2-9",
  (function (param) {
      var x = [
        3,
        4,
        5,
        2
      ];
      return {
              TAG: /* Eq */0,
              _0: x,
              _1: queue_1(x)
            };
    })
];

var suites = {
  hd: suites_0,
  tl: /* [] */0
};

Mt.from_pair_suites("Queue_test", suites);

exports.Test = Test;
exports.T1 = T1;
exports.suites = suites;
/*  Not a pure module */
