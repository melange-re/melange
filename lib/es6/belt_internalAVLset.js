

import * as Curry from "./curry.js";
import * as Caml_option from "./caml_option.js";
import * as Belt_SortArray from "./belt_SortArray.js";

function copy(n) {
  if (n === undefined) {
    return n;
  }
  var n$1 = Caml_option.valFromOption(n);
  return {
          v: n$1.v,
          h: n$1.h,
          l: copy(n$1.l),
          r: copy(n$1.r)
        };
}

function create(l, v, r) {
  var hl = l !== undefined ? Caml_option.valFromOption(l).h : 0;
  var hr = r !== undefined ? Caml_option.valFromOption(r).h : 0;
  return {
          v: v,
          h: (
            hl >= hr ? hl : hr
          ) + 1 | 0,
          l: l,
          r: r
        };
}

function singleton(x) {
  return {
          v: x,
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

function bal(l, v, r) {
  var hl = l !== undefined ? Caml_option.valFromOption(l).h : 0;
  var hr = r !== undefined ? Caml_option.valFromOption(r).h : 0;
  if (hl > (hr + 2 | 0)) {
    var l$1 = Caml_option.valFromOption(l);
    var ll = l$1.l;
    var lr = l$1.r;
    if (heightGe(ll, lr)) {
      return create(ll, l$1.v, create(lr, v, r));
    }
    var lr$1 = Caml_option.valFromOption(lr);
    return create(create(ll, l$1.v, lr$1.l), lr$1.v, create(lr$1.r, v, r));
  }
  if (hr <= (hl + 2 | 0)) {
    return {
            v: v,
            h: (
              hl >= hr ? hl : hr
            ) + 1 | 0,
            l: l,
            r: r
          };
  }
  var r$1 = Caml_option.valFromOption(r);
  var rl = r$1.l;
  var rr = r$1.r;
  if (heightGe(rr, rl)) {
    return create(create(l, v, rl), r$1.v, rr);
  }
  var rl$1 = Caml_option.valFromOption(rl);
  return create(create(l, v, rl$1.l), rl$1.v, create(rl$1.r, r$1.v, rr));
}

function min0Aux(_n) {
  while(true) {
    var n = _n;
    var n$1 = n.l;
    if (n$1 === undefined) {
      return n.v;
    }
    _n = Caml_option.valFromOption(n$1);
    continue ;
  };
}

function minimum(n) {
  if (n !== undefined) {
    return Caml_option.some(min0Aux(n));
  }
  
}

function minUndefined(n) {
  if (n !== undefined) {
    return min0Aux(n);
  }
  
}

function max0Aux(_n) {
  while(true) {
    var n = _n;
    var n$1 = n.r;
    if (n$1 === undefined) {
      return n.v;
    }
    _n = Caml_option.valFromOption(n$1);
    continue ;
  };
}

function maximum(n) {
  if (n !== undefined) {
    return Caml_option.some(max0Aux(n));
  }
  
}

function maxUndefined(n) {
  if (n !== undefined) {
    return max0Aux(n);
  }
  
}

function removeMinAuxWithRef(n, v) {
  var ln = n.l;
  if (ln !== undefined) {
    return bal(removeMinAuxWithRef(Caml_option.valFromOption(ln), v), n.v, n.r);
  } else {
    v.contents = n.v;
    return n.r;
  }
}

function isEmpty(n) {
  return n === undefined;
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

function forEachU(_n, f) {
  while(true) {
    var n = _n;
    if (n === undefined) {
      return ;
    }
    var n$1 = Caml_option.valFromOption(n);
    forEachU(n$1.l, f);
    f(n$1.v);
    _n = n$1.r;
    continue ;
  };
}

function forEach(n, f) {
  return forEachU(n, Curry.__1(f));
}

function reduceU(_s, _accu, f) {
  while(true) {
    var accu = _accu;
    var s = _s;
    if (s === undefined) {
      return accu;
    }
    var n = Caml_option.valFromOption(s);
    _accu = f(reduceU(n.l, accu, f), n.v);
    _s = n.r;
    continue ;
  };
}

function reduce(s, accu, f) {
  return reduceU(s, accu, Curry.__2(f));
}

function everyU(_n, p) {
  while(true) {
    var n = _n;
    if (n === undefined) {
      return true;
    }
    var n$1 = Caml_option.valFromOption(n);
    if (!p(n$1.v)) {
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
  return everyU(n, Curry.__1(p));
}

function someU(_n, p) {
  while(true) {
    var n = _n;
    if (n === undefined) {
      return false;
    }
    var n$1 = Caml_option.valFromOption(n);
    if (p(n$1.v)) {
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
  return someU(n, Curry.__1(p));
}

function addMinElement(n, v) {
  if (n === undefined) {
    return singleton(v);
  }
  var n$1 = Caml_option.valFromOption(n);
  return bal(addMinElement(n$1.l, v), n$1.v, n$1.r);
}

function addMaxElement(n, v) {
  if (n === undefined) {
    return singleton(v);
  }
  var n$1 = Caml_option.valFromOption(n);
  return bal(n$1.l, n$1.v, addMaxElement(n$1.r, v));
}

function joinShared(ln, v, rn) {
  if (ln === undefined) {
    return addMinElement(rn, v);
  }
  if (rn === undefined) {
    return addMaxElement(ln, v);
  }
  var r = Caml_option.valFromOption(rn);
  var l = Caml_option.valFromOption(ln);
  var lh = l.h;
  var rh = r.h;
  if (lh > (rh + 2 | 0)) {
    return bal(l.l, l.v, joinShared(l.r, v, rn));
  } else if (rh > (lh + 2 | 0)) {
    return bal(joinShared(ln, v, r.l), r.v, r.r);
  } else {
    return create(ln, v, rn);
  }
}

function concatShared(t1, t2) {
  if (t1 === undefined) {
    return t2;
  }
  if (t2 === undefined) {
    return t1;
  }
  var t2n = Caml_option.valFromOption(t2);
  var v = {
    contents: t2n.v
  };
  var t2r = removeMinAuxWithRef(t2n, v);
  return joinShared(t1, v.contents, t2r);
}

function partitionSharedU(n, p) {
  if (n === undefined) {
    return [
            undefined,
            undefined
          ];
  }
  var n$1 = Caml_option.valFromOption(n);
  var value = n$1.v;
  var match = partitionSharedU(n$1.l, p);
  var lf = match[1];
  var lt = match[0];
  var pv = p(value);
  var match$1 = partitionSharedU(n$1.r, p);
  var rf = match$1[1];
  var rt = match$1[0];
  if (pv) {
    return [
            joinShared(lt, value, rt),
            concatShared(lf, rf)
          ];
  } else {
    return [
            concatShared(lt, rt),
            joinShared(lf, value, rf)
          ];
  }
}

function partitionShared(n, p) {
  return partitionSharedU(n, Curry.__1(p));
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
    _accu = {
      hd: n$1.v,
      tl: toListAux(n$1.r, accu)
    };
    _n = n$1.l;
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
    var diff = (
      l !== undefined ? Caml_option.valFromOption(l).h : 0
    ) - (
      r !== undefined ? Caml_option.valFromOption(r).h : 0
    ) | 0;
    if (!(diff <= 2 && diff >= -2)) {
      throw {
            RE_EXN_ID: "Assert_failure",
            _1: [
              "belt_internalAVLset.ml",
              290,
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

function fillArray(_n, _i, arr) {
  while(true) {
    var i = _i;
    var n = _n;
    var v = n.v;
    var l = n.l;
    var r = n.r;
    var next = l !== undefined ? fillArray(Caml_option.valFromOption(l), i, arr) : i;
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

function fillArrayWithPartition(_n, cursor, arr, p) {
  while(true) {
    var n = _n;
    var v = n.v;
    var l = n.l;
    var r = n.r;
    if (l !== undefined) {
      fillArrayWithPartition(Caml_option.valFromOption(l), cursor, arr, p);
    }
    if (p(v)) {
      var c = cursor.forward;
      arr[c] = v;
      cursor.forward = c + 1 | 0;
    } else {
      var c$1 = cursor.backward;
      arr[c$1] = v;
      cursor.backward = c$1 - 1 | 0;
    }
    if (r === undefined) {
      return ;
    }
    _n = Caml_option.valFromOption(r);
    continue ;
  };
}

function fillArrayWithFilter(_n, _i, arr, p) {
  while(true) {
    var i = _i;
    var n = _n;
    var v = n.v;
    var l = n.l;
    var r = n.r;
    var next = l !== undefined ? fillArrayWithFilter(Caml_option.valFromOption(l), i, arr, p) : i;
    var rnext = p(v) ? (arr[next] = v, next + 1 | 0) : next;
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

function fromSortedArrayRevAux(arr, off, len) {
  switch (len) {
    case 0 :
        return ;
    case 1 :
        return singleton(arr[off]);
    case 2 :
        var x0 = arr[off];
        var x1 = arr[off - 1 | 0];
        return {
                v: x1,
                h: 2,
                l: singleton(x0),
                r: undefined
              };
    case 3 :
        var x0$1 = arr[off];
        var x1$1 = arr[off - 1 | 0];
        var x2 = arr[off - 2 | 0];
        return {
                v: x1$1,
                h: 2,
                l: singleton(x0$1),
                r: singleton(x2)
              };
    default:
      var nl = len / 2 | 0;
      var left = fromSortedArrayRevAux(arr, off, nl);
      var mid = arr[off - nl | 0];
      var right = fromSortedArrayRevAux(arr, (off - nl | 0) - 1 | 0, (len - nl | 0) - 1 | 0);
      return create(left, mid, right);
  }
}

function fromSortedArrayAux(arr, off, len) {
  switch (len) {
    case 0 :
        return ;
    case 1 :
        return singleton(arr[off]);
    case 2 :
        var x0 = arr[off];
        var x1 = arr[off + 1 | 0];
        return {
                v: x1,
                h: 2,
                l: singleton(x0),
                r: undefined
              };
    case 3 :
        var x0$1 = arr[off];
        var x1$1 = arr[off + 1 | 0];
        var x2 = arr[off + 2 | 0];
        return {
                v: x1$1,
                h: 2,
                l: singleton(x0$1),
                r: singleton(x2)
              };
    default:
      var nl = len / 2 | 0;
      var left = fromSortedArrayAux(arr, off, nl);
      var mid = arr[off + nl | 0];
      var right = fromSortedArrayAux(arr, (off + nl | 0) + 1 | 0, (len - nl | 0) - 1 | 0);
      return create(left, mid, right);
  }
}

function fromSortedArrayUnsafe(arr) {
  return fromSortedArrayAux(arr, 0, arr.length);
}

function keepSharedU(n, p) {
  if (n === undefined) {
    return ;
  }
  var n$1 = Caml_option.valFromOption(n);
  var v = n$1.v;
  var l = n$1.l;
  var r = n$1.r;
  var newL = keepSharedU(l, p);
  var pv = p(v);
  var newR = keepSharedU(r, p);
  if (pv) {
    if (l === newL && r === newR) {
      return n$1;
    } else {
      return joinShared(newL, v, newR);
    }
  } else {
    return concatShared(newL, newR);
  }
}

function keepShared(n, p) {
  return keepSharedU(n, Curry.__1(p));
}

function keepCopyU(n, p) {
  if (n === undefined) {
    return ;
  }
  var size = lengthNode(n);
  var v$1 = new Array(size);
  var last = fillArrayWithFilter(n, 0, v$1, p);
  return fromSortedArrayAux(v$1, 0, last);
}

function keepCopy(n, p) {
  return keepCopyU(n, Curry.__1(p));
}

function partitionCopyU(n, p) {
  if (n === undefined) {
    return [
            undefined,
            undefined
          ];
  }
  var size = lengthNode(n);
  var v$2 = new Array(size);
  var backward = size - 1 | 0;
  var cursor = {
    forward: 0,
    backward: backward
  };
  fillArrayWithPartition(n, cursor, v$2, p);
  var forwardLen = cursor.forward;
  return [
          fromSortedArrayAux(v$2, 0, forwardLen),
          fromSortedArrayRevAux(v$2, backward, size - forwardLen | 0)
        ];
}

function partitionCopy(n, p) {
  return partitionCopyU(n, Curry.__1(p));
}

function has(_t, x, cmp) {
  while(true) {
    var t = _t;
    if (t === undefined) {
      return false;
    }
    var n = Caml_option.valFromOption(t);
    var v = n.v;
    var c = cmp(x, v);
    if (c === 0) {
      return true;
    }
    _t = c < 0 ? n.l : n.r;
    continue ;
  };
}

function cmp(s1, s2, cmp$1) {
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
      var c = cmp$1(h1.v, h2.v);
      if (c !== 0) {
        return c;
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

function eq(s1, s2, c) {
  return cmp(s1, s2, c) === 0;
}

function subset(_s1, _s2, cmp) {
  while(true) {
    var s2 = _s2;
    var s1 = _s1;
    if (s1 === undefined) {
      return true;
    }
    if (s2 === undefined) {
      return false;
    }
    var t2 = Caml_option.valFromOption(s2);
    var t1 = Caml_option.valFromOption(s1);
    var v1 = t1.v;
    var l1 = t1.l;
    var r1 = t1.r;
    var v2 = t2.v;
    var l2 = t2.l;
    var r2 = t2.r;
    var c = cmp(v1, v2);
    if (c === 0) {
      if (!subset(l1, l2, cmp)) {
        return false;
      }
      _s2 = r2;
      _s1 = r1;
      continue ;
    }
    if (c < 0) {
      if (!subset(create(l1, v1, undefined), l2, cmp)) {
        return false;
      }
      _s1 = r1;
      continue ;
    }
    if (!subset(create(undefined, v1, r1), r2, cmp)) {
      return false;
    }
    _s1 = l1;
    continue ;
  };
}

function get(_n, x, cmp) {
  while(true) {
    var n = _n;
    if (n === undefined) {
      return ;
    }
    var t = Caml_option.valFromOption(n);
    var v = t.v;
    var c = cmp(x, v);
    if (c === 0) {
      return Caml_option.some(v);
    }
    _n = c < 0 ? t.l : t.r;
    continue ;
  };
}

function getUndefined(_n, x, cmp) {
  while(true) {
    var n = _n;
    if (n === undefined) {
      return ;
    }
    var t = Caml_option.valFromOption(n);
    var v = t.v;
    var c = cmp(x, v);
    if (c === 0) {
      return v;
    }
    _n = c < 0 ? t.l : t.r;
    continue ;
  };
}

function getExn(_n, x, cmp) {
  while(true) {
    var n = _n;
    if (n !== undefined) {
      var t = Caml_option.valFromOption(n);
      var v = t.v;
      var c = cmp(x, v);
      if (c === 0) {
        return v;
      }
      _n = c < 0 ? t.l : t.r;
      continue ;
    }
    throw {
          RE_EXN_ID: "Not_found",
          Error: new Error()
        };
  };
}

function rotateWithLeftChild(k2) {
  var k1 = k2.l;
  var k1$1 = Caml_option.valFromOption(k1);
  k2.l = k1$1.r;
  k1$1.r = k2;
  var n = k2.l;
  var hlk2 = n !== undefined ? Caml_option.valFromOption(n).h : 0;
  var n$1 = k2.r;
  var hrk2 = n$1 !== undefined ? Caml_option.valFromOption(n$1).h : 0;
  k2.h = (
    hlk2 > hrk2 ? hlk2 : hrk2
  ) + 1 | 0;
  var n$2 = k1$1.l;
  var hlk1 = n$2 !== undefined ? Caml_option.valFromOption(n$2).h : 0;
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
  var n = k1.l;
  var hlk1 = n !== undefined ? Caml_option.valFromOption(n).h : 0;
  var n$1 = k1.r;
  var hrk1 = n$1 !== undefined ? Caml_option.valFromOption(n$1).h : 0;
  k1.h = (
    hlk1 > hrk1 ? hlk1 : hrk1
  ) + 1 | 0;
  var n$2 = k2$1.r;
  var hrk2 = n$2 !== undefined ? Caml_option.valFromOption(n$2).h : 0;
  var hk1 = k1.h;
  k2$1.h = (
    hrk2 > hk1 ? hrk2 : hk1
  ) + 1 | 0;
  return k2$1;
}

function doubleWithLeftChild(k3) {
  var k3l = k3.l;
  var v = rotateWithRightChild(Caml_option.valFromOption(k3l));
  k3.l = v;
  return rotateWithLeftChild(k3);
}

function doubleWithRightChild(k2) {
  var k2r = k2.r;
  var v = rotateWithLeftChild(Caml_option.valFromOption(k2r));
  k2.r = v;
  return rotateWithRightChild(k2);
}

function heightUpdateMutate(t) {
  var n = t.l;
  var hlt = n !== undefined ? Caml_option.valFromOption(n).h : 0;
  var n$1 = t.r;
  var hrt = n$1 !== undefined ? Caml_option.valFromOption(n$1).h : 0;
  t.h = (
    hlt > hrt ? hlt : hrt
  ) + 1 | 0;
  return t;
}

function balMutate(nt) {
  var l = nt.l;
  var r = nt.r;
  var hl = l !== undefined ? Caml_option.valFromOption(l).h : 0;
  var hr = r !== undefined ? Caml_option.valFromOption(r).h : 0;
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

function addMutate(cmp, t, x) {
  if (t === undefined) {
    return singleton(x);
  }
  var nt = Caml_option.valFromOption(t);
  var k = nt.v;
  var c = cmp(x, k);
  if (c === 0) {
    return t;
  }
  var l = nt.l;
  var r = nt.r;
  if (c < 0) {
    var ll = addMutate(cmp, l, x);
    nt.l = ll;
  } else {
    nt.r = addMutate(cmp, r, x);
  }
  return balMutate(nt);
}

function fromArray(xs, cmp) {
  var len = xs.length;
  if (len === 0) {
    return ;
  }
  var next = Belt_SortArray.strictlySortedLengthU(xs, (function (x, y) {
          return cmp(x, y) < 0;
        }));
  var result;
  if (next >= 0) {
    result = fromSortedArrayAux(xs, 0, next);
  } else {
    next = -next | 0;
    result = fromSortedArrayRevAux(xs, next - 1 | 0, next);
  }
  for(var i = next; i < len; ++i){
    result = addMutate(cmp, result, xs[i]);
  }
  return result;
}

function removeMinAuxWithRootMutate(nt, n) {
  var ln = n.l;
  var rn = n.r;
  if (ln !== undefined) {
    n.l = removeMinAuxWithRootMutate(nt, Caml_option.valFromOption(ln));
    return balMutate(n);
  } else {
    nt.v = n.v;
    return rn;
  }
}

export {
  copy ,
  create ,
  bal ,
  singleton ,
  minimum ,
  minUndefined ,
  maximum ,
  maxUndefined ,
  removeMinAuxWithRef ,
  isEmpty ,
  stackAllLeft ,
  forEachU ,
  forEach ,
  reduceU ,
  reduce ,
  everyU ,
  every ,
  someU ,
  some ,
  joinShared ,
  concatShared ,
  keepSharedU ,
  keepShared ,
  keepCopyU ,
  keepCopy ,
  partitionSharedU ,
  partitionShared ,
  partitionCopyU ,
  partitionCopy ,
  lengthNode ,
  size ,
  toList ,
  checkInvariantInternal ,
  fillArray ,
  toArray ,
  fromSortedArrayAux ,
  fromSortedArrayRevAux ,
  fromSortedArrayUnsafe ,
  has ,
  cmp ,
  eq ,
  subset ,
  get ,
  getUndefined ,
  getExn ,
  fromArray ,
  addMutate ,
  balMutate ,
  removeMinAuxWithRootMutate ,
  
}
/* No side effect */
