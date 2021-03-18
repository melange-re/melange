

import * as Caml_io from "./caml_io.js";
import * as Stdlib__no_aliases from "./stdlib__no_aliases.js";
import * as Caml_external_polyfill from "./caml_external_polyfill.js";

var invalid_arg = Stdlib__no_aliases.Stdlib.invalid_arg;

var failwith = Stdlib__no_aliases.Stdlib.failwith;

var Exit = Stdlib__no_aliases.Stdlib.Exit;

var Match_failure = Stdlib__no_aliases.Stdlib.Match_failure;

var Assert_failure = Stdlib__no_aliases.Stdlib.Assert_failure;

var Invalid_argument = Stdlib__no_aliases.Stdlib.Invalid_argument;

var Failure = Stdlib__no_aliases.Stdlib.Failure;

var Not_found = Stdlib__no_aliases.Stdlib.Not_found;

var Out_of_memory = Stdlib__no_aliases.Stdlib.Out_of_memory;

var Stack_overflow = Stdlib__no_aliases.Stdlib.Stack_overflow;

var Sys_error = Stdlib__no_aliases.Stdlib.Sys_error;

var End_of_file = Stdlib__no_aliases.Stdlib.End_of_file;

var Division_by_zero = Stdlib__no_aliases.Stdlib.Division_by_zero;

var Sys_blocked_io = Stdlib__no_aliases.Stdlib.Sys_blocked_io;

var Undefined_recursive_module = Stdlib__no_aliases.Stdlib.Undefined_recursive_module;

var abs = Stdlib__no_aliases.Stdlib.abs;

var max_int = Stdlib__no_aliases.Stdlib.max_int;

var min_int = Stdlib__no_aliases.Stdlib.min_int;

var lnot = Stdlib__no_aliases.Stdlib.lnot;

var infinity = Stdlib__no_aliases.Stdlib.infinity;

var neg_infinity = Stdlib__no_aliases.Stdlib.neg_infinity;

var max_float = Stdlib__no_aliases.Stdlib.max_float;

var min_float = Stdlib__no_aliases.Stdlib.min_float;

var epsilon_float = Stdlib__no_aliases.Stdlib.epsilon_float;

var classify_float = Stdlib__no_aliases.Stdlib.classify_float;

var char_of_int = Stdlib__no_aliases.Stdlib.char_of_int;

var string_of_bool = Stdlib__no_aliases.Stdlib.string_of_bool;

var bool_of_string_opt = Stdlib__no_aliases.Stdlib.bool_of_string_opt;

var bool_of_string = Stdlib__no_aliases.Stdlib.bool_of_string;

var int_of_string_opt = Stdlib__no_aliases.Stdlib.int_of_string_opt;

var string_of_float = Stdlib__no_aliases.Stdlib.string_of_float;

var float_of_string_opt = Stdlib__no_aliases.Stdlib.float_of_string_opt;

var $at = Stdlib__no_aliases.Stdlib.$at;

var stdin = Stdlib__no_aliases.Stdlib.stdin;

var stdout = Stdlib__no_aliases.Stdlib.stdout;

var stderr = Stdlib__no_aliases.Stdlib.stderr;

var print_char = Stdlib__no_aliases.Stdlib.print_char;

var print_string = Stdlib__no_aliases.Stdlib.print_string;

var print_bytes = Stdlib__no_aliases.Stdlib.print_bytes;

var print_int = Stdlib__no_aliases.Stdlib.print_int;

var print_float = Stdlib__no_aliases.Stdlib.print_float;

var print_newline = Stdlib__no_aliases.Stdlib.print_newline;

var prerr_char = Stdlib__no_aliases.Stdlib.prerr_char;

var prerr_string = Stdlib__no_aliases.Stdlib.prerr_string;

var prerr_bytes = Stdlib__no_aliases.Stdlib.prerr_bytes;

var prerr_int = Stdlib__no_aliases.Stdlib.prerr_int;

var prerr_float = Stdlib__no_aliases.Stdlib.prerr_float;

var prerr_newline = Stdlib__no_aliases.Stdlib.prerr_newline;

var read_line = Stdlib__no_aliases.Stdlib.read_line;

var read_int_opt = Stdlib__no_aliases.Stdlib.read_int_opt;

var read_int = Stdlib__no_aliases.Stdlib.read_int;

var read_float_opt = Stdlib__no_aliases.Stdlib.read_float_opt;

var read_float = Stdlib__no_aliases.Stdlib.read_float;

var open_out = Stdlib__no_aliases.Stdlib.open_out;

var open_out_bin = Stdlib__no_aliases.Stdlib.open_out_bin;

var open_out_gen = Stdlib__no_aliases.Stdlib.open_out_gen;

var flush = Caml_io.caml_ml_flush;

var flush_all = Stdlib__no_aliases.Stdlib.flush_all;

var output_char = Caml_io.caml_ml_output_char;

var output_string = Stdlib__no_aliases.Stdlib.output_string;

var output_bytes = Stdlib__no_aliases.Stdlib.output_bytes;

var output = Stdlib__no_aliases.Stdlib.output;

var output_substring = Stdlib__no_aliases.Stdlib.output_substring;

var output_byte = Caml_io.caml_ml_output_char;

function output_binary_int(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_ml_output_int")(prim, prim$1);
}

var output_value = Stdlib__no_aliases.Stdlib.output_value;

function seek_out(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_ml_seek_out")(prim, prim$1);
}

function pos_out(prim) {
  return Caml_external_polyfill.resolve("caml_ml_pos_out")(prim);
}

function out_channel_length(prim) {
  return Caml_external_polyfill.resolve("caml_ml_channel_size")(prim);
}

