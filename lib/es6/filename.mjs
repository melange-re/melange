

import * as Sys from "./sys.mjs";
import * as List from "./list.mjs";
import * as Bytes from "./bytes.mjs";
import * as Curry from "./curry.mjs";
import * as $$Buffer from "./buffer.mjs";
import * as Printf from "./printf.mjs";
import * as Random from "./random.mjs";
import * as $$String from "./string.mjs";
import * as Caml_obj from "./caml_obj.mjs";
import * as Caml_sys from "./caml_sys.mjs";
import * as Caml_bytes from "./caml_bytes.mjs";
import * as Caml_string from "./caml_string.mjs";
import * as CamlinternalLazy from "./camlinternalLazy.mjs";
import * as Caml_js_exceptions from "./caml_js_exceptions.mjs";
import * as Stdlib__no_aliases from "./stdlib__no_aliases.mjs";
import * as Caml_external_polyfill from "./caml_external_polyfill.mjs";

function generic_quote(quotequote, s) {
  var l = s.length;
  var b = $$Buffer.create(l + 20 | 0);
  $$Buffer.add_char(b, /* '\'' */39);
  for(var i = 0; i < l; ++i){
    if (Caml_string.get(s, i) === /* '\'' */39) {
      $$Buffer.add_string(b, quotequote);
    } else {
      $$Buffer.add_char(b, Caml_string.get(s, i));
    }
  }
  $$Buffer.add_char(b, /* '\'' */39);
  return $$Buffer.contents(b);
}

function generic_basename(is_dir_sep, current_dir_name, name) {
  if (name === "") {
    return current_dir_name;
  } else {
    var _n = name.length - 1 | 0;
    while(true) {
      var n = _n;
      if (n < 0) {
        return $$String.sub(name, 0, 1);
      }
      if (!Curry._2(is_dir_sep, name, n)) {
        var _n$1 = n;
        var p = n + 1 | 0;
        while(true) {
          var n$1 = _n$1;
          if (n$1 < 0) {
            return $$String.sub(name, 0, p);
          }
          if (Curry._2(is_dir_sep, name, n$1)) {
            return $$String.sub(name, n$1 + 1 | 0, (p - n$1 | 0) - 1 | 0);
          }
          _n$1 = n$1 - 1 | 0;
          continue ;
        };
      }
      _n = n - 1 | 0;
      continue ;
    };
  }
}

function generic_dirname(is_dir_sep, current_dir_name, name) {
  if (name === "") {
    return current_dir_name;
  } else {
    var _n = name.length - 1 | 0;
    while(true) {
      var n = _n;
      if (n < 0) {
        return $$String.sub(name, 0, 1);
      }
      if (!Curry._2(is_dir_sep, name, n)) {
        var _n$1 = n;
        while(true) {
          var n$1 = _n$1;
          if (n$1 < 0) {
            return current_dir_name;
          }
          if (Curry._2(is_dir_sep, name, n$1)) {
            var _n$2 = n$1;
            while(true) {
              var n$2 = _n$2;
              if (n$2 < 0) {
                return $$String.sub(name, 0, 1);
              }
              if (!Curry._2(is_dir_sep, name, n$2)) {
                return $$String.sub(name, 0, n$2 + 1 | 0);
              }
              _n$2 = n$2 - 1 | 0;
              continue ;
            };
          }
          _n$1 = n$1 - 1 | 0;
          continue ;
        };
      }
      _n = n - 1 | 0;
      continue ;
    };
  }
}

var current_dir_name = ".";

function is_dir_sep(s, i) {
  return Caml_string.get(s, i) === /* '/' */47;
}

function is_relative(n) {
  if (n.length < 1) {
    return true;
  } else {
    return Caml_string.get(n, 0) !== /* '/' */47;
  }
}

function is_implicit(n) {
  if (is_relative(n) && (n.length < 2 || $$String.sub(n, 0, 2) !== "./")) {
    if (n.length < 3) {
      return true;
    } else {
      return $$String.sub(n, 0, 3) !== "../";
    }
  } else {
    return false;
  }
}

function check_suffix(name, suff) {
  if (name.length >= suff.length) {
    return $$String.sub(name, name.length - suff.length | 0, suff.length) === suff;
  } else {
    return false;
  }
}

function chop_suffix_opt(suffix, filename) {
  var len_s = suffix.length;
  var len_f = filename.length;
  if (len_f < len_s) {
    return ;
  }
  var r = $$String.sub(filename, len_f - len_s | 0, len_s);
  if (r === suffix) {
    return $$String.sub(filename, 0, len_f - len_s | 0);
  }
  
}

