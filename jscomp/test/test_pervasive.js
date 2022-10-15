'use strict';

var List = require("melange/lib/js/list.js");
var Pervasives = require("melange/lib/js/pervasives.js");

var Pervasives$1 = {
  length: List.length,
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
  invalid_arg: Pervasives.invalid_arg,
  failwith: Pervasives.failwith,
  Exit: Pervasives.Exit,
  min: Pervasives.min,
  max: Pervasives.max,
  abs: Pervasives.abs,
  max_int: Pervasives.max_int,
  min_int: Pervasives.min_int,
  lnot: Pervasives.lnot,
  infinity: Pervasives.infinity,
  neg_infinity: Pervasives.neg_infinity,
  nan: Pervasives.nan,
  max_float: Pervasives.max_float,
  min_float: Pervasives.min_float,
  epsilon_float: Pervasives.epsilon_float,
  $caret: Pervasives.$caret,
  char_of_int: Pervasives.char_of_int,
  string_of_bool: Pervasives.string_of_bool,
  bool_of_string: Pervasives.bool_of_string,
  bool_of_string_opt: Pervasives.bool_of_string_opt,
  string_of_int: Pervasives.string_of_int,
  int_of_string_opt: Pervasives.int_of_string_opt,
  string_of_float: Pervasives.string_of_float,
  float_of_string_opt: Pervasives.float_of_string_opt,
  $at: Pervasives.$at,
  stdin: Pervasives.stdin,
  stdout: Pervasives.stdout,
  stderr: Pervasives.stderr,
  print_char: Pervasives.print_char,
  print_string: Pervasives.print_string,
  print_bytes: Pervasives.print_bytes,
  print_int: Pervasives.print_int,
  print_float: Pervasives.print_float,
  print_endline: Pervasives.print_endline,
  print_newline: Pervasives.print_newline,
  prerr_char: Pervasives.prerr_char,
  prerr_string: Pervasives.prerr_string,
  prerr_bytes: Pervasives.prerr_bytes,
  prerr_int: Pervasives.prerr_int,
  prerr_float: Pervasives.prerr_float,
  prerr_endline: Pervasives.prerr_endline,
  prerr_newline: Pervasives.prerr_newline,
  read_line: Pervasives.read_line,
  read_int: Pervasives.read_int,
  read_int_opt: Pervasives.read_int_opt,
  read_float: Pervasives.read_float,
  read_float_opt: Pervasives.read_float_opt,
  open_out: Pervasives.open_out,
  open_out_bin: Pervasives.open_out_bin,
  open_out_gen: Pervasives.open_out_gen,
  flush: Pervasives.flush,
  flush_all: Pervasives.flush_all,
  output_char: Pervasives.output_char,
  output_string: Pervasives.output_string,
  output_bytes: Pervasives.output_bytes,
  output: Pervasives.output,
  output_substring: Pervasives.output_substring,
  output_byte: Pervasives.output_byte,
  output_binary_int: Pervasives.output_binary_int,
  output_value: Pervasives.output_value,
  seek_out: Pervasives.seek_out,
  pos_out: Pervasives.pos_out,
  out_channel_length: Pervasives.out_channel_length,
  close_out: Pervasives.close_out,
  close_out_noerr: Pervasives.close_out_noerr,
  set_binary_mode_out: Pervasives.set_binary_mode_out,
  open_in: Pervasives.open_in,
  open_in_bin: Pervasives.open_in_bin,
  open_in_gen: Pervasives.open_in_gen,
  input_char: Pervasives.input_char,
  input_line: Pervasives.input_line,
  input: Pervasives.input,
  really_input: Pervasives.really_input,
  really_input_string: Pervasives.really_input_string,
  input_byte: Pervasives.input_byte,
  input_binary_int: Pervasives.input_binary_int,
  input_value: Pervasives.input_value,
  seek_in: Pervasives.seek_in,
  pos_in: Pervasives.pos_in,
  in_channel_length: Pervasives.in_channel_length,
  close_in: Pervasives.close_in,
  close_in_noerr: Pervasives.close_in_noerr,
  set_binary_mode_in: Pervasives.set_binary_mode_in,
  string_of_format: Pervasives.string_of_format,
  $caret$caret: Pervasives.$caret$caret,
  exit: Pervasives.exit,
  at_exit: Pervasives.at_exit,
  valid_float_lexem: Pervasives.valid_float_lexem,
  do_at_exit: Pervasives.do_at_exit
};

function a0(prim) {
  return Math.abs(prim);
}

function a1(prim) {
  return Math.acos(prim);
}

function a2(prim) {
  return Math.tan(prim);
}

function a3(prim) {
  return Math.tanh(prim);
}

function a4(prim) {
  return Math.asin(prim);
}

function a5(prim0, prim1) {
  return Math.atan2(prim0, prim1);
}

function a6(prim) {
  return Math.atan(prim);
}

function a7(prim) {
  return Math.ceil(prim);
}

function a8(prim) {
  return Math.cos(prim);
}

function a9(prim) {
  return Math.cosh(prim);
}

function a10(prim) {
  return Math.exp(prim);
}

function a11(prim) {
  return Math.sin(prim);
}

function a12(prim) {
  return Math.sinh(prim);
}

function a13(prim) {
  return Math.sqrt(prim);
}

function a14(prim) {
  return Math.floor(prim);
}

function a15(prim) {
  return Math.log(prim);
}

function a16(prim) {
  return Math.log10(prim);
}

function a17(prim) {
  return Math.log1p(prim);
}

function a18(prim0, prim1) {
  return Math.pow(prim0, prim1);
}

var f = Pervasives.$at;

exports.Pervasives = Pervasives$1;
exports.f = f;
exports.a0 = a0;
exports.a1 = a1;
exports.a2 = a2;
exports.a3 = a3;
exports.a4 = a4;
exports.a5 = a5;
exports.a6 = a6;
exports.a7 = a7;
exports.a8 = a8;
exports.a9 = a9;
exports.a10 = a10;
exports.a11 = a11;
exports.a12 = a12;
exports.a13 = a13;
exports.a14 = a14;
exports.a15 = a15;
exports.a16 = a16;
exports.a17 = a17;
exports.a18 = a18;
/* Pervasives Not a pure module */
