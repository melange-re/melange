'use strict';


function make(v) {
  return {
          v: v
        };
}

function get(r) {
  return r.v;
}

function set(r, v) {
  r.v = v;
  
}

function exchange(r, v) {
  var cur = r.v;
  r.v = v;
  return cur;
}

function compare_and_set(r, seen, v) {
  var cur = r.v;
  if (cur === seen) {
    r.v = v;
    return true;
  } else {
    return false;
  }
}

function fetch_and_add(r, n) {
  var cur = r.v;
  r.v = cur + n | 0;
  return cur;
}

function incr(r) {
  fetch_and_add(r, 1);
  
}

function decr(r) {
  fetch_and_add(r, -1);
  
}

exports.make = make;
exports.get = get;
exports.set = set;
exports.exchange = exchange;
exports.compare_and_set = compare_and_set;
exports.fetch_and_add = fetch_and_add;
exports.incr = incr;
exports.decr = decr;
/* No side effect */
