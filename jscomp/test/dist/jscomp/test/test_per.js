// Generated by Melange
'use strict';

const Caml_bytes = require("melange.js/caml_bytes.js");
const Caml_exceptions = require("melange.js/caml_exceptions.js");
const Caml_external_polyfill = require("melange.js/caml_external_polyfill.js");
const Caml_format = require("melange.js/caml_format.js");
const Caml_int64 = require("melange.js/caml_int64.js");
const Caml_io = require("melange.js/caml_io.js");
const Caml_js_exceptions = require("melange.js/caml_js_exceptions.js");
const Caml_obj = require("melange.js/caml_obj.js");
const Caml_string = require("melange.js/caml_string.js");
const Caml_sys = require("melange.js/caml_sys.js");
const CamlinternalFormatBasics = require("melange/camlinternalFormatBasics.js");
const Curry = require("melange.js/curry.js");
const Stdlib = require("melange/stdlib.js");

function failwith(s) {
  throw new Caml_js_exceptions.MelangeError(Stdlib.Failure, {
      MEL_EXN_ID: Stdlib.Failure,
      _1: s
    });
}

function invalid_arg(s) {
  throw new Caml_js_exceptions.MelangeError(Stdlib.Invalid_argument, {
      MEL_EXN_ID: Stdlib.Invalid_argument,
      _1: s
    });
}

const Exit = /* @__PURE__ */ Caml_exceptions.create("Test_per.Exit");

function min(x, y) {
  if (Caml_obj.caml_lessequal(x, y)) {
    return x;
  } else {
    return y;
  }
}

function max(x, y) {
  if (Caml_obj.caml_greaterequal(x, y)) {
    return x;
  } else {
    return y;
  }
}

function abs(x) {
  if (x >= 0) {
    return x;
  } else {
    return -x | 0;
  }
}

function lnot(x) {
  return x ^ -1;
}

const min_int = -2147483648;

const infinity = Caml_int64.float_of_bits([
  2146435072,
  0
]);

const neg_infinity = Caml_int64.float_of_bits([
  -1048576,
  0
]);

const nan = Caml_int64.float_of_bits([
  2146435072,
  1
]);

const max_float = Caml_int64.float_of_bits([
  2146435071,
  4294967295
]);

const min_float = Caml_int64.float_of_bits([
  1048576,
  0
]);

const epsilon_float = Caml_int64.float_of_bits([
  1018167296,
  0
]);

function $caret(s1, s2) {
  const l1 = s1.length;
  const l2 = s2.length;
  const s = Caml_bytes.caml_create_bytes(l1 + l2 | 0);
  Caml_bytes.caml_blit_string(s1, 0, s, 0, l1);
  Caml_bytes.caml_blit_string(s2, 0, s, l1, l2);
  return s;
}

function char_of_int(n) {
  if (n < 0 || n > 255) {
    throw new Caml_js_exceptions.MelangeError(Stdlib.Invalid_argument, {
        MEL_EXN_ID: Stdlib.Invalid_argument,
        _1: "char_of_int"
      });
  }
  return n;
}

function string_of_bool(b) {
  if (b) {
    return "true";
  } else {
    return "false";
  }
}

function bool_of_string(param) {
  switch (param) {
    case "false" :
      return false;
    case "true" :
      return true;
    default:
      throw new Caml_js_exceptions.MelangeError(Stdlib.Invalid_argument, {
          MEL_EXN_ID: Stdlib.Invalid_argument,
          _1: "bool_of_string"
        });
  }
}

function string_of_int(n) {
  return Caml_format.caml_format_int("%d", n);
}

function valid_float_lexem(s) {
  const l = s.length;
  let _i = 0;
  while (true) {
    const i = _i;
    if (i >= l) {
      return $caret(s, ".");
    }
    const match = Caml_string.get(s, i);
    if (match >= 48) {
      if (match >= 58) {
        return s;
      }
      _i = i + 1 | 0;
      continue;
    }
    if (match !== 45) {
      return s;
    }
    _i = i + 1 | 0;
    continue;
  };
}

