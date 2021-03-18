

import * as Curry from "./curry.js";
import * as Caml_option from "./caml_option.js";
import * as Belt_SortArray from "./belt_SortArray.js";

function treeHeight(n) {
  if (n !== undefined) {
    return Caml_option.valFromOption(n).h;
  } else {
    return 0;
  }
}

function copy(n) {
  if (n === undefined) {
    return n;
  }
  var n$1 = Caml_option.valFromOption(n);
  return {
          k: n$1.k,
          v: n$1.v,
          h: n$1.h,
          l: copy(n$1.l),
          r: copy(n$1.r)
        };
}

function create(l, x, d, r) {
  var hl = treeHeight(l);
  var hr = treeHeight(r);
  return {
          k: x,
          v: d,
          h: hl >= hr ? hl + 1 | 0 : hr + 1 | 0,
          l: l,
          r: r
        };
}

function singleton(x, d) {
  return {
          k: x,
          v: d,
          h: 1,
          l: undefined,
          r: undefined
        };
}

function heightGe(l, r) {
  if (r !== undefined) {
    if (l !== undefined) {
      return l.h >= r.h;
    } else {
      return false;
    }
  } else {
    return true;
  }
}

function updateValue(n, newValue) {
  if (n.v === newValue) {
    return n;
  } else {
    return {
            k: n.k,
            v: newValue,
            h: n.h,
            l: n.l,
            r: n.r
          };
  }
}

function bal(l, x, d, r) {
  var hl = l !== undefined ? Caml_option.valFromOption(l).h : 0;
  var hr = r !== undefined ? Caml_option.valFromOption(r).h : 0;
  if (hl > (hr + 2 | 0)) {
    var ll = l.l;
    var lr = l.r;
    if (treeHeight(ll) >= treeHeight(lr)) {
      return create(ll, l.k, l.v, create(lr, x, d, r));
    }
    var lr$1 = Caml_option.valFromOption(lr);
    return create(create(ll, l.k, l.v, lr$1.l), lr$1.k, lr$1.v, create(lr$1.r, x, d, r));
  }
  if (hr <= (hl + 2 | 0)) {
    return {
            k: x,
            v: d,
            h: hl >= hr ? hl + 1 | 0 : hr + 1 | 0,
            l: l,
            r: r
          };
  }
  var r$1 = Caml_option.valFromOption(r);
  var rl = r$1.l;
  var rr = r$1.r;
  if (treeHeight(rr) >= treeHeight(rl)) {
    return create(create(l, x, d, rl), r$1.k, r$1.v, rr);
  }
  var rl$1 = Caml_option.valFromOption(rl);
  return create(create(l, x, d, rl$1.l), rl$1.k, rl$1.v, create(rl$1.r, r$1.k, r$1.v, rr));
}

function minKey0Aux(_n) {
  while(true) {
    var n = _n;
    var n$1 = n.l;
    if (n$1 === undefined) {
      return n.k;
    }
    _n = Caml_option.valFromOption(n$1);
    continue ;
  };
}

function minKey(n) {
  if (n !== undefined) {
    return Caml_option.some(minKey0Aux(n));
  }
  
}

function minKeyUndefined(n) {
  if (n !== undefined) {
    return minKey0Aux(n);
  }
  
}

function maxKey0Aux(_n) {
  while(true) {
    var n = _n;
    var n$1 = n.r;
    if (n$1 === undefined) {
      return n.k;
    }
    _n = Caml_option.valFromOption(n$1);
    continue ;
  };
}

function maxKey(n) {
  if (n !== undefined) {
    return Caml_option.some(maxKey0Aux(n));
  }
  
}

function maxKeyUndefined(n) {
  if (n !== undefined) {
    return maxKey0Aux(n);
  }
  
}

function minKV0Aux(_n) {
  while(true) {
    var n = _n;
    var n$1 = n.l;
    if (n$1 === undefined) {
      return [
              n.k,
              n.v
            ];
    }
    _n = Caml_option.valFromOption(n$1);
    continue ;
  };
}

function minimum(n) {
  if (n !== undefined) {
    return minKV0Aux(n);
  }
  
}

