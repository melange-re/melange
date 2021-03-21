

import * as Seq from "./seq.js";
import * as Caml from "./caml.js";
import * as List from "./list.js";
import * as Curry from "./curry.js";
import * as Caml_hash from "./caml_hash.js";
import * as Caml_array from "./caml_array.js";
import * as Caml_exceptions from "./caml_exceptions.js";
import * as Caml_js_exceptions from "./caml_js_exceptions.js";
import * as Stdlib__no_aliases from "./stdlib__no_aliases.js";
import * as Caml_external_polyfill from "./caml_external_polyfill.js";

var infinity = Stdlib__no_aliases.Stdlib.infinity;

var neg_infinity = Stdlib__no_aliases.Stdlib.neg_infinity;

var nan = Number.NaN;

function is_finite(x) {
  return x - x === 0;
}

function is_infinite(x) {
  return 1 / x === 0;
}

function is_nan(x) {
  return x !== x;
}

var max_float = Stdlib__no_aliases.Stdlib.max_float;

var min_float = Stdlib__no_aliases.Stdlib.min_float;

var epsilon = Stdlib__no_aliases.Stdlib.epsilon_float;

var of_string_opt = Stdlib__no_aliases.Stdlib.float_of_string_opt;

var to_string = Stdlib__no_aliases.Stdlib.string_of_float;

function is_integer(x) {
  if (x === Caml_external_polyfill.resolve("caml_trunc_float")(x)) {
    return is_finite(x);
  } else {
    return false;
  }
}

function succ(x) {
  return Caml_external_polyfill.resolve("caml_nextafter_float")(x, infinity);
}

function pred(x) {
  return Caml_external_polyfill.resolve("caml_nextafter_float")(x, neg_infinity);
}

function equal(x, y) {
  return Caml.caml_float_compare(x, y) === 0;
}

function min(x, y) {
  if (y > x || !Caml_external_polyfill.resolve("caml_signbit_float")(y) && Caml_external_polyfill.resolve("caml_signbit_float")(x)) {
    if (y !== y) {
      return y;
    } else {
      return x;
    }
  } else if (x !== x) {
    return x;
  } else {
    return y;
  }
}

function max(x, y) {
  if (y > x || !Caml_external_polyfill.resolve("caml_signbit_float")(y) && Caml_external_polyfill.resolve("caml_signbit_float")(x)) {
    if (x !== x) {
      return x;
    } else {
      return y;
    }
  } else if (y !== y) {
    return y;
  } else {
    return x;
  }
}

function min_max(x, y) {
  if (x !== x || y !== y) {
    return [
            nan,
            nan
          ];
  } else if (y > x || !Caml_external_polyfill.resolve("caml_signbit_float")(y) && Caml_external_polyfill.resolve("caml_signbit_float")(x)) {
    return [
            x,
            y
          ];
  } else {
    return [
            y,
            x
          ];
  }
}

function min_num(x, y) {
  if (y > x || !Caml_external_polyfill.resolve("caml_signbit_float")(y) && Caml_external_polyfill.resolve("caml_signbit_float")(x)) {
    if (x !== x) {
      return y;
    } else {
      return x;
    }
  } else if (y !== y) {
    return x;
  } else {
    return y;
  }
}

function max_num(x, y) {
  if (y > x || !Caml_external_polyfill.resolve("caml_signbit_float")(y) && Caml_external_polyfill.resolve("caml_signbit_float")(x)) {
    if (y !== y) {
      return x;
    } else {
      return y;
    }
  } else if (x !== x) {
    return y;
  } else {
    return x;
  }
}

function min_max_num(x, y) {
  if (x !== x) {
    return [
            y,
            y
          ];
  } else if (y !== y) {
    return [
            x,
            x
          ];
  } else if (y > x || !Caml_external_polyfill.resolve("caml_signbit_float")(y) && Caml_external_polyfill.resolve("caml_signbit_float")(x)) {
    return [
            x,
            y
          ];
  } else {
    return [
            y,
            x
          ];
  }
}

function hash(x) {
  return Caml_hash.caml_hash(10, 100, 0, x);
}

function unsafe_fill(a, ofs, len, v) {
  for(var i = ofs ,i_finish = ofs + len | 0; i < i_finish; ++i){
    a[i] = v;
  }
  
}

