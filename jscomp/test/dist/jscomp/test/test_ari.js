// Generated by Melange
'use strict';

const Curry = require("melange.js/curry.js");
const Stdlib__List = require("melange/list.js");
const U = require("U");
const VV = require("VV");

function f(x) {
  return function (param) {
    return x + param | 0;
  };
}

function f1(x, y) {
  return x + y | 0;
}

function f3(g, x) {
  return Curry._1(g, x);
}

function f2(param) {
  return 3 + param | 0;
}

const g = 7;

function ff(param) {
  return U.test_primit(3, param);
}

const fff = VV.test_primit2(3);

function length_aux(_len, _param) {
  while (true) {
    const param = _param;
    const len = _len;
    if (!param) {
      return len;
    }
    _param = param.tl;
    _len = len + 1 | 0;
    continue;
  };
}

const length = Stdlib__List.length;

const compare_lengths = Stdlib__List.compare_lengths;

const compare_length_with = Stdlib__List.compare_length_with;

const is_empty = Stdlib__List.is_empty;

const cons = Stdlib__List.cons;

const singleton = Stdlib__List.singleton;

const hd = Stdlib__List.hd;

const tl = Stdlib__List.tl;

const nth = Stdlib__List.nth;

const nth_opt = Stdlib__List.nth_opt;

const rev = Stdlib__List.rev;

const init = Stdlib__List.init;

const append = Stdlib__List.append;

const rev_append = Stdlib__List.rev_append;

const concat = Stdlib__List.concat;

const flatten = Stdlib__List.flatten;

const equal = Stdlib__List.equal;

const compare = Stdlib__List.compare;

const iter = Stdlib__List.iter;

const iteri = Stdlib__List.iteri;

const map = Stdlib__List.map;

const mapi = Stdlib__List.mapi;

const rev_map = Stdlib__List.rev_map;

const filter_map = Stdlib__List.filter_map;

const concat_map = Stdlib__List.concat_map;

const fold_left_map = Stdlib__List.fold_left_map;

const fold_left = Stdlib__List.fold_left;

const fold_right = Stdlib__List.fold_right;

const iter2 = Stdlib__List.iter2;

const map2 = Stdlib__List.map2;

const rev_map2 = Stdlib__List.rev_map2;

const fold_left2 = Stdlib__List.fold_left2;

const fold_right2 = Stdlib__List.fold_right2;

const for_all = Stdlib__List.for_all;

const exists = Stdlib__List.exists;

const for_all2 = Stdlib__List.for_all2;

const exists2 = Stdlib__List.exists2;

const mem = Stdlib__List.mem;

const memq = Stdlib__List.memq;

const find = Stdlib__List.find;

const find_opt = Stdlib__List.find_opt;

const find_index = Stdlib__List.find_index;

const find_map = Stdlib__List.find_map;

const find_mapi = Stdlib__List.find_mapi;

const filter = Stdlib__List.filter;

const find_all = Stdlib__List.find_all;

const filteri = Stdlib__List.filteri;

const take = Stdlib__List.take;

const drop = Stdlib__List.drop;

const take_while = Stdlib__List.take_while;

const drop_while = Stdlib__List.drop_while;

const partition = Stdlib__List.partition;

const partition_map = Stdlib__List.partition_map;

const assoc = Stdlib__List.assoc;

const assoc_opt = Stdlib__List.assoc_opt;

const assq = Stdlib__List.assq;

const assq_opt = Stdlib__List.assq_opt;

const mem_assoc = Stdlib__List.mem_assoc;

const mem_assq = Stdlib__List.mem_assq;

const remove_assoc = Stdlib__List.remove_assoc;

const remove_assq = Stdlib__List.remove_assq;

const split = Stdlib__List.split;

const combine = Stdlib__List.combine;

const sort = Stdlib__List.sort;

const stable_sort = Stdlib__List.stable_sort;

const fast_sort = Stdlib__List.fast_sort;

const sort_uniq = Stdlib__List.sort_uniq;

const merge = Stdlib__List.merge;

const to_seq = Stdlib__List.to_seq;

const of_seq = Stdlib__List.of_seq;

module.exports = {
  f,
  f1,
  f3,
  f2,
  g,
  ff,
  fff,
  length_aux,
  length,
  compare_lengths,
  compare_length_with,
  is_empty,
  cons,
  singleton,
  hd,
  tl,
  nth,
  nth_opt,
  rev,
  init,
  append,
  rev_append,
  concat,
  flatten,
  equal,
  compare,
  iter,
  iteri,
  map,
  mapi,
  rev_map,
  filter_map,
  concat_map,
  fold_left_map,
  fold_left,
  fold_right,
  iter2,
  map2,
  rev_map2,
  fold_left2,
  fold_right2,
  for_all,
  exists,
  for_all2,
  exists2,
  mem,
  memq,
  find,
  find_opt,
  find_index,
  find_map,
  find_mapi,
  filter,
  find_all,
  filteri,
  take,
  drop,
  take_while,
  drop_while,
  partition,
  partition_map,
  assoc,
  assoc_opt,
  assq,
  assq_opt,
  mem_assoc,
  mem_assq,
  remove_assoc,
  remove_assq,
  split,
  combine,
  sort,
  stable_sort,
  fast_sort,
  sort_uniq,
  merge,
  to_seq,
  of_seq,
}
/* fff Not a pure module */
