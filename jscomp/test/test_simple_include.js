'use strict';

var $$Array = require("melange/lib/js/array.js");

var v = {
  contents: 32
};

v.contents = 0;

var N = {
  a: 3,
  v: v
};

var v$1 = {
  contents: 32
};

var NN = {
  a: 3,
  v: v$1
};

var make_float = $$Array.make_float;

var init = $$Array.init;

var make_matrix = $$Array.make_matrix;

var create_matrix = $$Array.create_matrix;

var append = $$Array.append;

var concat = $$Array.concat;

var sub = $$Array.sub;

var copy = $$Array.copy;

var fill = $$Array.fill;

var blit = $$Array.blit;

var to_list = $$Array.to_list;

var of_list = $$Array.of_list;

var iter = $$Array.iter;

var iteri = $$Array.iteri;

var map = $$Array.map;

var mapi = $$Array.mapi;

var fold_left = $$Array.fold_left;

var fold_left_map = $$Array.fold_left_map;

var fold_right = $$Array.fold_right;

var iter2 = $$Array.iter2;

var map2 = $$Array.map2;

var for_all = $$Array.for_all;

var exists = $$Array.exists;

var for_all2 = $$Array.for_all2;

var exists2 = $$Array.exists2;

var mem = $$Array.mem;

var memq = $$Array.memq;

var find_opt = $$Array.find_opt;

var find_map = $$Array.find_map;

var split = $$Array.split;

var combine = $$Array.combine;

var sort = $$Array.sort;

var stable_sort = $$Array.stable_sort;

var fast_sort = $$Array.fast_sort;

var to_seq = $$Array.to_seq;

var to_seqi = $$Array.to_seqi;

var of_seq = $$Array.of_seq;

var Floatarray = $$Array.Floatarray;

var a = 3;

exports.make_float = make_float;
exports.init = init;
exports.make_matrix = make_matrix;
exports.create_matrix = create_matrix;
exports.append = append;
exports.concat = concat;
exports.sub = sub;
exports.copy = copy;
exports.fill = fill;
exports.blit = blit;
exports.to_list = to_list;
exports.of_list = of_list;
exports.iter = iter;
exports.iteri = iteri;
exports.map = map;
exports.mapi = mapi;
exports.fold_left = fold_left;
exports.fold_left_map = fold_left_map;
exports.fold_right = fold_right;
exports.iter2 = iter2;
exports.map2 = map2;
exports.for_all = for_all;
exports.exists = exists;
exports.for_all2 = for_all2;
exports.exists2 = exists2;
exports.mem = mem;
exports.memq = memq;
exports.find_opt = find_opt;
exports.find_map = find_map;
exports.split = split;
exports.combine = combine;
exports.sort = sort;
exports.stable_sort = stable_sort;
exports.fast_sort = fast_sort;
exports.to_seq = to_seq;
exports.to_seqi = to_seqi;
exports.of_seq = of_seq;
exports.Floatarray = Floatarray;
exports.N = N;
exports.NN = NN;
exports.a = a;
exports.v = v;
/*  Not a pure module */