var temp_dir_name;

try {
  temp_dir_name = Caml_sys.caml_sys_getenv("TMPDIR");
}
catch (raw_exn){
  var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
  if (exn.RE_EXN_ID === Stdlib__no_aliases.Not_found) {
    temp_dir_name = "/tmp";
  } else {
    throw exn;
  }
}

function quote(param) {
  return generic_quote("'\\''", param);
}

function quote_command(cmd, stdin, stdout, stderr, args) {
  return $$String.concat(" ", List.map(quote, {
                  hd: cmd,
                  tl: args
                })) + ((
            stdin !== undefined ? " <" + generic_quote("'\\''", stdin) : ""
          ) + ((
              stdout !== undefined ? " >" + generic_quote("'\\''", stdout) : ""
            ) + (
              stderr !== undefined ? (
                  Caml_obj.caml_equal(stderr, stdout) ? " 2>&1" : " 2>" + generic_quote("'\\''", stderr)
                ) : ""
            )));
}

function basename(param) {
  return generic_basename(is_dir_sep, current_dir_name, param);
}

function dirname(param) {
  return generic_dirname(is_dir_sep, current_dir_name, param);
}

var Unix = {
  $$null: "/dev/null",
  current_dir_name: current_dir_name,
  parent_dir_name: "..",
  dir_sep: "/",
  is_dir_sep: is_dir_sep,
  is_relative: is_relative,
  is_implicit: is_implicit,
  check_suffix: check_suffix,
  chop_suffix_opt: chop_suffix_opt,
  temp_dir_name: temp_dir_name,
  quote: quote,
  quote_command: quote_command,
  basename: basename,
  dirname: dirname
};

var current_dir_name$1 = ".";

function is_dir_sep$1(s, i) {
  var c = Caml_string.get(s, i);
  if (c === /* '/' */47 || c === /* '\\' */92) {
    return true;
  } else {
    return c === /* ':' */58;
  }
}

function is_relative$1(n) {
  if ((n.length < 1 || Caml_string.get(n, 0) !== /* '/' */47) && (n.length < 1 || Caml_string.get(n, 0) !== /* '\\' */92)) {
    if (n.length < 2) {
      return true;
    } else {
      return Caml_string.get(n, 1) !== /* ':' */58;
    }
  } else {
    return false;
  }
}

function is_implicit$1(n) {
  if (is_relative$1(n) && (n.length < 2 || $$String.sub(n, 0, 2) !== "./") && (n.length < 2 || $$String.sub(n, 0, 2) !== ".\\") && (n.length < 3 || $$String.sub(n, 0, 3) !== "../")) {
    if (n.length < 3) {
      return true;
    } else {
      return $$String.sub(n, 0, 3) !== "..\\";
    }
  } else {
    return false;
  }
}

function check_suffix$1(name, suff) {
  if (name.length < suff.length) {
    return false;
  }
  var s = $$String.sub(name, name.length - suff.length | 0, suff.length);
  return Caml_bytes.bytes_to_string(Bytes.lowercase_ascii(Caml_bytes.bytes_of_string(s))) === Caml_bytes.bytes_to_string(Bytes.lowercase_ascii(Caml_bytes.bytes_of_string(suff)));
}

function chop_suffix_opt$1(suffix, filename) {
  var len_s = suffix.length;
  var len_f = filename.length;
  if (len_f < len_s) {
    return ;
  }
  var r = $$String.sub(filename, len_f - len_s | 0, len_s);
  if (Caml_bytes.bytes_to_string(Bytes.lowercase_ascii(Caml_bytes.bytes_of_string(r))) === Caml_bytes.bytes_to_string(Bytes.lowercase_ascii(Caml_bytes.bytes_of_string(suffix)))) {
    return $$String.sub(filename, 0, len_f - len_s | 0);
  }
  
}

var temp_dir_name$1;

try {
  temp_dir_name$1 = Caml_sys.caml_sys_getenv("TEMP");
}
catch (raw_exn$1){
  var exn$1 = Caml_js_exceptions.internalToOCamlException(raw_exn$1);
  if (exn$1.RE_EXN_ID === Stdlib__no_aliases.Not_found) {
    temp_dir_name$1 = ".";
  } else {
    throw exn$1;
  }
}

