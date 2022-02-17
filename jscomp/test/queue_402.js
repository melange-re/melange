'use strict';

var Curry = require("../../lib/js/curry.js");
var Caml_obj = require("../../lib/js/caml_obj.js");
var Caml_exceptions = require("../../lib/js/caml_exceptions.js");

var Empty = /* @__PURE__ */Caml_exceptions.create("Queue_402.Empty");

function create(param) {
  return {
          length: 0,
          tail: undefined
        };
}

function clear(q) {
  q.length = 0;
  q.tail = undefined;
}

function add(x, q) {
  if (q.length === 0) {
    var cell = {};
    cell.content = x;
    cell.next = cell;
    q.length = 1;
    q.tail = cell;
    return ;
  }
  var tail = q.tail;
  var head = tail.next;
  var cell$1 = {
    content: x,
    next: head
  };
  q.length = q.length + 1 | 0;
  tail.next = cell$1;
  q.tail = cell$1;
}

function peek(q) {
  if (q.length === 0) {
    throw {
          RE_EXN_ID: Empty,
          Error: new Error()
        };
  }
  return q.tail.next.content;
}

function take(q) {
  if (q.length === 0) {
    throw {
          RE_EXN_ID: Empty,
          Error: new Error()
        };
  }
  q.length = q.length - 1 | 0;
  var tail = q.tail;
  var head = tail.next;
  if (head === tail) {
    q.tail = undefined;
  } else {
    tail.next = head.next;
  }
  return head.content;
}

function copy(q) {
  if (q.length === 0) {
    return {
            length: 0,
            tail: undefined
          };
  }
  var tail = q.tail;
  var tail$p = {};
  Caml_obj.update_dummy(tail$p, {
        content: tail.content,
        next: tail$p
      });
  var copy$1 = function (_prev, _cell) {
    while(true) {
      var cell = _cell;
      var prev = _prev;
      if (cell === tail) {
        return ;
      }
      var res = {
        content: cell.content,
        next: tail$p
      };
      prev.next = res;
      _cell = cell.next;
      _prev = res;
      continue ;
    };
  };
  copy$1(tail$p, tail.next);
  return {
          length: q.length,
          tail: tail$p
        };
}

function is_empty(q) {
  return q.length === 0;
}

function length(q) {
  return q.length;
}

function iter(f, q) {
  if (q.length <= 0) {
    return ;
  }
  var tail = q.tail;
  var _cell = tail.next;
  while(true) {
    var cell = _cell;
    Curry._1(f, cell.content);
    if (cell === tail) {
      return ;
    }
    _cell = cell.next;
    continue ;
  };
}

function fold(f, accu, q) {
  if (q.length === 0) {
    return accu;
  }
  var tail = q.tail;
  var _accu = accu;
  var _cell = tail.next;
  while(true) {
    var cell = _cell;
    var accu$1 = _accu;
    var accu$2 = Curry._2(f, accu$1, cell.content);
    if (cell === tail) {
      return accu$2;
    }
    _cell = cell.next;
    _accu = accu$2;
    continue ;
  };
}

function transfer(q1, q2) {
  var length1 = q1.length;
  if (length1 <= 0) {
    return ;
  }
  var tail1 = q1.tail;
  clear(q1);
  if (q2.length > 0) {
    var tail2 = q2.tail;
    var head1 = tail1.next;
    var head2 = tail2.next;
    tail1.next = head2;
    tail2.next = head1;
  }
  q2.length = q2.length + length1 | 0;
  q2.tail = tail1;
}

function of_seq(param) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "queue_402.ml",
          167,
          15
        ],
        Error: new Error()
      };
}

function add_seq(param, param$1) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "queue_402.ml",
          168,
          18
        ],
        Error: new Error()
      };
}

function to_seq(param) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "queue_402.ml",
          169,
          15
        ],
        Error: new Error()
      };
}

function peek_opt(param) {
  
}

function take_opt(param) {
  
}

var push = add;

var top = peek;

var pop = take;

exports.Empty = Empty;
exports.create = create;
exports.clear = clear;
exports.add = add;
exports.push = push;
exports.peek = peek;
exports.top = top;
exports.take = take;
exports.pop = pop;
exports.copy = copy;
exports.is_empty = is_empty;
exports.length = length;
exports.iter = iter;
exports.fold = fold;
exports.transfer = transfer;
exports.of_seq = of_seq;
exports.add_seq = add_seq;
exports.to_seq = to_seq;
exports.peek_opt = peek_opt;
exports.take_opt = take_opt;
/* No side effect */