var close_out = Stdlib__no_aliases.Stdlib.close_out;

var close_out_noerr = Stdlib__no_aliases.Stdlib.close_out_noerr;

function set_binary_mode_out(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_ml_set_binary_mode")(prim, prim$1);
}

var open_in = Stdlib__no_aliases.Stdlib.open_in;

var open_in_bin = Stdlib__no_aliases.Stdlib.open_in_bin;

var open_in_gen = Stdlib__no_aliases.Stdlib.open_in_gen;

function input_char(prim) {
  return Caml_external_polyfill.resolve("caml_ml_input_char")(prim);
}

var input_line = Stdlib__no_aliases.Stdlib.input_line;

var input = Stdlib__no_aliases.Stdlib.input;

var really_input = Stdlib__no_aliases.Stdlib.really_input;

var really_input_string = Stdlib__no_aliases.Stdlib.really_input_string;

function input_byte(prim) {
  return Caml_external_polyfill.resolve("caml_ml_input_char")(prim);
}

function input_binary_int(prim) {
  return Caml_external_polyfill.resolve("caml_ml_input_int")(prim);
}

function input_value(prim) {
  return Caml_external_polyfill.resolve("caml_input_value")(prim);
}

function seek_in(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_ml_seek_in")(prim, prim$1);
}

function pos_in(prim) {
  return Caml_external_polyfill.resolve("caml_ml_pos_in")(prim);
}

function in_channel_length(prim) {
  return Caml_external_polyfill.resolve("caml_ml_channel_size")(prim);
}

function close_in(prim) {
  return Caml_external_polyfill.resolve("caml_ml_close_channel")(prim);
}

var close_in_noerr = Stdlib__no_aliases.Stdlib.close_in_noerr;

function set_binary_mode_in(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_ml_set_binary_mode")(prim, prim$1);
}

function LargeFile_seek_out(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_ml_seek_out_64")(prim, prim$1);
}

function LargeFile_pos_out(prim) {
  return Caml_external_polyfill.resolve("caml_ml_pos_out_64")(prim);
}

function LargeFile_out_channel_length(prim) {
  return Caml_external_polyfill.resolve("caml_ml_channel_size_64")(prim);
}

function LargeFile_seek_in(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_ml_seek_in_64")(prim, prim$1);
}

function LargeFile_pos_in(prim) {
  return Caml_external_polyfill.resolve("caml_ml_pos_in_64")(prim);
}

function LargeFile_in_channel_length(prim) {
  return Caml_external_polyfill.resolve("caml_ml_channel_size_64")(prim);
}

var LargeFile = {
  seek_out: LargeFile_seek_out,
  pos_out: LargeFile_pos_out,
  out_channel_length: LargeFile_out_channel_length,
  seek_in: LargeFile_seek_in,
  pos_in: LargeFile_pos_in,
  in_channel_length: LargeFile_in_channel_length
};

var string_of_format = Stdlib__no_aliases.Stdlib.string_of_format;

var $caret$caret = Stdlib__no_aliases.Stdlib.$caret$caret;

var exit = Stdlib__no_aliases.Stdlib.exit;

var at_exit = Stdlib__no_aliases.Stdlib.at_exit;

var valid_float_lexem = Stdlib__no_aliases.Stdlib.valid_float_lexem;

var unsafe_really_input = Stdlib__no_aliases.Stdlib.unsafe_really_input;

var do_at_exit = Stdlib__no_aliases.Stdlib.do_at_exit;

export {
  invalid_arg ,
  failwith ,
  Exit ,
  Match_failure ,
  Assert_failure ,
  Invalid_argument ,
  Failure ,
  Not_found ,
  Out_of_memory ,
  Stack_overflow ,
  Sys_error ,
  End_of_file ,
  Division_by_zero ,
  Sys_blocked_io ,
  Undefined_recursive_module ,
  abs ,
  max_int ,
  min_int ,
  lnot ,
  infinity ,
  neg_infinity ,
  max_float ,
  min_float ,
  epsilon_float ,
  classify_float ,
  char_of_int ,
  string_of_bool ,
  bool_of_string_opt ,
  bool_of_string ,
  int_of_string_opt ,
  string_of_float ,
  float_of_string_opt ,
  $at ,
  stdin ,
  stdout ,
  stderr ,
  print_char ,
  print_string ,
  print_bytes ,
  print_int ,
  print_float ,
  print_newline ,
  prerr_char ,
  prerr_string ,
  prerr_bytes ,
  prerr_int ,
  prerr_float ,
  prerr_newline ,
  read_line ,
  read_int_opt ,
  read_int ,
  read_float_opt ,
  read_float ,
  open_out ,
  open_out_bin ,
  open_out_gen ,
  flush ,
  flush_all ,
  output_char ,
  output_string ,
  output_bytes ,
  output ,
  output_substring ,
  output_byte ,
  output_binary_int ,
  output_value ,
  seek_out ,
  pos_out ,
  out_channel_length ,
  close_out ,
  close_out_noerr ,
  set_binary_mode_out ,
  open_in ,
  open_in_bin ,
  open_in_gen ,
  input_char ,
  input_line ,
  input ,
  really_input ,
  really_input_string ,
  input_byte ,
  input_binary_int ,
  input_value ,
  seek_in ,
  pos_in ,
  in_channel_length ,
  close_in ,
  close_in_noerr ,
  set_binary_mode_in ,
  LargeFile ,
  string_of_format ,
  $caret$caret ,
  exit ,
  at_exit ,
  valid_float_lexem ,
  unsafe_really_input ,
  do_at_exit ,
  
}
/* No side effect */
