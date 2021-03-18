

import * as Caml_io from "./caml_io.js";
import * as Caml_obj from "./caml_obj.js";
import * as Caml_exceptions from "./caml_exceptions.js";
import * as Stdlib__no_aliases from "./stdlib__no_aliases.js";
import * as Caml_external_polyfill from "./caml_external_polyfill.js";

var Exit = /* @__PURE__ */Caml_exceptions.create("Pervasives.Exit");

var min = Caml_obj.caml_min;

var max = Caml_obj.caml_max;

var nan = Number.NaN;

function $caret(prim, prim$1) {
  return prim + prim$1;
}

function string_of_int(prim) {
  return String(prim);
}

function print_endline(prim) {
  console.log(prim);
  
}

function prerr_endline(prim) {
  console.error(prim);
  
}

var flush = Caml_io.caml_ml_flush;

var output_char = Caml_io.caml_ml_output_char;

var output_byte = Caml_io.caml_ml_output_char;

function output_binary_int(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_ml_output_int")(prim, prim$1);
}

function seek_out(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_ml_seek_out")(prim, prim$1);
}

function pos_out(prim) {
  return Caml_external_polyfill.resolve("caml_ml_pos_out")(prim);
}

function out_channel_length(prim) {
  return Caml_external_polyfill.resolve("caml_ml_channel_size")(prim);
}

function set_binary_mode_out(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_ml_set_binary_mode")(prim, prim$1);
}

function input_char(prim) {
  return Caml_external_polyfill.resolve("caml_ml_input_char")(prim);
}

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

function set_binary_mode_in(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_ml_set_binary_mode")(prim, prim$1);
}

var invalid_arg = Stdlib__no_aliases.invalid_arg;

var failwith = Stdlib__no_aliases.failwith;

var abs = Stdlib__no_aliases.abs;

var max_int = Stdlib__no_aliases.max_int;

var min_int = Stdlib__no_aliases.min_int;

var lnot = Stdlib__no_aliases.lnot;

var infinity = Stdlib__no_aliases.infinity;

var neg_infinity = Stdlib__no_aliases.neg_infinity;

var max_float = Stdlib__no_aliases.max_float;

var min_float = Stdlib__no_aliases.min_float;

var epsilon_float = Stdlib__no_aliases.epsilon_float;

var char_of_int = Stdlib__no_aliases.char_of_int;

var string_of_bool = Stdlib__no_aliases.string_of_bool;

var bool_of_string = Stdlib__no_aliases.bool_of_string;

var bool_of_string_opt = Stdlib__no_aliases.bool_of_string_opt;

var int_of_string_opt = Stdlib__no_aliases.int_of_string_opt;

var string_of_float = Stdlib__no_aliases.string_of_float;

var float_of_string_opt = Stdlib__no_aliases.float_of_string_opt;

var $at = Stdlib__no_aliases.$at;

var stdin = Stdlib__no_aliases.stdin;

var stdout = Stdlib__no_aliases.stdout;

var stderr = Stdlib__no_aliases.stderr;

var print_char = Stdlib__no_aliases.print_char;

var print_string = Stdlib__no_aliases.print_string;

var print_bytes = Stdlib__no_aliases.print_bytes;

var print_int = Stdlib__no_aliases.print_int;

var print_float = Stdlib__no_aliases.print_float;

var print_newline = Stdlib__no_aliases.print_newline;

var prerr_char = Stdlib__no_aliases.prerr_char;

var prerr_string = Stdlib__no_aliases.prerr_string;

var prerr_bytes = Stdlib__no_aliases.prerr_bytes;

var prerr_int = Stdlib__no_aliases.prerr_int;

var prerr_float = Stdlib__no_aliases.prerr_float;

var prerr_newline = Stdlib__no_aliases.prerr_newline;

var read_line = Stdlib__no_aliases.read_line;

var read_int = Stdlib__no_aliases.read_int;

var read_int_opt = Stdlib__no_aliases.read_int_opt;

var read_float = Stdlib__no_aliases.read_float;

var read_float_opt = Stdlib__no_aliases.read_float_opt;

var open_out = Stdlib__no_aliases.open_out;

var open_out_bin = Stdlib__no_aliases.open_out_bin;

var open_out_gen = Stdlib__no_aliases.open_out_gen;

var flush_all = Stdlib__no_aliases.flush_all;

var output_string = Stdlib__no_aliases.output_string;

var output_bytes = Stdlib__no_aliases.output_bytes;

var output = Stdlib__no_aliases.output;

var output_substring = Stdlib__no_aliases.output_substring;

var output_value = Stdlib__no_aliases.output_value;

var close_out = Stdlib__no_aliases.close_out;

var close_out_noerr = Stdlib__no_aliases.close_out_noerr;

var open_in = Stdlib__no_aliases.open_in;

var open_in_bin = Stdlib__no_aliases.open_in_bin;

var open_in_gen = Stdlib__no_aliases.open_in_gen;

var input_line = Stdlib__no_aliases.input_line;

var input = Stdlib__no_aliases.input;

var really_input = Stdlib__no_aliases.really_input;

var really_input_string = Stdlib__no_aliases.really_input_string;

var close_in_noerr = Stdlib__no_aliases.close_in_noerr;

var string_of_format = Stdlib__no_aliases.string_of_format;

var $caret$caret = Stdlib__no_aliases.$caret$caret;

var exit = Stdlib__no_aliases.exit;

var at_exit = Stdlib__no_aliases.at_exit;

var valid_float_lexem = Stdlib__no_aliases.valid_float_lexem;

var do_at_exit = Stdlib__no_aliases.do_at_exit;

export {
  invalid_arg ,
  failwith ,
  Exit ,
  min ,
  max ,
  abs ,
  max_int ,
  min_int ,
  lnot ,
  infinity ,
  neg_infinity ,
  nan ,
  max_float ,
  min_float ,
  epsilon_float ,
  $caret ,
  char_of_int ,
  string_of_bool ,
  bool_of_string ,
  bool_of_string_opt ,
  string_of_int ,
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
  print_endline ,
  print_newline ,
  prerr_char ,
  prerr_string ,
  prerr_bytes ,
  prerr_int ,
  prerr_float ,
  prerr_endline ,
  prerr_newline ,
  read_line ,
  read_int ,
  read_int_opt ,
  read_float ,
  read_float_opt ,
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
  string_of_format ,
  $caret$caret ,
  exit ,
  at_exit ,
  valid_float_lexem ,
  do_at_exit ,
  
}
/* nan Not a pure module */
