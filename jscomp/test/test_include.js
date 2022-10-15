'use strict';

var List = require("melange/lib/js/list.js");
var $$String = require("melange/lib/js/string.js");
var Test_order = require("./test_order.js");

function Make(U) {
  var compare = U.compare;
  return {
          compare: compare,
          v: compare
        };
}

var X = {
  compare: $$String.compare,
  v: $$String.compare
};

var U = {
  compare: Test_order.compare,
  v: Test_order.compare
};

var v = List.length;

var length = List.length;

var compare_lengths = List.compare_lengths;

var compare_length_with = List.compare_length_with;

var cons = List.cons;

var hd = List.hd;

var tl = List.tl;

var nth = List.nth;

var nth_opt = List.nth_opt;

var rev = List.rev;

var init = List.init;

var append = List.append;

var rev_append = List.rev_append;

var concat = List.concat;

var flatten = List.flatten;

var equal = List.equal;

var compare = List.compare;

var iter = List.iter;

var iteri = List.iteri;

var map = List.map;

var mapi = List.mapi;

var rev_map = List.rev_map;

var filter_map = List.filter_map;

var concat_map = List.concat_map;

var fold_left_map = List.fold_left_map;

var fold_left = List.fold_left;

var fold_right = List.fold_right;

var iter2 = List.iter2;

var map2 = List.map2;

var rev_map2 = List.rev_map2;

var fold_left2 = List.fold_left2;

var fold_right2 = List.fold_right2;

var for_all = List.for_all;

var exists = List.exists;

var for_all2 = List.for_all2;

var exists2 = List.exists2;

var mem = List.mem;

var memq = List.memq;

var find = List.find;

var find_opt = List.find_opt;

var find_map = List.find_map;

var filter = List.filter;

var find_all = List.find_all;

var filteri = List.filteri;

var partition = List.partition;

var partition_map = List.partition_map;

var assoc = List.assoc;

var assoc_opt = List.assoc_opt;

var assq = List.assq;

var assq_opt = List.assq_opt;

var mem_assoc = List.mem_assoc;

var mem_assq = List.mem_assq;

var remove_assoc = List.remove_assoc;

var remove_assq = List.remove_assq;

var split = List.split;

var combine = List.combine;

var sort = List.sort;

var stable_sort = List.stable_sort;

var fast_sort = List.fast_sort;

var sort_uniq = List.sort_uniq;

var merge = List.merge;

var to_seq = List.to_seq;

var of_seq = List.of_seq;

exports.v = v;
exports.Make = Make;
exports.X = X;
exports.U = U;
exports.length = length;
exports.compare_lengths = compare_lengths;
exports.compare_length_with = compare_length_with;
exports.cons = cons;
exports.hd = hd;
exports.tl = tl;
exports.nth = nth;
exports.nth_opt = nth_opt;
exports.rev = rev;
exports.init = init;
exports.append = append;
exports.rev_append = rev_append;
exports.concat = concat;
exports.flatten = flatten;
exports.equal = equal;
exports.compare = compare;
exports.iter = iter;
exports.iteri = iteri;
exports.map = map;
exports.mapi = mapi;
exports.rev_map = rev_map;
exports.filter_map = filter_map;
exports.concat_map = concat_map;
exports.fold_left_map = fold_left_map;
exports.fold_left = fold_left;
exports.fold_right = fold_right;
exports.iter2 = iter2;
exports.map2 = map2;
exports.rev_map2 = rev_map2;
exports.fold_left2 = fold_left2;
exports.fold_right2 = fold_right2;
exports.for_all = for_all;
exports.exists = exists;
exports.for_all2 = for_all2;
exports.exists2 = exists2;
exports.mem = mem;
exports.memq = memq;
exports.find = find;
exports.find_opt = find_opt;
exports.find_map = find_map;
exports.filter = filter;
exports.find_all = find_all;
exports.filteri = filteri;
exports.partition = partition;
exports.partition_map = partition_map;
exports.assoc = assoc;
exports.assoc_opt = assoc_opt;
exports.assq = assq;
exports.assq_opt = assq_opt;
exports.mem_assoc = mem_assoc;
exports.mem_assq = mem_assq;
exports.remove_assoc = remove_assoc;
exports.remove_assq = remove_assq;
exports.split = split;
exports.combine = combine;
exports.sort = sort;
exports.stable_sort = stable_sort;
exports.fast_sort = fast_sort;
exports.sort_uniq = sort_uniq;
exports.merge = merge;
exports.to_seq = to_seq;
exports.of_seq = of_seq;
/* No side effect */