function string_of_float(f) {
  return valid_float_lexem(Caml_format.caml_format_float("%.12g", f));
}

function $at(l1, l2) {
  if (l1) {
    return {
      hd: l1.hd,
      tl: $at(l1.tl, l2)
    };
  } else {
    return l2;
  }
}

const stdin = Caml_io.stdin;

const stdout = Caml_io.stdout;

const stderr = Caml_io.stderr;

function open_out_gen(mode, perm, name) {
  return Caml_external_polyfill.resolve("caml_ml_open_descriptor_out")(Caml_external_polyfill.resolve("caml_sys_open")(name, mode, perm));
}

function open_out(name) {
  return open_out_gen({
    hd: /* Open_wronly */ 1,
    tl: {
      hd: /* Open_creat */ 3,
      tl: {
        hd: /* Open_trunc */ 4,
        tl: {
          hd: /* Open_text */ 7,
          tl: /* [] */ 0
        }
      }
    }
  }, 438, name);
}

function open_out_bin(name) {
  return open_out_gen({
    hd: /* Open_wronly */ 1,
    tl: {
      hd: /* Open_creat */ 3,
      tl: {
        hd: /* Open_trunc */ 4,
        tl: {
          hd: /* Open_binary */ 6,
          tl: /* [] */ 0
        }
      }
    }
  }, 438, name);
}

function flush_all(param) {
  let _param = Caml_io.caml_ml_out_channels_list(undefined);
  while (true) {
    const param$1 = _param;
    if (!param$1) {
      return;
    }
    try {
      Caml_io.caml_ml_flush(param$1.hd);
    }
    catch (exn){
      
    }
    _param = param$1.tl;
    continue;
  };
}

function output_bytes(oc, s) {
  Caml_io.caml_ml_output(oc, s, 0, s.length);
}

function output_string(oc, s) {
  Caml_io.caml_ml_output(oc, s, 0, s.length);
}

function output(oc, s, ofs, len) {
  if (ofs < 0 || len < 0 || ofs > (s.length - len | 0)) {
    throw new Caml_js_exceptions.MelangeError(Stdlib.Invalid_argument, {
        MEL_EXN_ID: Stdlib.Invalid_argument,
        _1: "output"
      });
  }
  Caml_io.caml_ml_output(oc, s, ofs, len);
}

function output_substring(oc, s, ofs, len) {
  if (ofs < 0 || len < 0 || ofs > (s.length - len | 0)) {
    throw new Caml_js_exceptions.MelangeError(Stdlib.Invalid_argument, {
        MEL_EXN_ID: Stdlib.Invalid_argument,
        _1: "output_substring"
      });
  }
  Caml_io.caml_ml_output(oc, s, ofs, len);
}

function output_value(chan, v) {
  Caml_external_polyfill.resolve("caml_output_value")(chan, v, /* [] */ 0);
}

function close_out(oc) {
  Caml_io.caml_ml_flush(oc);
  Caml_external_polyfill.resolve("caml_ml_close_channel")(oc);
}

function close_out_noerr(oc) {
  try {
    Caml_io.caml_ml_flush(oc);
  }
  catch (exn){
    
  }
  try {
    return Caml_external_polyfill.resolve("caml_ml_close_channel")(oc);
  }
  catch (exn$1){
    return;
  }
}

function open_in_gen(mode, perm, name) {
  return Caml_external_polyfill.resolve("caml_ml_open_descriptor_in")(Caml_external_polyfill.resolve("caml_sys_open")(name, mode, perm));
}

function open_in(name) {
  return open_in_gen({
    hd: /* Open_rdonly */ 0,
    tl: {
      hd: /* Open_text */ 7,
      tl: /* [] */ 0
    }
  }, 0, name);
}

