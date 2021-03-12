'use strict';

var Seq = require("./seq.js");
var Curry = require("./curry.js");
var Caml_option = require("./caml_option.js");

function ok(v) {
  return {
          TAG: /* Ok */0,
          _0: v
        };
}

function error(e) {
  return {
          TAG: /* Error */1,
          _0: e
        };
}

function value(r, $$default) {
  if (r.TAG === /* Ok */0) {
    return r._0;
  } else {
    return $$default;
  }
}

function get_ok(v) {
  if (v.TAG === /* Ok */0) {
    return v._0;
  }
  throw {
        RE_EXN_ID: "Invalid_argument",
        _1: "result is Error _",
        Error: new Error()
      };
}

function get_error(e) {
  if (e.TAG !== /* Ok */0) {
    return e._0;
  }
  throw {
        RE_EXN_ID: "Invalid_argument",
        _1: "result is Ok _",
        Error: new Error()
      };
}

function bind(r, f) {
  if (r.TAG === /* Ok */0) {
    return Curry._1(f, r._0);
  } else {
    return r;
  }
}

function join(r) {
  if (r.TAG === /* Ok */0) {
    return r._0;
  } else {
    return r;
  }
}

function map(f, v) {
  if (v.TAG === /* Ok */0) {
    return {
            TAG: /* Ok */0,
            _0: Curry._1(f, v._0)
          };
  } else {
    return v;
  }
}

function map_error(f, e) {
  if (e.TAG === /* Ok */0) {
    return e;
  } else {
    return {
            TAG: /* Error */1,
            _0: Curry._1(f, e._0)
          };
  }
}

function fold(ok, error, v) {
  if (v.TAG === /* Ok */0) {
    return Curry._1(ok, v._0);
  } else {
    return Curry._1(error, v._0);
  }
}

function iter(f, v) {
  if (v.TAG === /* Ok */0) {
    return Curry._1(f, v._0);
  }
  
}

function iter_error(f, e) {
  if (e.TAG === /* Ok */0) {
    return ;
  } else {
    return Curry._1(f, e._0);
  }
}

function is_ok(param) {
  if (param.TAG === /* Ok */0) {
    return true;
  } else {
    return false;
  }
}

function is_error(param) {
  if (param.TAG === /* Ok */0) {
    return false;
  } else {
    return true;
  }
}

function equal(ok, error, r0, r1) {
  if (r0.TAG === /* Ok */0) {
    if (r1.TAG === /* Ok */0) {
      return Curry._2(ok, r0._0, r1._0);
    } else {
      return false;
    }
  } else if (r1.TAG === /* Ok */0) {
    return false;
  } else {
    return Curry._2(error, r0._0, r1._0);
  }
}

function compare(ok, error, r0, r1) {
  if (r0.TAG === /* Ok */0) {
    if (r1.TAG === /* Ok */0) {
      return Curry._2(ok, r0._0, r1._0);
    } else {
      return -1;
    }
  } else if (r1.TAG === /* Ok */0) {
    return 1;
  } else {
    return Curry._2(error, r0._0, r1._0);
  }
}

function to_option(v) {
  if (v.TAG === /* Ok */0) {
    return Caml_option.some(v._0);
  }
  
}

function to_list(v) {
  if (v.TAG === /* Ok */0) {
    return {
            hd: v._0,
            tl: /* [] */0
          };
  } else {
    return /* [] */0;
  }
}

function to_seq(v) {
  if (v.TAG !== /* Ok */0) {
    return Seq.empty;
  }
  var partial_arg = v._0;
  return function (param) {
    return Seq.$$return(partial_arg, param);
  };
}

exports.ok = ok;
exports.error = error;
exports.value = value;
exports.get_ok = get_ok;
exports.get_error = get_error;
exports.bind = bind;
exports.join = join;
exports.map = map;
exports.map_error = map_error;
exports.fold = fold;
exports.iter = iter;
exports.iter_error = iter_error;
exports.is_ok = is_ok;
exports.is_error = is_error;
exports.equal = equal;
exports.compare = compare;
exports.to_option = to_option;
exports.to_list = to_list;
exports.to_seq = to_seq;
/* No side effect */
