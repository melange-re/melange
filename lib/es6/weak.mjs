

import * as Obj from "./obj.mjs";
import * as Sys from "./sys.mjs";
import * as $$Array from "./array.mjs";
import * as Curry from "./curry.mjs";
import * as Caml_array from "./caml_array.mjs";
import * as Caml_option from "./caml_option.mjs";
import * as Caml_primitive from "./caml_primitive.mjs";
import * as Stdlib__no_aliases from "./stdlib__no_aliases.mjs";
import * as Caml_external_polyfill from "./caml_external_polyfill.mjs";

function create(l) {
  if (!(0 <= l && l <= Obj.Ephemeron.max_ephe_length)) {
    throw {
          RE_EXN_ID: "Invalid_argument",
          _1: "Weak.create",
          Error: new Error()
        };
  }
  return Caml_external_polyfill.resolve("caml_weak_create")(l);
}

function length(x) {
  return (x.length | 0) - 2 | 0;
}

function raise_if_invalid_offset(e, o, msg) {
  if (0 <= o && o < length(e)) {
    return ;
  }
  throw {
        RE_EXN_ID: "Invalid_argument",
        _1: msg,
        Error: new Error()
      };
}

function set(e, o, x) {
  raise_if_invalid_offset(e, o, "Weak.set");
  if (x !== undefined) {
    return Caml_external_polyfill.resolve("caml_ephe_set_key")(e, o, Caml_option.valFromOption(x));
  } else {
    return Caml_external_polyfill.resolve("caml_ephe_unset_key")(e, o);
  }
}

function get(e, o) {
  raise_if_invalid_offset(e, o, "Weak.get");
  return Caml_external_polyfill.resolve("caml_weak_get")(e, o);
}

function get_copy(e, o) {
  raise_if_invalid_offset(e, o, "Weak.get_copy");
  return Caml_external_polyfill.resolve("caml_weak_get_copy")(e, o);
}

function check(e, o) {
  raise_if_invalid_offset(e, o, "Weak.check");
  return Caml_external_polyfill.resolve("caml_weak_check")(e, o);
}

function blit(e1, o1, e2, o2, l) {
  if (l < 0 || o1 < 0 || o1 > (length(e1) - l | 0) || o2 < 0 || o2 > (length(e2) - l | 0)) {
    throw {
          RE_EXN_ID: "Invalid_argument",
          _1: "Weak.blit",
          Error: new Error()
        };
  }
  if (l !== 0) {
    return Caml_external_polyfill.resolve("caml_weak_blit")(e1, o1, e2, o2, l);
  }
  
}

function fill(ar, ofs, len, x) {
  if (ofs < 0 || len < 0 || ofs > (length(ar) - len | 0)) {
    throw {
          RE_EXN_ID: Stdlib__no_aliases.Invalid_argument,
          _1: "Weak.fill",
          Error: new Error()
        };
  }
  for(var i = ofs ,i_finish = ofs + len | 0; i < i_finish; ++i){
    set(ar, i, x);
  }
  
}