function minUndefined(n) {
  if (n !== undefined) {
    return minKV0Aux(n);
  }
  
}

function maxKV0Aux(_n) {
  while(true) {
    var n = _n;
    var n$1 = n.r;
    if (n$1 === undefined) {
      return [
              n.k,
              n.v
            ];
    }
    _n = Caml_option.valFromOption(n$1);
    continue ;
  };
}

function maximum(n) {
  if (n !== undefined) {
    return maxKV0Aux(n);
  }
  
}

function maxUndefined(n) {
  if (n !== undefined) {
    return maxKV0Aux(n);
  }
  
}

function removeMinAuxWithRef(n, kr, vr) {
  var ln = n.l;
  if (ln !== undefined) {
    return bal(removeMinAuxWithRef(Caml_option.valFromOption(ln), kr, vr), n.k, n.v, n.r);
  } else {
    kr.contents = n.k;
    vr.contents = n.v;
    return n.r;
  }
}

function isEmpty(x) {
  return x === undefined;
}

function stackAllLeft(_v, _s) {
  while(true) {
    var s = _s;
    var v = _v;
    if (v === undefined) {
      return s;
    }
    var x = Caml_option.valFromOption(v);
    _s = {
      hd: x,
      tl: s
    };
    _v = x.l;
    continue ;
  };
}

function findFirstByU(n, p) {
  if (n === undefined) {
    return ;
  }
  var n$1 = Caml_option.valFromOption(n);
  var left = findFirstByU(n$1.l, p);
  if (left !== undefined) {
    return left;
  }
  var v = n$1.k;
  var d = n$1.v;
  var pvd = p(v, d);
  if (pvd) {
    return [
            v,
            d
          ];
  }
  var right = findFirstByU(n$1.r, p);
  if (right !== undefined) {
    return right;
  }
  
}

function findFirstBy(n, p) {
  return findFirstByU(n, Curry.__2(p));
}

function forEachU(_n, f) {
  while(true) {
    var n = _n;
    if (n === undefined) {
      return ;
    }
    var n$1 = Caml_option.valFromOption(n);
    forEachU(n$1.l, f);
    f(n$1.k, n$1.v);
    _n = n$1.r;
    continue ;
  };
}

function forEach(n, f) {
  return forEachU(n, Curry.__2(f));
}

function mapU(n, f) {
  if (n === undefined) {
    return ;
  }
  var n$1 = Caml_option.valFromOption(n);
  var newLeft = mapU(n$1.l, f);
  var newD = f(n$1.v);
  var newRight = mapU(n$1.r, f);
  return {
          k: n$1.k,
          v: newD,
          h: n$1.h,
          l: newLeft,
          r: newRight
        };
}

function map(n, f) {
  return mapU(n, Curry.__1(f));
}

function mapWithKeyU(n, f) {
  if (n === undefined) {
    return ;
  }
  var n$1 = Caml_option.valFromOption(n);
  var key = n$1.k;
  var newLeft = mapWithKeyU(n$1.l, f);
  var newD = f(key, n$1.v);
  var newRight = mapWithKeyU(n$1.r, f);
  return {
          k: key,
          v: newD,
          h: n$1.h,
          l: newLeft,
          r: newRight
        };
}

function mapWithKey(n, f) {
  return mapWithKeyU(n, Curry.__2(f));
}

function reduceU(_m, _accu, f) {
  while(true) {
    var accu = _accu;
    var m = _m;
    if (m === undefined) {
      return accu;
    }
    var n = Caml_option.valFromOption(m);
    var v = n.k;
    var d = n.v;
    var l = n.l;
    var r = n.r;
    _accu = f(reduceU(l, accu, f), v, d);
    _m = r;
    continue ;
  };
}

function reduce(m, accu, f) {
  return reduceU(m, accu, Curry.__3(f));
}

function everyU(_n, p) {
  while(true) {
    var n = _n;
    if (n === undefined) {
      return true;
    }
    var n$1 = Caml_option.valFromOption(n);
    if (!p(n$1.k, n$1.v)) {
      return false;
    }
    if (!everyU(n$1.l, p)) {
      return false;
    }
    _n = n$1.r;
    continue ;
  };
}