function check(a, ofs, len, msg) {
  if (!(ofs < 0 || len < 0 || (ofs + len | 0) < 0 || (ofs + len | 0) > a.length)) {
    return ;
  }
  throw {
        RE_EXN_ID: "Invalid_argument",
        _1: msg,
        Error: new Error()
      };
}

function make(n, v) {
  var result = Caml_array.make_float(n);
  unsafe_fill(result, 0, n, v);
  return result;
}

function init(l, f) {
  if (l < 0) {
    throw {
          RE_EXN_ID: "Invalid_argument",
          _1: "Float.Array.init",
          Error: new Error()
        };
  }
  var res = Caml_array.make_float(l);
  for(var i = 0; i < l; ++i){
    res[i] = Curry._1(f, i);
  }
  return res;
}

function append(a1, a2) {
  var l1 = a1.length;
  var l2 = a2.length;
  var result = Caml_array.make_float(l1 + l2 | 0);
  Caml_external_polyfill.resolve("caml_floatarray_blit")(a1, 0, result, 0, l1);
  Caml_external_polyfill.resolve("caml_floatarray_blit")(a2, 0, result, l1, l2);
  return result;
}

function ensure_ge(x, y) {
  if (x >= y) {
    return x;
  }
  throw {
        RE_EXN_ID: "Invalid_argument",
        _1: "Float.Array.concat",
        Error: new Error()
      };
}

function sum_lengths(_acc, _param) {
  while(true) {
    var param = _param;
    var acc = _acc;
    if (!param) {
      return acc;
    }
    _param = param.tl;
    _acc = ensure_ge(param.hd.length + acc | 0, acc);
    continue ;
  };
}

function concat(l) {
  var len = sum_lengths(0, l);
  var result = Caml_array.make_float(len);
  var loop = function (_l, _i) {
    while(true) {
      var i = _i;
      var l = _l;
      if (l) {
        var hd = l.hd;
        var hlen = hd.length;
        Caml_external_polyfill.resolve("caml_floatarray_blit")(hd, 0, result, i, hlen);
        _i = i + hlen | 0;
        _l = l.tl;
        continue ;
      }
      if (i === len) {
        return ;
      }
      throw {
            RE_EXN_ID: "Assert_failure",
            _1: [
              "float.ml",
              206,
              14
            ],
            Error: new Error()
          };
    };
  };
  loop(l, 0);
  return result;
}

function sub(a, ofs, len) {
  check(a, ofs, len, "Float.Array.sub");
  var result = Caml_array.make_float(len);
  Caml_external_polyfill.resolve("caml_floatarray_blit")(a, ofs, result, 0, len);
  return result;
}

function copy(a) {
  var l = a.length;
  var result = Caml_array.make_float(l);
  Caml_external_polyfill.resolve("caml_floatarray_blit")(a, 0, result, 0, l);
  return result;
}

function fill(a, ofs, len, v) {
  check(a, ofs, len, "Float.Array.fill");
  return unsafe_fill(a, ofs, len, v);
}

function blit(src, sofs, dst, dofs, len) {
  check(src, sofs, len, "Float.array.blit");
  check(dst, dofs, len, "Float.array.blit");
  return Caml_external_polyfill.resolve("caml_floatarray_blit")(src, sofs, dst, dofs, len);
}

function to_list(a) {
  return List.init(a.length, (function (param) {
                return a[param];
              }));
}

function of_list(l) {
  var result = Caml_array.make_float(List.length(l));
  var _i = 0;
  var _l = l;
  while(true) {
    var l$1 = _l;
    var i = _i;
    if (!l$1) {
      return result;
    }
    result[i] = l$1.hd;
    _l = l$1.tl;
    _i = i + 1 | 0;
    continue ;
  };
}

function iter(f, a) {
  for(var i = 0 ,i_finish = a.length; i < i_finish; ++i){
    Curry._1(f, a[i]);
  }
  
}

function iter2(f, a, b) {
  if (a.length !== b.length) {
    throw {
          RE_EXN_ID: "Invalid_argument",
          _1: "Float.Array.iter2: arrays must have the same length",
          Error: new Error()
        };
  }
  for(var i = 0 ,i_finish = a.length; i < i_finish; ++i){
    Curry._2(f, a[i], b[i]);
  }
  
}