function Make(H) {
  var emptybucket = create(0);
  var get_index = function (t, h) {
    return (h & Stdlib__no_aliases.max_int) % t.table.length;
  };
  var create$1 = function (sz) {
    var sz$1 = sz < 7 ? 7 : sz;
    var sz$2 = sz$1 > Sys.max_array_length ? Sys.max_array_length : sz$1;
    return {
            table: Caml_array.caml_make_vect(sz$2, emptybucket),
            hashes: Caml_array.caml_make_vect(sz$2, []),
            limit: 7,
            oversize: 0,
            rover: 0
          };
  };
  var clear = function (t) {
    for(var i = 0 ,i_finish = t.table.length; i < i_finish; ++i){
      Caml_array.set(t.table, i, emptybucket);
      Caml_array.set(t.hashes, i, []);
    }
    t.limit = 7;
    t.oversize = 0;
    
  };
  var fold = function (f, t, init) {
    return $$Array.fold_right((function (param, param$1) {
                  var _i = 0;
                  var _accu = param$1;
                  while(true) {
                    var accu = _accu;
                    var i = _i;
                    if (i >= length(param)) {
                      return accu;
                    }
                    var v = get(param, i);
                    if (v !== undefined) {
                      _accu = Curry._2(f, Caml_option.valFromOption(v), accu);
                      _i = i + 1 | 0;
                      continue ;
                    }
                    _i = i + 1 | 0;
                    continue ;
                  };
                }), t.table, init);
  };
  var iter = function (f, t) {
    return $$Array.iter((function (param) {
                  var _i = 0;
                  while(true) {
                    var i = _i;
                    if (i >= length(param)) {
                      return ;
                    }
                    var v = get(param, i);
                    if (v !== undefined) {
                      Curry._1(f, Caml_option.valFromOption(v));
                      _i = i + 1 | 0;
                      continue ;
                    }
                    _i = i + 1 | 0;
                    continue ;
                  };
                }), t.table);
  };
  var iter_weak = function (f, t) {
    return $$Array.iteri((function (param, param$1) {
                  var _i = 0;
                  while(true) {
                    var i = _i;
                    if (i >= length(param$1)) {
                      return ;
                    }
                    if (check(param$1, i)) {
                      Curry._3(f, param$1, Caml_array.get(t.hashes, param), i);
                      _i = i + 1 | 0;
                      continue ;
                    }
                    _i = i + 1 | 0;
                    continue ;
                  };
                }), t.table);
  };
  var count_bucket = function (_i, b, _accu) {
    while(true) {
      var accu = _accu;
      var i = _i;
      if (i >= length(b)) {
        return accu;
      }
      _accu = accu + (
        check(b, i) ? 1 : 0
      ) | 0;
      _i = i + 1 | 0;
      continue ;
    };
  };
  var count = function (t) {
    return $$Array.fold_right((function (param, param$1) {
                  return count_bucket(0, param, param$1);
                }), t.table, 0);
  };
  var next_sz = function (n) {
    return Caml_primitive.caml_int_min((Math.imul(3, n) / 2 | 0) + 3 | 0, Sys.max_array_length);
  };
  var prev_sz = function (n) {
    return (((n - 3 | 0) << 1) + 2 | 0) / 3 | 0;
  };
  var test_shrink_bucket = function (t) {
    var bucket = Caml_array.get(t.table, t.rover);
    var hbucket = Caml_array.get(t.hashes, t.rover);
    var len = length(bucket);
    var prev_len = prev_sz(len);
    var live = count_bucket(0, bucket, 0);
    if (live <= prev_len) {
      var loop = function (_i, _j) {
        while(true) {
          var j = _j;
          var i = _i;
          if (j < prev_len) {
            return ;
          }
          if (check(bucket, i)) {
            _i = i + 1 | 0;
            continue ;
          }
          if (check(bucket, j)) {
            blit(bucket, j, bucket, i, 1);
            Caml_array.set(hbucket, i, Caml_array.get(hbucket, j));
            _j = j - 1 | 0;
            _i = i + 1 | 0;
            continue ;
          }
          _j = j - 1 | 0;
          continue ;
        };
      };
      loop(0, length(bucket) - 1 | 0);
      if (prev_len === 0) {
        Caml_array.set(t.table, t.rover, emptybucket);
        Caml_array.set(t.hashes, t.rover, []);
      } else {
        var newbucket = create(prev_len);
        blit(bucket, 0, newbucket, 0, prev_len);
        Caml_array.set(t.table, t.rover, newbucket);
        Caml_array.set(t.hashes, t.rover, $$Array.sub(hbucket, 0, prev_len));
      }
      if (len > t.limit && prev_len <= t.limit) {
        t.oversize = t.oversize - 1 | 0;
      }
      
    }
    t.rover = (t.rover + 1 | 0) % t.table.length;
    
  };
  var add_aux = function (t, setter, d, h, index) {
    var bucket = Caml_array.get(t.table, index);
    var hashes = Caml_array.get(t.hashes, index);
    var sz = length(bucket);
    var _i = 0;
    while(true) {
      var i = _i;
      if (i >= sz) {
        var newsz = Caml_primitive.caml_int_min((Math.imul(3, sz) / 2 | 0) + 3 | 0, Sys.max_array_length - 2 | 0);
        if (newsz <= sz) {
          throw {
                RE_EXN_ID: "Failure",
                _1: "Weak.Make: hash bucket cannot grow more",
                Error: new Error()
              };
        }
        var newbucket = create(newsz);
        var newhashes = Caml_array.caml_make_vect(newsz, 0);
        blit(bucket, 0, newbucket, 0, sz);
        $$Array.blit(hashes, 0, newhashes, 0, sz);
        Curry._3(setter, newbucket, sz, d);
        Caml_array.set(newhashes, sz, h);
        Caml_array.set(t.table, index, newbucket);
        Caml_array.set(t.hashes, index, newhashes);
        if (sz <= t.limit && newsz > t.limit) {
          t.oversize = t.oversize + 1 | 0;
          for(var _i$1 = 0; _i$1 <= 2; ++_i$1){
            test_shrink_bucket(t);
          }
        }
        if (t.oversize > (t.table.length >> 1)) {
          var oldlen = t.table.length;
          var newlen = next_sz(oldlen);
          if (newlen > oldlen) {
            var newt = create$1(newlen);
            var add_weak = (function(newt){
            return function add_weak(ob, oh, oi) {
              var setter = function (nb, ni, param) {
                return blit(ob, oi, nb, ni, 1);
              };
              var h = Caml_array.get(oh, oi);
              return add_aux(newt, setter, undefined, h, get_index(newt, h));
            }
            }(newt));
            iter_weak(add_weak, t);
            t.table = newt.table;
            t.hashes = newt.hashes;
            t.limit = newt.limit;
            t.oversize = newt.oversize;
            t.rover = t.rover % newt.table.length;
            return ;
          }
          t.limit = Stdlib__no_aliases.max_int;
          t.oversize = 0;
          return ;
        } else {
          return ;
        }
      }
      if (check(bucket, i)) {
        _i = i + 1 | 0;
        continue ;
      }
      Curry._3(setter, bucket, i, d);
      return Caml_array.set(hashes, i, h);
    };
  };
  var add = function (t, d) {
    var h = Curry._1(H.hash, d);
    return add_aux(t, set, Caml_option.some(d), h, get_index(t, h));
  };
  var find_or = function (t, d, ifnotfound) {
    var h = Curry._1(H.hash, d);
    var index = get_index(t, h);
    var bucket = Caml_array.get(t.table, index);
    var hashes = Caml_array.get(t.hashes, index);
    var sz = length(bucket);
    var _i = 0;
    while(true) {
      var i = _i;
      if (i >= sz) {
        return Curry._2(ifnotfound, h, index);
      }
      if (h === Caml_array.get(hashes, i)) {
        var v = get_copy(bucket, i);
        if (v !== undefined) {
          if (Curry._2(H.equal, Caml_option.valFromOption(v), d)) {
            var v$1 = get(bucket, i);
            if (v$1 !== undefined) {
              return Caml_option.valFromOption(v$1);
            }
            _i = i + 1 | 0;
            continue ;
          }
          _i = i + 1 | 0;
          continue ;
        }
        _i = i + 1 | 0;
        continue ;
      }
      _i = i + 1 | 0;
      continue ;
    };
  };
  var merge = function (t, d) {
    return find_or(t, d, (function (h, index) {
                  add_aux(t, set, Caml_option.some(d), h, index);
                  return d;
                }));
  };
  var find = function (t, d) {
    return find_or(t, d, (function (_h, _index) {
                  throw {
                        RE_EXN_ID: Stdlib__no_aliases.Not_found,
                        Error: new Error()
                      };
                }));
  };
  var find_opt = function (t, d) {
    var h = Curry._1(H.hash, d);
    var index = get_index(t, h);
    var bucket = Caml_array.get(t.table, index);
    var hashes = Caml_array.get(t.hashes, index);
    var sz = length(bucket);
    var _i = 0;
    while(true) {
      var i = _i;
      if (i >= sz) {
        return ;
      }
      if (h === Caml_array.get(hashes, i)) {
        var v = get_copy(bucket, i);
        if (v !== undefined) {
          if (Curry._2(H.equal, Caml_option.valFromOption(v), d)) {
            var v$1 = get(bucket, i);
            if (v$1 !== undefined) {
              return v$1;
            }
            _i = i + 1 | 0;
            continue ;
          }
          _i = i + 1 | 0;
          continue ;
        }
        _i = i + 1 | 0;
        continue ;
      }
      _i = i + 1 | 0;
      continue ;
    };
  };
  var find_shadow = function (t, d, iffound, ifnotfound) {
    var h = Curry._1(H.hash, d);
    var index = get_index(t, h);
    var bucket = Caml_array.get(t.table, index);
    var hashes = Caml_array.get(t.hashes, index);
    var sz = length(bucket);
    var _i = 0;
    while(true) {
      var i = _i;
      if (i >= sz) {
        return ifnotfound;
      }
      if (h === Caml_array.get(hashes, i)) {
        var v = get_copy(bucket, i);
        if (v !== undefined) {
          if (Curry._2(H.equal, Caml_option.valFromOption(v), d)) {
            return Curry._2(iffound, bucket, i);
          }
          _i = i + 1 | 0;
          continue ;
        }
        _i = i + 1 | 0;
        continue ;
      }
      _i = i + 1 | 0;
      continue ;
    };
  };
  var remove = function (t, d) {
    return find_shadow(t, d, (function (w, i) {
                  return set(w, i, undefined);
                }), undefined);
  };
  var mem = function (t, d) {
    return find_shadow(t, d, (function (_w, _i) {
                  return true;
                }), false);
  };
  var find_all = function (t, d) {
    var h = Curry._1(H.hash, d);
    var index = get_index(t, h);
    var bucket = Caml_array.get(t.table, index);
    var hashes = Caml_array.get(t.hashes, index);
    var sz = length(bucket);
    var _i = 0;
    var _accu = /* [] */0;
    while(true) {
      var accu = _accu;
      var i = _i;
      if (i >= sz) {
        return accu;
      }
      if (h === Caml_array.get(hashes, i)) {
        var v = get_copy(bucket, i);
        if (v !== undefined) {
          if (Curry._2(H.equal, Caml_option.valFromOption(v), d)) {
            var v$1 = get(bucket, i);
            if (v$1 !== undefined) {
              _accu = {
                hd: Caml_option.valFromOption(v$1),
                tl: accu
              };
              _i = i + 1 | 0;
              continue ;
            }
            _i = i + 1 | 0;
            continue ;
          }
          _i = i + 1 | 0;
          continue ;
        }
        _i = i + 1 | 0;
        continue ;
      }
      _i = i + 1 | 0;
      continue ;
    };
  };
  var stats = function (t) {
    var len = t.table.length;
    var lens = $$Array.map(length, t.table);
    $$Array.sort(Caml_primitive.caml_int_compare, lens);
    var totlen = $$Array.fold_left((function (prim, prim$1) {
            return prim + prim$1 | 0;
          }), 0, lens);
    return [
            len,
            count(t),
            totlen,
            Caml_array.get(lens, 0),
            Caml_array.get(lens, len / 2 | 0),
            Caml_array.get(lens, len - 1 | 0)
          ];
  };
  return {
          create: create$1,
          clear: clear,
          merge: merge,
          add: add,
          remove: remove,
          find: find,
          find_opt: find_opt,
          find_all: find_all,
          mem: mem,
          iter: iter,
          fold: fold,
          count: count,
          stats: stats
        };
}

export {
  create ,
  length ,
  set ,
  get ,
  get_copy ,
  check ,
  fill ,
  blit ,
  Make ,
  
}
/* No side effect */