function every(n, p) {
  return everyU(n, Curry.__2(p));
}

function someU(_n, p) {
  while(true) {
    var n = _n;
    if (n === undefined) {
      return false;
    }
    var n$1 = Caml_option.valFromOption(n);
    if (p(n$1.k, n$1.v)) {
      return true;
    }
    if (someU(n$1.l, p)) {
      return true;
    }
    _n = n$1.r;
    continue ;
  };
}

function some(n, p) {
  return someU(n, Curry.__2(p));
}

function addMinElement(n, k, v) {
  if (n === undefined) {
    return singleton(k, v);
  }
  var n$1 = Caml_option.valFromOption(n);
  return bal(addMinElement(n$1.l, k, v), n$1.k, n$1.v, n$1.r);
}

function addMaxElement(n, k, v) {
  if (n === undefined) {
    return singleton(k, v);
  }
  var n$1 = Caml_option.valFromOption(n);
  return bal(n$1.l, n$1.k, n$1.v, addMaxElement(n$1.r, k, v));
}

function join(ln, v, d, rn) {
  if (ln === undefined) {
    return addMinElement(rn, v, d);
  }
  if (rn === undefined) {
    return addMaxElement(ln, v, d);
  }
  var r = Caml_option.valFromOption(rn);
  var l = Caml_option.valFromOption(ln);
  var lv = l.k;
  var ld = l.v;
  var lh = l.h;
  var ll = l.l;
  var lr = l.r;
  var rv = r.k;
  var rd = r.v;
  var rh = r.h;
  var rl = r.l;
  var rr = r.r;
  if (lh > (rh + 2 | 0)) {
    return bal(ll, lv, ld, join(lr, v, d, rn));
  } else if (rh > (lh + 2 | 0)) {
    return bal(join(ln, v, d, rl), rv, rd, rr);
  } else {
    return create(ln, v, d, rn);
  }
}

function concat(t1, t2) {
  if (t1 === undefined) {
    return t2;
  }
  if (t2 === undefined) {
    return t1;
  }
  var t2n = Caml_option.valFromOption(t2);
  var kr = {
    contents: t2n.k
  };
  var vr = {
    contents: t2n.v
  };
  var t2r = removeMinAuxWithRef(t2n, kr, vr);
  return join(t1, kr.contents, vr.contents, t2r);
}

function concatOrJoin(t1, v, d, t2) {
  if (d !== undefined) {
    return join(t1, v, Caml_option.valFromOption(d), t2);
  } else {
    return concat(t1, t2);
  }
}

function keepSharedU(n, p) {
  if (n === undefined) {
    return ;
  }
  var n$1 = Caml_option.valFromOption(n);
  var v = n$1.k;
  var d = n$1.v;
  var newLeft = keepSharedU(n$1.l, p);
  var pvd = p(v, d);
  var newRight = keepSharedU(n$1.r, p);
  if (pvd) {
    return join(newLeft, v, d, newRight);
  } else {
    return concat(newLeft, newRight);
  }
}

function keepShared(n, p) {
  return keepSharedU(n, Curry.__2(p));
}

function keepMapU(n, p) {
  if (n === undefined) {
    return ;
  }
  var n$1 = Caml_option.valFromOption(n);
  var v = n$1.k;
  var d = n$1.v;
  var newLeft = keepMapU(n$1.l, p);
  var pvd = p(v, d);
  var newRight = keepMapU(n$1.r, p);
  if (pvd !== undefined) {
    return join(newLeft, v, Caml_option.valFromOption(pvd), newRight);
  } else {
    return concat(newLeft, newRight);
  }
}

function keepMap(n, p) {
  return keepMapU(n, Curry.__2(p));
}

function partitionSharedU(n, p) {
  if (n === undefined) {
    return [
            undefined,
            undefined
          ];
  }
  var n$1 = Caml_option.valFromOption(n);
  var key = n$1.k;
  var value = n$1.v;
  var match = partitionSharedU(n$1.l, p);
  var lf = match[1];
  var lt = match[0];
  var pvd = p(key, value);
  var match$1 = partitionSharedU(n$1.r, p);
  var rf = match$1[1];
  var rt = match$1[0];
  if (pvd) {
    return [
            join(lt, key, value, rt),
            concat(lf, rf)
          ];
  } else {
    return [
            concat(lt, rt),
            join(lf, key, value, rf)
          ];
  }
}

