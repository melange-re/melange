'use strict';

var Caml_io = require("./caml_io.js");
var Stdlib__no_aliases = require("./stdlib__no_aliases.js");
var Caml_external_polyfill = require("./caml_external_polyfill.js");

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

exports.invalid_arg = invalid_arg;
exports.failwith = failwith;
exports.Exit = Exit;
exports.Match_failure = Match_failure;
exports.Assert_failure = Assert_failure;
exports.Invalid_argument = Invalid_argument;
exports.Failure = Failure;
exports.Not_found = Not_found;
exports.Out_of_memory = Out_of_memory;
exports.Stack_overflow = Stack_overflow;
exports.Sys_error = Sys_error;
exports.End_of_file = End_of_file;
exports.Division_by_zero = Division_by_zero;
exports.Sys_blocked_io = Sys_blocked_io;
exports.Undefined_recursive_module = Undefined_recursive_module;
exports.abs = abs;
exports.max_int = max_int;
exports.min_int = min_int;
exports.lnot = lnot;
exports.infinity = infinity;
exports.neg_infinity = neg_infinity;
exports.max_float = max_float;
exports.min_float = min_float;
exports.epsilon_float = epsilon_float;
exports.classify_float = classify_float;
exports.char_of_int = char_of_int;
exports.string_of_bool = string_of_bool;
exports.bool_of_string_opt = bool_of_string_opt;
exports.bool_of_string = bool_of_string;
exports.int_of_string_opt = int_of_string_opt;
exports.string_of_float = string_of_float;
exports.float_of_string_opt = float_of_string_opt;
exports.$at = $at;
exports.stdin = stdin;
exports.stdout = stdout;
exports.stderr = stderr;
exports.print_char = print_char;
exports.print_string = print_string;
exports.print_bytes = print_bytes;
exports.print_int = print_int;
exports.print_float = print_float;
exports.print_newline = print_newline;
exports.prerr_char = prerr_char;
exports.prerr_string = prerr_string;
exports.prerr_bytes = prerr_bytes;
exports.prerr_int = prerr_int;
exports.prerr_float = prerr_float;
exports.prerr_newline = prerr_newline;
exports.read_line = read_line;
exports.read_int_opt = read_int_opt;
exports.read_int = read_int;
exports.read_float_opt = read_float_opt;
exports.read_float = read_float;
exports.open_out = open_out;
exports.open_out_bin = open_out_bin;
exports.open_out_gen = open_out_gen;
exports.flush = flush;
exports.flush_all = flush_all;
exports.output_char = output_char;
exports.output_string = output_string;
exports.output_bytes = output_bytes;
exports.output = output;
exports.output_substring = output_substring;
exports.output_byte = output_byte;
exports.output_binary_int = output_binary_int;
exports.output_value = output_value;
exports.seek_out = seek_out;
exports.pos_out = pos_out;
exports.out_channel_length = out_channel_length;
exports.close_out = close_out;
exports.close_out_noerr = close_out_noerr;
exports.set_binary_mode_out = set_binary_mode_out;
exports.open_in = open_in;
exports.open_in_bin = open_in_bin;
exports.open_in_gen = open_in_gen;
exports.input_char = input_char;
exports.input_line = input_line;
exports.input = input;
exports.really_input = really_input;
exports.really_input_string = really_input_string;
exports.input_byte = input_byte;
exports.input_binary_int = input_binary_int;
exports.input_value = input_value;
exports.seek_in = seek_in;
exports.pos_in = pos_in;
exports.in_channel_length = in_channel_length;
exports.close_in = close_in;
exports.close_in_noerr = close_in_noerr;
exports.set_binary_mode_in = set_binary_mode_in;
exports.LargeFile = LargeFile;
exports.string_of_format = string_of_format;
exports.$caret$caret = $caret$caret;
exports.exit = exit;
exports.at_exit = at_exit;
exports.valid_float_lexem = valid_float_lexem;
exports.unsafe_really_input = unsafe_really_input;
exports.do_at_exit = do_at_exit;
/* No side effect */
