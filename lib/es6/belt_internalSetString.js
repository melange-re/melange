

import * as Caml_option from "./caml_option.js";
import * as Belt_internalAVLset from "./belt_internalAVLset.js";
import * as Belt_SortArrayString from "./belt_SortArrayString.js";

function has(_t, x) {
  while(true) {
    var t = _t;
    if (t === undefined) {
      return false;
    }
    var n = Caml_option.valFromOption(t);
    var v = n.v;
    if (x === v) {
      return true;
    }
    _t = x < v ? n.l : n.r;
    continue ;
  };
}

function compareAux(_e1, _e2) {
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
    var k1 = h1.v;
    var k2 = h2.v;
    if (k1 !== k2) {
      if (k1 < k2) {
        return -1;
      } else {
        return 1;
      }
    }
    _e2 = Belt_internalAVLset.stackAllLeft(h2.r, e2.tl);
    _e1 = Belt_internalAVLset.stackAllLeft(h1.r, e1.tl);
    continue ;
  };
}

function cmp(s1, s2) {
  var len1 = Belt_internalAVLset.size(s1);
  var len2 = Belt_internalAVLset.size(s2);
  if (len1 === len2) {
    return compareAux(Belt_internalAVLset.stackAllLeft(s1, /* [] */0), Belt_internalAVLset.stackAllLeft(s2, /* [] */0));
  } else if (len1 < len2) {
    return -1;
  } else {
    return 1;
  }
}

function eq(s1, s2) {
  return cmp(s1, s2) === 0;
}

function subset(_s1, _s2) {
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
    if (v1 === v2) {
      if (!subset(l1, l2)) {
        return false;
      }
      _s2 = r2;
      _s1 = r1;
      continue ;
    }
    if (v1 < v2) {
      if (!subset(Belt_internalAVLset.create(l1, v1, undefined), l2)) {
        return false;
      }
      _s1 = r1;
      continue ;
    }
    if (!subset(Belt_internalAVLset.create(undefined, v1, r1), r2)) {
      return false;
    }
    _s1 = l1;
    continue ;
  };
}

function get(_n, x) {
  while(true) {
    var n = _n;
    if (n === undefined) {
      return ;
    }
    var t = Caml_option.valFromOption(n);
    var v = t.v;
    if (x === v) {
      return v;
    }
    _n = x < v ? t.l : t.r;
    continue ;
  };
}

function getUndefined(_n, x) {
  while(true) {
    var n = _n;
    if (n === undefined) {
      return ;
    }
    var t = Caml_option.valFromOption(n);
    var v = t.v;
    if (x === v) {
      return v;
    }
    _n = x < v ? t.l : t.r;
    continue ;
  };
}

function getExn(_n, x) {
  while(true) {
    var n = _n;
    if (n !== undefined) {
      var t = Caml_option.valFromOption(n);
      var v = t.v;
      if (x === v) {
        return v;
      }
      _n = x < v ? t.l : t.r;
      continue ;
    }
    throw {
          RE_EXN_ID: "Not_found",
          Error: new Error()
        };
  };
}

function addMutate(t, x) {
  if (t === undefined) {
    return Belt_internalAVLset.singleton(x);
  }
  var nt = Caml_option.valFromOption(t);
  var k = nt.v;
  if (x === k) {
    return t;
  }
  var l = nt.l;
  var r = nt.r;
  if (x < k) {
    nt.l = addMutate(l, x);
  } else {
    nt.r = addMutate(r, x);
  }
  return Belt_internalAVLset.balMutate(nt);
}

function fromArray(xs) {
  var len = xs.length;
  if (len === 0) {
    return ;
  }
  var next = Belt_SortArrayString.strictlySortedLength(xs);
  var result;
  if (next >= 0) {
    result = Belt_internalAVLset.fromSortedArrayAux(xs, 0, next);
  } else {
    next = -next | 0;
    result = Belt_internalAVLset.fromSortedArrayRevAux(xs, next - 1 | 0, next);
  }
  for(var i = next; i < len; ++i){
    result = addMutate(result, xs[i]);
  }
  return result;
}

export {
  has ,
  compareAux ,
  cmp ,
  eq ,
  subset ,
  get ,
  getUndefined ,
  getExn ,
  addMutate ,
  fromArray ,
  
}
/* No side effect */
