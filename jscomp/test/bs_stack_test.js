'use strict';

var Mt = require("./mt.js");
var Caml_option = require("melange/lib/js/caml_option.js");
var Js_undefined = require("melange/lib/js/js_undefined.js");
var Belt_MutableQueue = require("melange/lib/js/belt_MutableQueue.js");
var Belt_MutableStack = require("melange/lib/js/belt_MutableStack.js");

var suites = {
  contents: /* [] */0
};

var test_id = {
  contents: 0
};

function eq(loc, x, y) {
  Mt.eq_suites(test_id, suites, loc, x, y);
}

function inOrder(v) {
  var current = v;
  var s = {
    root: undefined
  };
  var q = {
    length: 0,
    first: undefined,
    last: undefined
  };
  while(current !== undefined) {
    var v$1 = current;
    Belt_MutableStack.push(s, v$1);
    current = v$1.left;
  };
  while(s.root !== undefined) {
    current = Belt_MutableStack.popUndefined(s);
    var v$2 = current;
    Belt_MutableQueue.add(q, v$2.value);
    current = v$2.right;
    while(current !== undefined) {
      var v$3 = current;
      Belt_MutableStack.push(s, v$3);
      current = v$3.left;
    };
  };
  return Belt_MutableQueue.toArray(q);
}

function inOrder3(v) {
  var current = v;
  var s = {
    root: undefined
  };
  var q = {
    length: 0,
    first: undefined,
    last: undefined
  };
  while(current !== undefined) {
    var v$1 = current;
    Belt_MutableStack.push(s, v$1);
    current = v$1.left;
  };
  Belt_MutableStack.dynamicPopIter(s, (function (popped) {
          Belt_MutableQueue.add(q, popped.value);
          var current = popped.right;
          while(current !== undefined) {
            var v = current;
            Belt_MutableStack.push(s, v);
            current = v.left;
          };
        }));
  return Belt_MutableQueue.toArray(q);
}

function inOrder2(v) {
  var todo = true;
  var cursor = v;
  var s = {
    root: undefined
  };
  var q = {
    length: 0,
    first: undefined,
    last: undefined
  };
  while(todo) {
    if (cursor !== undefined) {
      var v$1 = cursor;
      Belt_MutableStack.push(s, v$1);
      cursor = v$1.left;
    } else if (s.root !== undefined) {
      cursor = Belt_MutableStack.popUndefined(s);
      var current = cursor;
      Belt_MutableQueue.add(q, current.value);
      cursor = current.right;
    } else {
      todo = false;
    }
  };
}

function n(l, r, a) {
  return {
          value: a,
          left: Js_undefined.fromOption(l),
          right: Js_undefined.fromOption(r)
        };
}

var test1 = n(Caml_option.some(n(Caml_option.some(n(undefined, undefined, 4)), Caml_option.some(n(undefined, undefined, 5)), 2)), Caml_option.some(n(undefined, undefined, 3)), 1);

function pushAllLeft(st1, s1) {
  var current = st1;
  while(current !== undefined) {
    var v = current;
    Belt_MutableStack.push(s1, v);
    current = v.left;
  };
}

var test2 = n(Caml_option.some(n(Caml_option.some(n(Caml_option.some(n(Caml_option.some(n(undefined, undefined, 4)), undefined, 2)), undefined, 5)), undefined, 1)), undefined, 3);

var test3 = n(Caml_option.some(n(Caml_option.some(n(Caml_option.some(n(undefined, undefined, 4)), undefined, 2)), undefined, 5)), Caml_option.some(n(undefined, undefined, 3)), 1);

eq("File \"bs_stack_test.ml\", line 137, characters 6-13", inOrder(test1), [
      4,
      2,
      5,
      1,
      3
    ]);

eq("File \"bs_stack_test.ml\", line 140, characters 6-13", inOrder3(test1), [
      4,
      2,
      5,
      1,
      3
    ]);

Mt.from_pair_suites("bs_stack_test.ml", suites.contents);

exports.suites = suites;
exports.test_id = test_id;
exports.eq = eq;
exports.inOrder = inOrder;
exports.inOrder3 = inOrder3;
exports.inOrder2 = inOrder2;
exports.n = n;
exports.test1 = test1;
exports.pushAllLeft = pushAllLeft;
exports.test2 = test2;
exports.test3 = test3;
/* test1 Not a pure module */