function map(f, a) {
  var l = a.length;
  var r = Caml_array.make_float(l);
  for(var i = 0; i < l; ++i){
    r[i] = Curry._1(f, a[i]);
  }
  return r;
}

function map2(f, a, b) {
  var la = a.length;
  var lb = b.length;
  if (la !== lb) {
    throw {
          RE_EXN_ID: "Invalid_argument",
          _1: "Float.Array.map2: arrays must have the same length",
          Error: new Error()
        };
  }
  var r = Caml_array.make_float(la);
  for(var i = 0; i < la; ++i){
    r[i] = Curry._2(f, a[i], b[i]);
  }
  return r;
}

function iteri(f, a) {
  for(var i = 0 ,i_finish = a.length; i < i_finish; ++i){
    Curry._2(f, i, a[i]);
  }
  
}

function mapi(f, a) {
  var l = a.length;
  var r = Caml_array.make_float(l);
  for(var i = 0; i < l; ++i){
    r[i] = Curry._2(f, i, a[i]);
  }
  return r;
}

function fold_left(f, x, a) {
  var r = x;
  for(var i = 0 ,i_finish = a.length; i < i_finish; ++i){
    r = Curry._2(f, r, a[i]);
  }
  return r;
}

function fold_right(f, a, x) {
  var r = x;
  for(var i = a.length - 1 | 0; i >= 0; --i){
    r = Curry._2(f, a[i], r);
  }
  return r;
}

function exists(p, a) {
  var n = a.length;
  var _i = 0;
  while(true) {
    var i = _i;
    if (i === n) {
      return false;
    }
    if (Curry._1(p, a[i])) {
      return true;
    }
    _i = i + 1 | 0;
    continue ;
  };
}

function for_all(p, a) {
  var n = a.length;
  var _i = 0;
  while(true) {
    var i = _i;
    if (i === n) {
      return true;
    }
    if (!Curry._1(p, a[i])) {
      return false;
    }
    _i = i + 1 | 0;
    continue ;
  };
}

function mem(x, a) {
  var n = a.length;
  var _i = 0;
  while(true) {
    var i = _i;
    if (i === n) {
      return false;
    }
    if (Caml.caml_float_compare(a[i], x) === 0) {
      return true;
    }
    _i = i + 1 | 0;
    continue ;
  };
}

function mem_ieee(x, a) {
  var n = a.length;
  var _i = 0;
  while(true) {
    var i = _i;
    if (i === n) {
      return false;
    }
    if (x === a[i]) {
      return true;
    }
    _i = i + 1 | 0;
    continue ;
  };
}

var Bottom = /* @__PURE__ */Caml_exceptions.create("Float.Array.Bottom");

