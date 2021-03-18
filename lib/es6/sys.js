

import * as Caml_sys from "./caml_sys.js";
import * as Caml_exceptions from "./caml_exceptions.js";
import * as Caml_external_polyfill from "./caml_external_polyfill.js";

var os_type = Caml_sys.os_type(undefined);

var backend_type = /* Other */{
  _0: "BS"
};

var big_endian = false;

var unix = Caml_sys.os_type(undefined) === "Unix";

var win32 = Caml_sys.os_type(undefined) === "Win32";

function getenv_opt(s) {
  var x = typeof process === "undefined" ? undefined : process;
  if (x !== undefined) {
    return x.env[s];
  }
  
}

var interactive = {
  contents: false
};

function set_signal(sig_num, sig_beh) {
  
}

var Break = /* @__PURE__ */Caml_exceptions.create("Sys.Break");

function catch_break(on) {
  
}

function Make(Immediate, Non_immediate) {
  var repr = /* Non_immediate */1;
  return {
          repr: repr
        };
}

var Immediate64 = {
  Make: Make
};

var cygwin = false;

var word_size = 32;

var int_size = 32;

var max_string_length = 2147483647;

var max_array_length = 2147483647;

var max_floatarray_length = 2147483647;

var sigabrt = -1;

var sigalrm = -2;

var sigfpe = -3;

var sighup = -4;

var sigill = -5;

var sigint = -6;

var sigkill = -7;

var sigpipe = -8;

var sigquit = -9;

var sigsegv = -10;

var sigterm = -11;

var sigusr1 = -12;

var sigusr2 = -13;

var sigchld = -14;

var sigcont = -15;

var sigstop = -16;

var sigtstp = -17;

var sigttin = -18;

var sigttou = -19;

var sigvtalrm = -20;

var sigprof = -21;

var sigbus = -22;

var sigpoll = -23;

var sigsys = -24;

var sigtrap = -25;

var sigurg = -26;

var sigxcpu = -27;

var sigxfsz = -28;

var ocaml_version = "4.12.0+BS";

function enable_runtime_warnings(prim) {
  return Caml_external_polyfill.resolve("caml_ml_enable_runtime_warnings")(prim);
}

function runtime_warnings_enabled(prim) {
  return Caml_external_polyfill.resolve("caml_ml_runtime_warnings_enabled")(prim);
}

export {
  getenv_opt ,
  interactive ,
  os_type ,
  backend_type ,
  unix ,
  win32 ,
  cygwin ,
  word_size ,
  int_size ,
  big_endian ,
  max_string_length ,
  max_array_length ,
  max_floatarray_length ,
  set_signal ,
  sigabrt ,
  sigalrm ,
  sigfpe ,
  sighup ,
  sigill ,
  sigint ,
  sigkill ,
  sigpipe ,
  sigquit ,
  sigsegv ,
  sigterm ,
  sigusr1 ,
  sigusr2 ,
  sigchld ,
  sigcont ,
  sigstop ,
  sigtstp ,
  sigttin ,
  sigttou ,
  sigvtalrm ,
  sigprof ,
  sigbus ,
  sigpoll ,
  sigsys ,
  sigtrap ,
  sigurg ,
  sigxcpu ,
  sigxfsz ,
  Break ,
  catch_break ,
  ocaml_version ,
  enable_runtime_warnings ,
  runtime_warnings_enabled ,
  Immediate64 ,
  
}
/* No side effect */