function partitionShared(n, p) {
  return partitionSharedU(n, Curry.__2(p));
}

function lengthNode(n) {
  var l = n.l;
  var r = n.r;
  var sizeL = l !== undefined ? lengthNode(Caml_option.valFromOption(l)) : 0;
  var sizeR = r !== undefined ? lengthNode(Caml_option.valFromOption(r)) : 0;
  return (1 + sizeL | 0) + sizeR | 0;
}

function size(n) {
  if (n !== undefined) {
    return lengthNode(n);
  } else {
    return 0;
  }
}

function toListAux(_n, _accu) {
  while(true) {
    var accu = _accu;
    var n = _n;
    if (n === undefined) {
      return accu;
    }
    var n$1 = Caml_option.valFromOption(n);
    var k = n$1.k;
    var v = n$1.v;
    var l = n$1.l;
    var r = n$1.r;
    _accu = {
      hd: [
        k,
        v
      ],
      tl: toListAux(r, accu)
    };
    _n = l;
    continue ;
  };
}

function toList(s) {
  return toListAux(s, /* [] */0);
}

function checkInvariantInternal(_v) {
  while(true) {
    var v = _v;
    if (v === undefined) {
      return ;
    }
    var n = Caml_option.valFromOption(v);
    var l = n.l;
    var r = n.r;
    var diff = treeHeight(l) - treeHeight(r) | 0;
    if (!(diff <= 2 && diff >= -2)) {
      throw {
            RE_EXN_ID: "Assert_failure",
            _1: [
              "belt_internalAVLtree.ml",
              373,
              4
            ],
            Error: new Error()
          };
    }
    checkInvariantInternal(l);
    _v = r;
    continue ;
  };
}

function fillArrayKey(_n, _i, arr) {
  while(true) {
    var i = _i;
    var n = _n;
    var v = n.k;
    var l = n.l;
    var r = n.r;
    var next = l !== undefined ? fillArrayKey(Caml_option.valFromOption(l), i, arr) : i;
    arr[next] = v;
    var rnext = next + 1 | 0;
    if (r === undefined) {
      return rnext;
    }
    _i = rnext;
    _n = Caml_option.valFromOption(r);
    continue ;
  };
}

function fillArrayValue(_n, _i, arr) {
  while(true) {
    var i = _i;
    var n = _n;
    var l = n.l;
    var r = n.r;
    var next = l !== undefined ? fillArrayValue(Caml_option.valFromOption(l), i, arr) : i;
    arr[next] = n.v;
    var rnext = next + 1 | 0;
    if (r === undefined) {
      return rnext;
    }
    _i = rnext;
    _n = Caml_option.valFromOption(r);
    continue ;
  };
}

function fillArray(_n, _i, arr) {
  while(true) {
    var i = _i;
    var n = _n;
    var l = n.l;
    var v = n.k;
    var r = n.r;
    var next = l !== undefined ? fillArray(Caml_option.valFromOption(l), i, arr) : i;
    arr[next] = [
      v,
      n.v
    ];
    var rnext = next + 1 | 0;
    if (r === undefined) {
      return rnext;
    }
    _i = rnext;
    _n = Caml_option.valFromOption(r);
    continue ;
  };
}

function toArray(n) {
  if (n === undefined) {
    return [];
  }
  var size = lengthNode(n);
  var v = new Array(size);
  fillArray(n, 0, v);
  return v;
}

function keysToArray(n) {
  if (n === undefined) {
    return [];
  }
  var size = lengthNode(n);
  var v$1 = new Array(size);
  fillArrayKey(n, 0, v$1);
  return v$1;
}

function valuesToArray(n) {
  if (n === undefined) {
    return [];
  }
  var size = lengthNode(n);
  var v$2 = new Array(size);
  fillArrayValue(n, 0, v$2);
  return v$2;
}