function open_in_bin(name) {
  return open_in_gen({
    hd: /* Open_rdonly */ 0,
    tl: {
      hd: /* Open_binary */ 6,
      tl: /* [] */ 0
    }
  }, 0, name);
}

function input(ic, s, ofs, len) {
  if (ofs < 0 || len < 0 || ofs > (s.length - len | 0)) {
    throw new Caml_js_exceptions.MelangeError(Stdlib.Invalid_argument, {
        MEL_EXN_ID: Stdlib.Invalid_argument,
        _1: "input"
      });
  }
  return Caml_external_polyfill.resolve("caml_ml_input")(ic, s, ofs, len);
}

function unsafe_really_input(ic, s, _ofs, _len) {
  while (true) {
    const len = _len;
    const ofs = _ofs;
    if (len <= 0) {
      return;
    }
    const r = Caml_external_polyfill.resolve("caml_ml_input")(ic, s, ofs, len);
    if (r === 0) {
      throw new Caml_js_exceptions.MelangeError(Stdlib.End_of_file, {
          MEL_EXN_ID: Stdlib.End_of_file
        });
    }
    _len = len - r | 0;
    _ofs = ofs + r | 0;
    continue;
  };
}

function really_input(ic, s, ofs, len) {
  if (ofs < 0 || len < 0 || ofs > (s.length - len | 0)) {
    throw new Caml_js_exceptions.MelangeError(Stdlib.Invalid_argument, {
        MEL_EXN_ID: Stdlib.Invalid_argument,
        _1: "really_input"
      });
  }
  unsafe_really_input(ic, s, ofs, len);
}

function really_input_string(ic, len) {
  const s = Caml_bytes.caml_create_bytes(len);
  really_input(ic, s, 0, len);
  return s;
}

function input_line(chan) {
  const build_result = function (buf, _pos, _param) {
    while (true) {
      const param = _param;
      const pos = _pos;
      if (!param) {
        return buf;
      }
      const hd = param.hd;
      const len = hd.length;
      Caml_bytes.caml_blit_string(hd, 0, buf, pos - len | 0, len);
      _param = param.tl;
      _pos = pos - len | 0;
      continue;
    };
  };
  let _accu = /* [] */ 0;
  let _len = 0;
  while (true) {
    const len = _len;
    const accu = _accu;
    const n = Caml_external_polyfill.resolve("caml_ml_input_scan_line")(chan);
    if (n === 0) {
      if (accu) {
        return build_result(Caml_bytes.caml_create_bytes(len), len, accu);
      }
      throw new Caml_js_exceptions.MelangeError(Stdlib.End_of_file, {
          MEL_EXN_ID: Stdlib.End_of_file
        });
    }
    if (n > 0) {
      const res = Caml_bytes.caml_create_bytes(n - 1 | 0);
      Caml_external_polyfill.resolve("caml_ml_input")(chan, res, 0, n - 1 | 0);
      Caml_external_polyfill.resolve("caml_ml_input_char")(chan);
      if (!accu) {
        return res;
      }
      const len$1 = (len + n | 0) - 1 | 0;
      return build_result(Caml_bytes.caml_create_bytes(len$1), len$1, {
        hd: res,
        tl: accu
      });
    }
    const beg = Caml_bytes.caml_create_bytes(-n | 0);
    Caml_external_polyfill.resolve("caml_ml_input")(chan, beg, 0, -n | 0);
    _len = len - n | 0;
    _accu = {
      hd: beg,
      tl: accu
    };
    continue;
  };
}

function close_in_noerr(ic) {
  try {
    return Caml_external_polyfill.resolve("caml_ml_close_channel")(ic);
  }
  catch (exn){
    return;
  }
}

function print_char(c) {
  Caml_io.caml_ml_output_char(stdout, c);
}

function print_string(s) {
  output_string(stdout, s);
}

function print_bytes(s) {
  output_bytes(stdout, s);
}

function print_int(i) {
  output_string(stdout, Caml_format.caml_format_int("%d", i));
}

