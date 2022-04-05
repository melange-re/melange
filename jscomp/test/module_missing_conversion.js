'use strict';

var $$Array = require("../../lib/js/array.js");
var Curry = require("../../lib/js/curry.js");
var $$String = require("../../lib/js/string.js");
var MoreLabels = require("../../lib/js/moreLabels.js");

function f(x) {
  return x;
}

var XX = {
  make_float: $$Array.make_float,
  init: $$Array.init,
  make_matrix: $$Array.make_matrix,
  create_matrix: $$Array.create_matrix,
  append: $$Array.append,
  concat: $$Array.concat,
  sub: $$Array.sub,
  copy: $$Array.copy,
  fill: $$Array.fill,
  blit: $$Array.blit,
  to_list: $$Array.to_list,
  of_list: $$Array.of_list,
  iter: $$Array.iter,
  iteri: $$Array.iteri,
  map: $$Array.map,
  mapi: $$Array.mapi,
  fold_left: $$Array.fold_left,
  fold_left_map: $$Array.fold_left_map,
  fold_right: $$Array.fold_right,
  iter2: $$Array.iter2,
  map2: $$Array.map2,
  for_all: $$Array.for_all,
  exists: $$Array.exists,
  for_all2: $$Array.for_all2,
  exists2: $$Array.exists2,
  mem: $$Array.mem,
  memq: $$Array.memq,
  find_opt: $$Array.find_opt,
  find_map: $$Array.find_map,
  split: $$Array.split,
  combine: $$Array.combine,
  sort: $$Array.sort,
  stable_sort: $$Array.stable_sort,
  fast_sort: $$Array.fast_sort,
  to_seq: $$Array.to_seq,
  to_seqi: $$Array.to_seqi,
  of_seq: $$Array.of_seq,
  Floatarray: $$Array.Floatarray,
  f: f
};

var u = [$$String];

var ghh = Curry._2(MoreLabels.Hashtbl.create, undefined, 30);

var hh = 1;

exports.XX = XX;
exports.u = u;
exports.hh = hh;
exports.ghh = ghh;
/* ghh Not a pure module */
