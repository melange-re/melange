'use strict';

var List = require("melange/lib/js/list.js");
var Stdlib = require("melange/lib/js/stdlib.js");

var a0 = {
  RE_EXN_ID: Stdlib.Not_found
};

var b = List.length({
      hd: 1,
      tl: {
        hd: 2,
        tl: /* [] */0
      }
    });

var List$1 = {
  compare_lengths: List.compare_lengths,
  compare_length_with: List.compare_length_with,
  cons: List.cons,
  hd: List.hd,
  tl: List.tl,
  nth: List.nth,
  nth_opt: List.nth_opt,
  rev: List.rev,
  init: List.init,
  append: List.append,
  rev_append: List.rev_append,
  concat: List.concat,
  flatten: List.flatten,
  equal: List.equal,
  compare: List.compare,
  iter: List.iter,
  iteri: List.iteri,
  map: List.map,
  mapi: List.mapi,
  rev_map: List.rev_map,
  filter_map: List.filter_map,
  concat_map: List.concat_map,
  fold_left_map: List.fold_left_map,
  fold_left: List.fold_left,
  fold_right: List.fold_right,
  iter2: List.iter2,
  map2: List.map2,
  rev_map2: List.rev_map2,
  fold_left2: List.fold_left2,
  fold_right2: List.fold_right2,
  for_all: List.for_all,
  exists: List.exists,
  for_all2: List.for_all2,
  exists2: List.exists2,
  mem: List.mem,
  memq: List.memq,
  find: List.find,
  find_opt: List.find_opt,
  find_map: List.find_map,
  filter: List.filter,
  find_all: List.find_all,
  filteri: List.filteri,
  partition: List.partition,
  partition_map: List.partition_map,
  assoc: List.assoc,
  assoc_opt: List.assoc_opt,
  assq: List.assq,
  assq_opt: List.assq_opt,
  mem_assoc: List.mem_assoc,
  mem_assq: List.mem_assq,
  remove_assoc: List.remove_assoc,
  remove_assq: List.remove_assq,
  split: List.split,
  combine: List.combine,
  sort: List.sort,
  stable_sort: List.stable_sort,
  fast_sort: List.fast_sort,
  sort_uniq: List.sort_uniq,
  merge: List.merge,
  to_seq: List.to_seq,
  of_seq: List.of_seq,
  b: b,
  length: 3
};

var a1 = a0;

var a2 = a0;

var a3 = a0;

var a4 = a0;

var a5 = a0;

exports.a0 = a0;
exports.a1 = a1;
exports.a2 = a2;
exports.a3 = a3;
exports.a4 = a4;
exports.a5 = a5;
exports.List = List$1;
/* b Not a pure module */