function print_float(f) {
  output_string(stdout, valid_float_lexem(Caml_format.caml_format_float("%.12g", f)));
}

function print_endline(s) {
  output_string(stdout, s);
  Caml_io.caml_ml_output_char(stdout, /* '\n' */10);
  Caml_io.caml_ml_flush(stdout);
}

function print_newline(param) {
  Caml_io.caml_ml_output_char(stdout, /* '\n' */10);
  Caml_io.caml_ml_flush(stdout);
}

function prerr_char(c) {
  Caml_io.caml_ml_output_char(stderr, c);
}

function prerr_string(s) {
  output_string(stderr, s);
}

function prerr_bytes(s) {
  output_bytes(stderr, s);
}

function prerr_int(i) {
  output_string(stderr, Caml_format.caml_format_int("%d", i));
}

function prerr_float(f) {
  output_string(stderr, valid_float_lexem(Caml_format.caml_format_float("%.12g", f)));
}

function prerr_endline(s) {
  output_string(stderr, s);
  Caml_io.caml_ml_output_char(stderr, /* '\n' */10);
  Caml_io.caml_ml_flush(stderr);
}

function prerr_newline(param) {
  Caml_io.caml_ml_output_char(stderr, /* '\n' */10);
  Caml_io.caml_ml_flush(stderr);
}

function read_line(param) {
  Caml_io.caml_ml_flush(stdout);
  return input_line(stdin);
}

function read_int(param) {
  return Caml_format.caml_int_of_string((Caml_io.caml_ml_flush(stdout), input_line(stdin)));
}

function read_float(param) {
  return Caml_format.caml_float_of_string((Caml_io.caml_ml_flush(stdout), input_line(stdin)));
}

const LargeFile = {};

function string_of_format(param) {
  return param._1;
}

function $caret$caret(param, param$1) {
  return {
    TAG: /* Format */ 0,
    _0: CamlinternalFormatBasics.concat_fmt(param._0, param$1._0),
    _1: $caret(param._1, $caret("%,", param$1._1))
  };
}

const exit_function = {
  contents: flush_all
};

function at_exit(f) {
  const g = exit_function.contents;
  exit_function.contents = (function (param) {
    Curry._1(f, undefined);
    Curry._1(g, undefined);
  });
}

function do_at_exit(param) {
  Curry._1(exit_function.contents, undefined);
}

function exit(retcode) {
  Curry._1(exit_function.contents, undefined);
  return Caml_sys.caml_sys_exit(retcode);
}

Caml_external_polyfill.resolve("caml_register_named_value")("Pervasives.do_at_exit", do_at_exit);

const max_int = 2147483647;

module.exports = {
  failwith,
  invalid_arg,
  Exit,
  min,
  max,
  abs,
  lnot,
  max_int,
  min_int,
  infinity,
  neg_infinity,
  nan,
  max_float,
  min_float,
  epsilon_float,
  $caret,
  char_of_int,
  string_of_bool,
  bool_of_string,
  string_of_int,
  valid_float_lexem,
  string_of_float,
  $at,
  stdin,
  stdout,
  stderr,
  open_out_gen,
  open_out,
  open_out_bin,
  flush_all,
  output_bytes,
  output_string,
  output,
  output_substring,
  output_value,
  close_out,
  close_out_noerr,
  open_in_gen,
  open_in,
  open_in_bin,
  input,
  unsafe_really_input,
  really_input,
  really_input_string,
  input_line,
  close_in_noerr,
  print_char,
  print_string,
  print_bytes,
  print_int,
  print_float,
  print_endline,
  print_newline,
  prerr_char,
  prerr_string,
  prerr_bytes,
  prerr_int,
  prerr_float,
  prerr_endline,
  prerr_newline,
  read_line,
  read_int,
  read_float,
  LargeFile,
  string_of_format,
  $caret$caret,
  exit_function,
  at_exit,
  do_at_exit,
  exit,
}
/* No side effect */
