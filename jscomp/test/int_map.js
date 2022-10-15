'use strict';

var $$Map = require("melange/jscomp/stdlib-412/stdlib_modules/map.js");
var Caml = require("melange/lib/js/caml.js");

var compare = Caml.caml_int_compare;

var include = $$Map.Make({
      compare: compare
    });

var empty = include.empty;

var is_empty = include.is_empty;

var mem = include.mem;

var add = include.add;

var update = include.update;

var singleton = include.singleton;

var remove = include.remove;

var merge = include.merge;

var union = include.union;

var compare$1 = include.compare;

var equal = include.equal;

var iter = include.iter;

var fold = include.fold;

var for_all = include.for_all;

var exists = include.exists;

var filter = include.filter;

var filter_map = include.filter_map;

var partition = include.partition;

var cardinal = include.cardinal;

var bindings = include.bindings;

var min_binding = include.min_binding;

var min_binding_opt = include.min_binding_opt;

var max_binding = include.max_binding;

var max_binding_opt = include.max_binding_opt;

var choose = include.choose;

var choose_opt = include.choose_opt;

var split = include.split;

var find = include.find;

var find_opt = include.find_opt;

var find_first = include.find_first;

var find_first_opt = include.find_first_opt;

var find_last = include.find_last;

var find_last_opt = include.find_last_opt;

var map = include.map;

var mapi = include.mapi;

var to_seq = include.to_seq;

var to_rev_seq = include.to_rev_seq;

var to_seq_from = include.to_seq_from;

var add_seq = include.add_seq;

var of_seq = include.of_seq;

exports.empty = empty;
exports.is_empty = is_empty;
exports.mem = mem;
exports.add = add;
exports.update = update;
exports.singleton = singleton;
exports.remove = remove;
exports.merge = merge;
exports.union = union;
exports.compare = compare$1;
exports.equal = equal;
exports.iter = iter;
exports.fold = fold;
exports.for_all = for_all;
exports.exists = exists;
exports.filter = filter;
exports.filter_map = filter_map;
exports.partition = partition;
exports.cardinal = cardinal;
exports.bindings = bindings;
exports.min_binding = min_binding;
exports.min_binding_opt = min_binding_opt;
exports.max_binding = max_binding;
exports.max_binding_opt = max_binding_opt;
exports.choose = choose;
exports.choose_opt = choose_opt;
exports.split = split;
exports.find = find;
exports.find_opt = find_opt;
exports.find_first = find_first;
exports.find_first_opt = find_first_opt;
exports.find_last = find_last;
exports.find_last_opt = find_last_opt;
exports.map = map;
exports.mapi = mapi;
exports.to_seq = to_seq;
exports.to_rev_seq = to_rev_seq;
exports.to_seq_from = to_seq_from;
exports.add_seq = add_seq;
exports.of_seq = of_seq;
/* include Not a pure module */