function quote$1(s) {
  var l = s.length;
  var b = $$Buffer.create(l + 20 | 0);
  $$Buffer.add_char(b, /* '"' */34);
  var loop = function (_i) {
    while(true) {
      var i = _i;
      if (i === l) {
        return $$Buffer.add_char(b, /* '"' */34);
      }
      var c = Caml_string.get(s, i);
      if (c === 34) {
        return loop_bs(0, i);
      }
      if (c === 92) {
        return loop_bs(0, i);
      }
      $$Buffer.add_char(b, c);
      _i = i + 1 | 0;
      continue ;
    };
  };
  var loop_bs = function (_n, _i) {
    while(true) {
      var i = _i;
      var n = _n;
      if (i === l) {
        $$Buffer.add_char(b, /* '"' */34);
        return add_bs(n);
      }
      var match = Caml_string.get(s, i);
      if (match !== 34) {
        if (match !== 92) {
          add_bs(n);
          return loop(i);
        }
        _i = i + 1 | 0;
        _n = n + 1 | 0;
        continue ;
      }
      add_bs((n << 1) + 1 | 0);
      $$Buffer.add_char(b, /* '"' */34);
      return loop(i + 1 | 0);
    };
  };
  var add_bs = function (n) {
    for(var _j = 1; _j <= n; ++_j){
      $$Buffer.add_char(b, /* '\\' */92);
    }
    
  };
  loop(0);
  return $$Buffer.contents(b);
}

function quote_cmd(s) {
  var b = $$Buffer.create(s.length + 20 | 0);
  $$String.iter((function (c) {
          if (c >= 62) {
            if (c > 123 || c < 63) {
              if (c >= 125) {
                return $$Buffer.add_char(b, c);
              }
              
            } else if (c !== 94) {
              return $$Buffer.add_char(b, c);
            }
            
          } else if (c >= 42) {
            if (c !== 60) {
              return $$Buffer.add_char(b, c);
            }
            
          } else {
            if (c < 33) {
              return $$Buffer.add_char(b, c);
            }
            switch (c) {
              case 35 :
              case 36 :
              case 39 :
                  return $$Buffer.add_char(b, c);
              case 33 :
              case 34 :
              case 37 :
              case 38 :
              case 40 :
              case 41 :
                  break;
              
            }
          }
          $$Buffer.add_char(b, /* '^' */94);
          return $$Buffer.add_char(b, c);
        }), s);
  return $$Buffer.contents(b);
}

function quote_cmd_filename(f) {
  if (!($$String.contains(f, /* '"' */34) || $$String.contains(f, /* '%' */37))) {
    if ($$String.contains(f, /* ' ' */32)) {
      return "\"" + (f + "\"");
    } else {
      return f;
    }
  }
  var s = "Filename.quote_command: bad file name " + f;
  throw {
        RE_EXN_ID: "Failure",
        _1: s,
        Error: new Error()
      };
}

function quote_command$1(cmd, stdin, stdout, stderr, args) {
  return $$String.concat("", {
              hd: "\"",
              tl: {
                hd: quote_cmd_filename(cmd),
                tl: {
                  hd: " ",
                  tl: {
                    hd: quote_cmd($$String.concat(" ", List.map(quote$1, args))),
                    tl: {
                      hd: stdin !== undefined ? " <" + quote_cmd_filename(stdin) : "",
                      tl: {
                        hd: stdout !== undefined ? " >" + quote_cmd_filename(stdout) : "",
                        tl: {
                          hd: stderr !== undefined ? (
                              Caml_obj.caml_equal(stderr, stdout) ? " 2>&1" : " 2>" + quote_cmd_filename(stderr)
                            ) : "",
                          tl: {
                            hd: "\"",
                            tl: /* [] */0
                          }
                        }
                      }
                    }
                  }
                }
              }
            });
}

function has_drive(s) {
  var is_letter = function (param) {
    if (param >= 91) {
      return !(param > 122 || param < 97);
    } else {
      return param >= 65;
    }
  };
  if (s.length >= 2 && is_letter(Caml_string.get(s, 0))) {
    return Caml_string.get(s, 1) === /* ':' */58;
  } else {
    return false;
  }
}

function drive_and_path(s) {
  if (has_drive(s)) {
    return [
            $$String.sub(s, 0, 2),
            $$String.sub(s, 2, s.length - 2 | 0)
          ];
  } else {
    return [
            "",
            s
          ];
  }
}

