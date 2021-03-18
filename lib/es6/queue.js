

import * as Seq from "./seq.js";
import * as Curry from "./curry.js";
import * as Caml_option from "./caml_option.js";
import * as Caml_exceptions from "./caml_exceptions.js";

var Empty = /* @__PURE__ */Caml_exceptions.create("Queue.Empty");

function create(param) {
  return {
          length: 0,
          first: /* Nil */0,
          last: /* Nil */0
        };
}

function clear(q) {
  q.length = 0;
  q.first = /* Nil */0;
  q.last = /* Nil */0;
  
}

function add(x, q) {
  var cell = /* Cons */{
    content: x,
    next: /* Nil */0
  };
  var last = q.last;
  if (last) {
    q.length = q.length + 1 | 0;
    last.next = cell;
    q.last = cell;
  } else {
    q.length = 1;
    q.first = cell;
    q.last = cell;
  }
  
}

function peek(q) {
  var match = q.first;
  if (match) {
    return match.content;
  }
  throw {
        RE_EXN_ID: Empty,
        Error: new Error()
      };
}

function peek_opt(q) {
  var match = q.first;
  if (match) {
    return Caml_option.some(match.content);
  }
  
}

function take(q) {
  var match = q.first;
  if (match) {
    var content = match.content;
    var match$1 = match.next;
    if (match$1) {
      var next = match.next;
      q.length = q.length - 1 | 0;
      q.first = next;
      return content;
    }
    clear(q);
    return content;
  }
  throw {
        RE_EXN_ID: Empty,
        Error: new Error()
      };
}

function take_opt(q) {
  var match = q.first;
  if (!match) {
    return ;
  }
  var content = match.content;
  var match$1 = match.next;
  if (match$1) {
    var next = match.next;
    q.length = q.length - 1 | 0;
    q.first = next;
    return Caml_option.some(content);
  }
  clear(q);
  return Caml_option.some(content);
}

function copy(q) {
  var q_res = {
    length: q.length,
    first: /* Nil */0,
    last: /* Nil */0
  };
  var _prev = /* Nil */0;
  var _cell = q.first;
  while(true) {
    var cell = _cell;
    var prev = _prev;
    if (cell) {
      var next = cell.next;
      var res = /* Cons */{
        content: cell.content,
        next: /* Nil */0
      };
      if (prev) {
        prev.next = res;
      } else {
        q_res.first = res;
      }
      _cell = next;
      _prev = res;
      continue ;
    }
    q_res.last = prev;
    return q_res;
  };
}

function is_empty(q) {
  return q.length === 0;
}

function length(q) {
  return q.length;
}

function iter(f, q) {
  var _cell = q.first;
  while(true) {
    var cell = _cell;
    if (!cell) {
      return ;
    }
    var next = cell.next;
    Curry._1(f, cell.content);
    _cell = next;
    continue ;
  };
}

function fold(f, accu, q) {
  var _accu = accu;
  var _cell = q.first;
  while(true) {
    var cell = _cell;
    var accu$1 = _accu;
    if (!cell) {
      return accu$1;
    }
    var next = cell.next;
    var accu$2 = Curry._2(f, accu$1, cell.content);
    _cell = next;
    _accu = accu$2;
    continue ;
  };
}

function transfer(q1, q2) {
  if (q1.length <= 0) {
    return ;
  }
  var last = q2.last;
  if (last) {
    q2.length = q2.length + q1.length | 0;
    last.next = q1.first;
    q2.last = q1.last;
    return clear(q1);
  } else {
    q2.length = q1.length;
    q2.first = q1.first;
    q2.last = q1.last;
    return clear(q1);
  }
}

function to_seq(q) {
  var aux = function (c, param) {
    if (!c) {
      return /* Nil */0;
    }
    var next = c.next;
    return /* Cons */{
            _0: c.content,
            _1: (function (param) {
                return aux(next, param);
              })
          };
  };
  var partial_arg = q.first;
  return function (param) {
    return aux(partial_arg, param);
  };
}

function add_seq(q, i) {
  return Seq.iter((function (x) {
                return add(x, q);
              }), i);
}

function of_seq(g) {
  var q = {
    length: 0,
    first: /* Nil */0,
    last: /* Nil */0
  };
  add_seq(q, g);
  return q;
}

var push = add;

var pop = take;

var top = peek;

export {
  Empty ,
  create ,
  add ,
  push ,
  take ,
  take_opt ,
  pop ,
  peek ,
  peek_opt ,
  top ,
  clear ,
  copy ,
  is_empty ,
  length ,
  iter ,
  fold ,
  transfer ,
  to_seq ,
  add_seq ,
  of_seq ,
  
}
/* No side effect */