function sort(cmp, a) {
  var maxson = function (l, i) {
    var i31 = ((i + i | 0) + i | 0) + 1 | 0;
    var x = i31;
    if ((i31 + 2 | 0) < l) {
      if (Curry._2(cmp, Caml_array.get(a, i31), Caml_array.get(a, i31 + 1 | 0)) < 0) {
        x = i31 + 1 | 0;
      }
      if (Curry._2(cmp, Caml_array.get(a, x), Caml_array.get(a, i31 + 2 | 0)) < 0) {
        x = i31 + 2 | 0;
      }
      return x;
    }
    if ((i31 + 1 | 0) < l && Curry._2(cmp, Caml_array.get(a, i31), Caml_array.get(a, i31 + 1 | 0)) < 0) {
      return i31 + 1 | 0;
    }
    if (i31 < l) {
      return i31;
    }
    throw {
          RE_EXN_ID: Bottom,
          _1: i,
          Error: new Error()
        };
  };
  var trickle = function (l, i, e) {
    try {
      var _i = i;
      while(true) {
        var i$1 = _i;
        var j = maxson(l, i$1);
        if (Curry._2(cmp, Caml_array.get(a, j), e) <= 0) {
          return Caml_array.set(a, i$1, e);
        }
        Caml_array.set(a, i$1, Caml_array.get(a, j));
        _i = j;
        continue ;
      };
    }
    catch (raw_i){
      var i$2 = Caml_js_exceptions.internalToOCamlException(raw_i);
      if (i$2.RE_EXN_ID === Bottom) {
        return Caml_array.set(a, i$2._1, e);
      }
      throw i$2;
    }
  };
  var bubble = function (l, i) {
    try {
      var _i = i;
      while(true) {
        var i$1 = _i;
        var j = maxson(l, i$1);
        Caml_array.set(a, i$1, Caml_array.get(a, j));
        _i = j;
        continue ;
      };
    }
    catch (raw_i){
      var i$2 = Caml_js_exceptions.internalToOCamlException(raw_i);
      if (i$2.RE_EXN_ID === Bottom) {
        return i$2._1;
      }
      throw i$2;
    }
  };
  var trickleup = function (_i, e) {
    while(true) {
      var i = _i;
      var father = (i - 1 | 0) / 3 | 0;
      if (i === father) {
        throw {
              RE_EXN_ID: "Assert_failure",
              _1: [
                "float.ml",
                379,
                6
              ],
              Error: new Error()
            };
      }
      if (Curry._2(cmp, Caml_array.get(a, father), e) >= 0) {
        return Caml_array.set(a, i, e);
      }
      Caml_array.set(a, i, Caml_array.get(a, father));
      if (father <= 0) {
        return Caml_array.set(a, 0, e);
      }
      _i = father;
      continue ;
    };
  };
  var l = a.length;
  for(var i = ((l + 1 | 0) / 3 | 0) - 1 | 0; i >= 0; --i){
    trickle(l, i, Caml_array.get(a, i));
  }
  for(var i$1 = l - 1 | 0; i$1 >= 2; --i$1){
    var e = Caml_array.get(a, i$1);
    Caml_array.set(a, i$1, Caml_array.get(a, 0));
    trickleup(bubble(i$1, 0), e);
  }
  if (l <= 1) {
    return ;
  }
  var e$1 = Caml_array.get(a, 1);
  Caml_array.set(a, 1, Caml_array.get(a, 0));
  return Caml_array.set(a, 0, e$1);
}

function stable_sort(cmp, a) {
  var merge = function (src1ofs, src1len, src2, src2ofs, src2len, dst, dstofs) {
    var src1r = src1ofs + src1len | 0;
    var src2r = src2ofs + src2len | 0;
    var _i1 = src1ofs;
    var _s1 = Caml_array.get(a, src1ofs);
    var _i2 = src2ofs;
    var _s2 = Caml_array.get(src2, src2ofs);
    var _d = dstofs;
    while(true) {
      var d = _d;
      var s2 = _s2;
      var i2 = _i2;
      var s1 = _s1;
      var i1 = _i1;
      if (Curry._2(cmp, s1, s2) <= 0) {
        Caml_array.set(dst, d, s1);
        var i1$1 = i1 + 1 | 0;
        if (i1$1 >= src1r) {
          return blit(src2, i2, dst, d + 1 | 0, src2r - i2 | 0);
        }
        _d = d + 1 | 0;
        _s1 = Caml_array.get(a, i1$1);
        _i1 = i1$1;
        continue ;
      }
      Caml_array.set(dst, d, s2);
      var i2$1 = i2 + 1 | 0;
      if (i2$1 >= src2r) {
        return blit(a, i1, dst, d + 1 | 0, src1r - i1 | 0);
      }
      _d = d + 1 | 0;
      _s2 = Caml_array.get(src2, i2$1);
      _i2 = i2$1;
      continue ;
    };
  };
  var isortto = function (srcofs, dst, dstofs, len) {
    for(var i = 0; i < len; ++i){
      var e = Caml_array.get(a, srcofs + i | 0);
      var j = (dstofs + i | 0) - 1 | 0;
      while(j >= dstofs && Curry._2(cmp, Caml_array.get(dst, j), e) > 0) {
        Caml_array.set(dst, j + 1 | 0, Caml_array.get(dst, j));
        j = j - 1 | 0;
      };
      Caml_array.set(dst, j + 1 | 0, e);
    }
    
  };
  var sortto = function (srcofs, dst, dstofs, len) {
    if (len <= 5) {
      return isortto(srcofs, dst, dstofs, len);
    }
    var l1 = len / 2 | 0;
    var l2 = len - l1 | 0;
    sortto(srcofs + l1 | 0, dst, dstofs + l1 | 0, l2);
    sortto(srcofs, a, srcofs + l2 | 0, l1);
    return merge(srcofs + l2 | 0, l1, dst, dstofs + l1 | 0, l2, dst, dstofs);
  };
  var l = a.length;
  if (l <= 5) {
    return isortto(0, a, 0, l);
  }
  var l1 = l / 2 | 0;
  var l2 = l - l1 | 0;
  var t = Caml_array.make_float(l2);
  sortto(l1, t, 0, l2);
  sortto(0, a, l2, l1);
  return merge(l2, l1, t, 0, l2, a, 0);
}