function dirname$1(s) {
  var match = drive_and_path(s);
  var dir = generic_dirname(is_dir_sep$1, current_dir_name$1, match[1]);
  return match[0] + dir;
}

function basename$1(s) {
  var match = drive_and_path(s);
  return generic_basename(is_dir_sep$1, current_dir_name$1, match[1]);
}

var Win32 = {
  $$null: "NUL",
  current_dir_name: current_dir_name$1,
  parent_dir_name: "..",
  dir_sep: "\\",
  is_dir_sep: is_dir_sep$1,
  is_relative: is_relative$1,
  is_implicit: is_implicit$1,
  check_suffix: check_suffix$1,
  chop_suffix_opt: chop_suffix_opt$1,
  temp_dir_name: temp_dir_name$1,
  quote: quote$1,
  quote_command: quote_command$1,
  basename: basename$1,
  dirname: dirname$1
};

var current_dir_name$2 = ".";

function basename$2(param) {
  return generic_basename(is_dir_sep$1, current_dir_name$2, param);
}

function dirname$2(param) {
  return generic_dirname(is_dir_sep$1, current_dir_name$2, param);
}

var Cygwin = {
  $$null: "/dev/null",
  current_dir_name: current_dir_name$2,
  parent_dir_name: "..",
  dir_sep: "/",
  is_dir_sep: is_dir_sep$1,
  is_relative: is_relative$1,
  is_implicit: is_implicit$1,
  check_suffix: check_suffix$1,
  chop_suffix_opt: chop_suffix_opt$1,
  temp_dir_name: temp_dir_name,
  quote: quote,
  quote_command: quote_command,
  basename: basename$2,
  dirname: dirname$2
};

var Sysdeps;

switch (Sys.os_type) {
  case "Cygwin" :
      Sysdeps = Cygwin;
      break;
  case "Win32" :
      Sysdeps = Win32;
      break;
  default:
    Sysdeps = Unix;
}

var dir_sep = Sysdeps.dir_sep;

var is_dir_sep$2 = Sysdeps.is_dir_sep;

var temp_dir_name$2 = Sysdeps.temp_dir_name;

function concat(dirname, filename) {
  var l = dirname.length;
  if (l === 0 || Curry._2(is_dir_sep$2, dirname, l - 1 | 0)) {
    return dirname + filename;
  } else {
    return dirname + (dir_sep + filename);
  }
}

function chop_suffix(name, suff) {
  var n = name.length - suff.length | 0;
  if (n < 0) {
    throw {
          RE_EXN_ID: "Invalid_argument",
          _1: "Filename.chop_suffix",
          Error: new Error()
        };
  }
  return $$String.sub(name, 0, n);
}

function extension_len(name) {
  var _i = name.length - 1 | 0;
  while(true) {
    var i = _i;
    if (i < 0 || Curry._2(is_dir_sep$2, name, i)) {
      return 0;
    }
    if (Caml_string.get(name, i) === /* '.' */46) {
      var _i$1 = i - 1 | 0;
      while(true) {
        var i$1 = _i$1;
        if (i$1 < 0 || Curry._2(is_dir_sep$2, name, i$1)) {
          return 0;
        }
        if (Caml_string.get(name, i$1) !== /* '.' */46) {
          return name.length - i | 0;
        }
        _i$1 = i$1 - 1 | 0;
        continue ;
      };
    }
    _i = i - 1 | 0;
    continue ;
  };
}

function extension(name) {
  var l = extension_len(name);
  if (l === 0) {
    return "";
  } else {
    return $$String.sub(name, name.length - l | 0, l);
  }
}

function chop_extension(name) {
  var l = extension_len(name);
  if (l === 0) {
    throw {
          RE_EXN_ID: "Invalid_argument",
          _1: "Filename.chop_extension",
          Error: new Error()
        };
  }
  return $$String.sub(name, 0, name.length - l | 0);
}

function remove_extension(name) {
  var l = extension_len(name);
  if (l === 0) {
    return name;
  } else {
    return $$String.sub(name, 0, name.length - l | 0);
  }
}

var prng = {
  LAZY_DONE: false,
  VAL: (function () {
      return Random.State.make_self_init(undefined);
    })
};