function fromSortedArrayRevAux(arr, off, len) {
  switch (len) {
    case 0 :
        return ;
    case 1 :
        var match = arr[off];
        return singleton(match[0], match[1]);
    case 2 :
        var match_0 = arr[off];
        var match_1 = arr[off - 1 | 0];
        var match$1 = match_1;
        var match$2 = match_0;
        return {
                k: match$1[0],
                v: match$1[1],
                h: 2,
                l: singleton(match$2[0], match$2[1]),
                r: undefined
              };
    case 3 :
        var match_0$1 = arr[off];
        var match_1$1 = arr[off - 1 | 0];
        var match_2 = arr[off - 2 | 0];
        var match$3 = match_2;
        var match$4 = match_1$1;
        var match$5 = match_0$1;
        return {
                k: match$4[0],
                v: match$4[1],
                h: 2,
                l: singleton(match$5[0], match$5[1]),
                r: singleton(match$3[0], match$3[1])
              };
    default:
      var nl = len / 2 | 0;
      var left = fromSortedArrayRevAux(arr, off, nl);
      var match$6 = arr[off - nl | 0];
      var right = fromSortedArrayRevAux(arr, (off - nl | 0) - 1 | 0, (len - nl | 0) - 1 | 0);
      return create(left, match$6[0], match$6[1], right);
  }
}

function fromSortedArrayAux(arr, off, len) {
  switch (len) {
    case 0 :
        return ;
    case 1 :
        var match = arr[off];
        return singleton(match[0], match[1]);
    case 2 :
        var match_0 = arr[off];
        var match_1 = arr[off + 1 | 0];
        var match$1 = match_1;
        var match$2 = match_0;
        return {
                k: match$1[0],
                v: match$1[1],
                h: 2,
                l: singleton(match$2[0], match$2[1]),
                r: undefined
              };
    case 3 :
        var match_0$1 = arr[off];
        var match_1$1 = arr[off + 1 | 0];
        var match_2 = arr[off + 2 | 0];
        var match$3 = match_2;
        var match$4 = match_1$1;
        var match$5 = match_0$1;
        return {
                k: match$4[0],
                v: match$4[1],
                h: 2,
                l: singleton(match$5[0], match$5[1]),
                r: singleton(match$3[0], match$3[1])
              };
    default:
      var nl = len / 2 | 0;
      var left = fromSortedArrayAux(arr, off, nl);
      var match$6 = arr[off + nl | 0];
      var right = fromSortedArrayAux(arr, (off + nl | 0) + 1 | 0, (len - nl | 0) - 1 | 0);
      return create(left, match$6[0], match$6[1], right);
  }
}

function fromSortedArrayUnsafe(arr) {
  return fromSortedArrayAux(arr, 0, arr.length);
}

function cmpU(s1, s2, kcmp, vcmp) {
  var len1 = size(s1);
  var len2 = size(s2);
  if (len1 === len2) {
    var _e1 = stackAllLeft(s1, /* [] */0);
    var _e2 = stackAllLeft(s2, /* [] */0);
    while(true) {
      var e2 = _e2;
      var e1 = _e1;
      if (!e1) {
        return 0;
      }
      if (!e2) {
        return 0;
      }
      var h2 = e2.hd;
      var h1 = e1.hd;
      var c = kcmp(h1.k, h2.k);
      if (c !== 0) {
        return c;
      }
      var cx = vcmp(h1.v, h2.v);
      if (cx !== 0) {
        return cx;
      }
      _e2 = stackAllLeft(h2.r, e2.tl);
      _e1 = stackAllLeft(h1.r, e1.tl);
      continue ;
    };
  } else if (len1 < len2) {
    return -1;
  } else {
    return 1;
  }
}

function cmp(s1, s2, kcmp, vcmp) {
  return cmpU(s1, s2, kcmp, Curry.__2(vcmp));
}

function eqU(s1, s2, kcmp, veq) {
  var len1 = size(s1);
  var len2 = size(s2);
  if (len1 === len2) {
    var _e1 = stackAllLeft(s1, /* [] */0);
    var _e2 = stackAllLeft(s2, /* [] */0);
    while(true) {
      var e2 = _e2;
      var e1 = _e1;
      if (!e1) {
        return true;
      }
      if (!e2) {
        return true;
      }
      var h2 = e2.hd;
      var h1 = e1.hd;
      if (!(kcmp(h1.k, h2.k) === 0 && veq(h1.v, h2.v))) {
        return false;
      }
      _e2 = stackAllLeft(h2.r, e2.tl);
      _e1 = stackAllLeft(h1.r, e1.tl);
      continue ;
    };
  } else {
    return false;
  }
}