function to_seq(a) {
  var aux = function (i, param) {
    if (i >= a.length) {
      return /* Nil */0;
    }
    var x = a[i];
    var partial_arg = i + 1 | 0;
    return /* Cons */{
            _0: x,
            _1: (function (param) {
                return aux(partial_arg, param);
              })
          };
  };
  return function (param) {
    return aux(0, param);
  };
}

function to_seqi(a) {
  var aux = function (i, param) {
    if (i >= a.length) {
      return /* Nil */0;
    }
    var x = a[i];
    var partial_arg = i + 1 | 0;
    return /* Cons */{
            _0: [
              i,
              x
            ],
            _1: (function (param) {
                return aux(partial_arg, param);
              })
          };
  };
  return function (param) {
    return aux(0, param);
  };
}

function of_seq(i) {
  var l = Seq.fold_left((function (acc, x) {
          return {
                  hd: x,
                  tl: acc
                };
        }), /* [] */0, i);
  var len = List.length(l);
  var a = Caml_array.make_float(len);
  var _i = len - 1 | 0;
  var _param = l;
  while(true) {
    var param = _param;
    var i$1 = _i;
    if (!param) {
      return a;
    }
    a[i$1] = param.hd;
    _param = param.tl;
    _i = i$1 - 1 | 0;
    continue ;
  };
}

function map_to_array(f, a) {
  var l = a.length;
  if (l === 0) {
    return [];
  }
  var r = Caml_array.make(l, Curry._1(f, a[0]));
  for(var i = 1; i < l; ++i){
    r[i] = Curry._1(f, a[i]);
  }
  return r;
}

function map_from_array(f, a) {
  var l = a.length;
  var r = Caml_array.make_float(l);
  for(var i = 0; i < l; ++i){
    r[i] = Curry._1(f, a[i]);
  }
  return r;
}

var zero = 0;

var one = 1;

var minus_one = -1;

var pi = 3.14159265358979312;

var compare = Caml.caml_float_compare;

function Array_length(prim) {
  return prim.length;
}

var Array_get = Caml_array.get;

var Array_set = Caml_array.set;

var Array_create = Caml_array.make_float;

var $$Array = {
  length: Array_length,
  get: Array_get,
  set: Array_set,
  make: make,
  create: Array_create,
  init: init,
  append: append,
  concat: concat,
  sub: sub,
  copy: copy,
  fill: fill,
  blit: blit,
  to_list: to_list,
  of_list: of_list,
  iter: iter,
  iteri: iteri,
  map: map,
  mapi: mapi,
  fold_left: fold_left,
  fold_right: fold_right,
  iter2: iter2,
  map2: map2,
  for_all: for_all,
  exists: exists,
  mem: mem,
  mem_ieee: mem_ieee,
  sort: sort,
  stable_sort: stable_sort,
  fast_sort: stable_sort,
  to_seq: to_seq,
  to_seqi: to_seqi,
  of_seq: of_seq,
  map_to_array: map_to_array,
  map_from_array: map_from_array
};

export {
  zero ,
  one ,
  minus_one ,
  succ ,
  pred ,
  infinity ,
  neg_infinity ,
  nan ,
  pi ,
  max_float ,
  min_float ,
  epsilon ,
  is_finite ,
  is_infinite ,
  is_nan ,
  is_integer ,
  of_string_opt ,
  to_string ,
  compare ,
  equal ,
  min ,
  max ,
  min_max ,
  min_num ,
  max_num ,
  min_max_num ,
  hash ,
  $$Array ,
  
}
/* nan Not a pure module */