function temp_file_name(temp_dir, prefix, suffix) {
  var rnd = Random.State.bits(CamlinternalLazy.force(prng)) & 16777215;
  return concat(temp_dir, Curry._3(Printf.sprintf(/* Format */{
                      _0: {
                        TAG: /* String */2,
                        _0: /* No_padding */0,
                        _1: {
                          TAG: /* Int */4,
                          _0: /* Int_x */6,
                          _1: {
                            TAG: /* Lit_padding */0,
                            _0: /* Zeros */2,
                            _1: 6
                          },
                          _2: /* No_precision */0,
                          _3: {
                            TAG: /* String */2,
                            _0: /* No_padding */0,
                            _1: /* End_of_format */0
                          }
                        }
                      },
                      _1: "%s%06x%s"
                    }), prefix, rnd, suffix));
}

var current_temp_dir_name = {
  contents: temp_dir_name$2
};

function set_temp_dir_name(s) {
  current_temp_dir_name[0] = s;
  
}

function get_temp_dir_name(param) {
  return current_temp_dir_name[0];
}

function temp_file(temp_dirOpt, prefix, suffix) {
  var temp_dir = temp_dirOpt !== undefined ? temp_dirOpt : current_temp_dir_name[0];
  var _counter = 0;
  while(true) {
    var counter = _counter;
    var name = temp_file_name(temp_dir, prefix, suffix);
    try {
      Caml_external_polyfill.resolve("caml_sys_close")(Caml_external_polyfill.resolve("caml_sys_open")(name, {
                hd: /* Open_wronly */1,
                tl: {
                  hd: /* Open_creat */3,
                  tl: {
                    hd: /* Open_excl */5,
                    tl: /* [] */0
                  }
                }
              }, 384));
      return name;
    }
    catch (raw_e){
      var e = Caml_js_exceptions.internalToOCamlException(raw_e);
      if (e.RE_EXN_ID === Stdlib__no_aliases.Sys_error) {
        if (counter >= 1000) {
          throw e;
        }
        _counter = counter + 1 | 0;
        continue ;
      }
      throw e;
    }
  };
}

function open_temp_file(modeOpt, permsOpt, temp_dirOpt, prefix, suffix) {
  var mode = modeOpt !== undefined ? modeOpt : ({
        hd: /* Open_text */7,
        tl: /* [] */0
      });
  var perms = permsOpt !== undefined ? permsOpt : 384;
  var temp_dir = temp_dirOpt !== undefined ? temp_dirOpt : current_temp_dir_name[0];
  var _counter = 0;
  while(true) {
    var counter = _counter;
    var name = temp_file_name(temp_dir, prefix, suffix);
    try {
      return [
              name,
              Stdlib__no_aliases.open_out_gen({
                    hd: /* Open_wronly */1,
                    tl: {
                      hd: /* Open_creat */3,
                      tl: {
                        hd: /* Open_excl */5,
                        tl: mode
                      }
                    }
                  }, perms, name)
            ];
    }
    catch (raw_e){
      var e = Caml_js_exceptions.internalToOCamlException(raw_e);
      if (e.RE_EXN_ID === Stdlib__no_aliases.Sys_error) {
        if (counter >= 1000) {
          throw e;
        }
        _counter = counter + 1 | 0;
        continue ;
      }
      throw e;
    }
  };
}

var current_dir_name$3 = Sysdeps.current_dir_name;

var parent_dir_name = Sysdeps.parent_dir_name;

var is_relative$2 = Sysdeps.is_relative;

var is_implicit$2 = Sysdeps.is_implicit;

var check_suffix$2 = Sysdeps.check_suffix;

var chop_suffix_opt$2 = Sysdeps.chop_suffix_opt;

var basename$3 = Sysdeps.basename;

var dirname$3 = Sysdeps.dirname;

var $$null = Sysdeps.$$null;

var quote$2 = Sysdeps.quote;

var quote_command$2 = Sysdeps.quote_command;

export {
  current_dir_name$3 as current_dir_name,
  parent_dir_name ,
  dir_sep ,
  concat ,
  is_relative$2 as is_relative,
  is_implicit$2 as is_implicit,
  check_suffix$2 as check_suffix,
  chop_suffix ,
  chop_suffix_opt$2 as chop_suffix_opt,
  extension ,
  remove_extension ,
  chop_extension ,
  basename$3 as basename,
  dirname$3 as dirname,
  $$null ,
  temp_file ,
  open_temp_file ,
  get_temp_dir_name ,
  set_temp_dir_name ,
  temp_dir_name$2 as temp_dir_name,
  quote$2 as quote,
  quote_command$2 as quote_command,
  
}
/* temp_dir_name Not a pure module */