function eq(s1, s2, kcmp, veq) {
  return eqU(s1, s2, kcmp, Curry.__2(veq));
}

function get(_n, x, cmp) {
  while(true) {
    var n = _n;
    if (n === undefined) {
      return ;
    }
    var n$1 = Caml_option.valFromOption(n);
    var v = n$1.k;
    var c = cmp(x, v);
    if (c === 0) {
      return Caml_option.some(n$1.v);
    }
    _n = c < 0 ? n$1.l : n$1.r;
    continue ;
  };
}

function getUndefined(_n, x, cmp) {
  while(true) {
    var n = _n;
    if (n === undefined) {
      return ;
    }
    var n$1 = Caml_option.valFromOption(n);
    var v = n$1.k;
    var c = cmp(x, v);
    if (c === 0) {
      return n$1.v;
    }
    _n = c < 0 ? n$1.l : n$1.r;
    continue ;
  };
}

function getExn(_n, x, cmp) {
  while(true) {
    var n = _n;
    if (n !== undefined) {
      var n$1 = Caml_option.valFromOption(n);
      var v = n$1.k;
      var c = cmp(x, v);
      if (c === 0) {
        return n$1.v;
      }
      _n = c < 0 ? n$1.l : n$1.r;
      continue ;
    }
    throw {
          RE_EXN_ID: "Not_found",
          Error: new Error()
        };
  };
}

function getWithDefault(_n, x, def, cmp) {
  while(true) {
    var n = _n;
    if (n === undefined) {
      return def;
    }
    var n$1 = Caml_option.valFromOption(n);
    var v = n$1.k;
    var c = cmp(x, v);
    if (c === 0) {
      return n$1.v;
    }
    _n = c < 0 ? n$1.l : n$1.r;
    continue ;
  };
}

function has(_n, x, cmp) {
  while(true) {
    var n = _n;
    if (n === undefined) {
      return false;
    }
    var n$1 = Caml_option.valFromOption(n);
    var v = n$1.k;
    var c = cmp(x, v);
    if (c === 0) {
      return true;
    }
    _n = c < 0 ? n$1.l : n$1.r;
    continue ;
  };
}

function rotateWithLeftChild(k2) {
  var k1 = k2.l;
  var k1$1 = Caml_option.valFromOption(k1);
  k2.l = k1$1.r;
  k1$1.r = k2;
  var hlk2 = treeHeight(k2.l);
  var hrk2 = treeHeight(k2.r);
  k2.h = (
    hlk2 > hrk2 ? hlk2 : hrk2
  ) + 1 | 0;
  var hlk1 = treeHeight(k1$1.l);
  var hk2 = k2.h;
  k1$1.h = (
    hlk1 > hk2 ? hlk1 : hk2
  ) + 1 | 0;
  return k1$1;
}

function rotateWithRightChild(k1) {
  var k2 = k1.r;
  var k2$1 = Caml_option.valFromOption(k2);
  k1.r = k2$1.l;
  k2$1.l = k1;
  var hlk1 = treeHeight(k1.l);
  var hrk1 = treeHeight(k1.r);
  k1.h = (
    hlk1 > hrk1 ? hlk1 : hrk1
  ) + 1 | 0;
  var hrk2 = treeHeight(k2$1.r);
  var hk1 = k1.h;
  k2$1.h = (
    hrk2 > hk1 ? hrk2 : hk1
  ) + 1 | 0;
  return k2$1;
}

function doubleWithLeftChild(k3) {
  var x = k3.l;
  var v = rotateWithRightChild(Caml_option.valFromOption(x));
  k3.l = v;
  return rotateWithLeftChild(k3);
}

function doubleWithRightChild(k2) {
  var x = k2.r;
  var v = rotateWithLeftChild(Caml_option.valFromOption(x));
  k2.r = v;
  return rotateWithRightChild(k2);
}

function heightUpdateMutate(t) {
  var hlt = treeHeight(t.l);
  var hrt = treeHeight(t.r);
  t.h = (
    hlt > hrt ? hlt : hrt
  ) + 1 | 0;
  return t;
}

function balMutate(nt) {
  var l = nt.l;
  var r = nt.r;
  var hl = treeHeight(l);
  var hr = treeHeight(r);
  if (hl > (2 + hr | 0)) {
    var match = Caml_option.valFromOption(l);
    var ll = match.l;
    var lr = match.r;
    if (heightGe(ll, lr)) {
      return heightUpdateMutate(rotateWithLeftChild(nt));
    } else {
      return heightUpdateMutate(doubleWithLeftChild(nt));
    }
  }
  if (hr > (2 + hl | 0)) {
    var match$1 = Caml_option.valFromOption(r);
    var rl = match$1.l;
    var rr = match$1.r;
    if (heightGe(rr, rl)) {
      return heightUpdateMutate(rotateWithRightChild(nt));
    } else {
      return heightUpdateMutate(doubleWithRightChild(nt));
    }
  }
  nt.h = (
    hl > hr ? hl : hr
  ) + 1 | 0;
  return nt;
}

function updateMutate(t, x, data, cmp) {
  if (t === undefined) {
    return singleton(x, data);
  }
  var nt = Caml_option.valFromOption(t);
  var k = nt.k;
  var c = cmp(x, k);
  if (c === 0) {
    nt.v = data;
    return nt;
  }
  var l = nt.l;
  var r = nt.r;
  if (c < 0) {
    var ll = updateMutate(l, x, data, cmp);
    nt.l = ll;
  } else {
    nt.r = updateMutate(r, x, data, cmp);
  }
  return balMutate(nt);
}

function fromArray(xs, cmp) {
  var len = xs.length;
  if (len === 0) {
    return ;
  }
  var next = Belt_SortArray.strictlySortedLengthU(xs, (function (param, param$1) {
          return cmp(param[0], param$1[0]) < 0;
        }));
  var result;
  if (next >= 0) {
    result = fromSortedArrayAux(xs, 0, next);
  } else {
    next = -next | 0;
    result = fromSortedArrayRevAux(xs, next - 1 | 0, next);
  }
  for(var i = next; i < len; ++i){
    var match = xs[i];
    result = updateMutate(result, match[0], match[1], cmp);
  }
  return result;
}

function removeMinAuxWithRootMutate(nt, n) {
  var rn = n.r;
  var ln = n.l;
  if (ln !== undefined) {
    n.l = removeMinAuxWithRootMutate(nt, Caml_option.valFromOption(ln));
    return balMutate(n);
  } else {
    nt.k = n.k;
    nt.v = n.v;
    return rn;
  }
}

export {
  copy ,
  create ,
  bal ,
  singleton ,
  updateValue ,
  minKey ,
  minKeyUndefined ,
  maxKey ,
  maxKeyUndefined ,
  minimum ,
  minUndefined ,
  maximum ,
  maxUndefined ,
  removeMinAuxWithRef ,
  isEmpty ,
  stackAllLeft ,
  findFirstByU ,
  findFirstBy ,
  forEachU ,
  forEach ,
  mapU ,
  map ,
  mapWithKeyU ,
  mapWithKey ,
  reduceU ,
  reduce ,
  everyU ,
  every ,
  someU ,
  some ,
  join ,
  concat ,
  concatOrJoin ,
  keepSharedU ,
  keepShared ,
  keepMapU ,
  keepMap ,
  partitionSharedU ,
  partitionShared ,
  lengthNode ,
  size ,
  toList ,
  checkInvariantInternal ,
  fillArray ,
  toArray ,
  keysToArray ,
  valuesToArray ,
  fromSortedArrayAux ,
  fromSortedArrayRevAux ,
  fromSortedArrayUnsafe ,
  cmpU ,
  cmp ,
  eqU ,
  eq ,
  get ,
  getUndefined ,
  getWithDefault ,
  getExn ,
  has ,
  fromArray ,
  updateMutate ,
  balMutate ,
  removeMinAuxWithRootMutate ,
  
}
/* No side effect */
