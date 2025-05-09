// Generated by Melange
'use strict';

const Caml = require("melange.js/caml.js");
const Caml_js_exceptions = require("melange.js/caml_js_exceptions.js");
const Curry = require("melange.js/curry.js");
const Stdlib = require("melange/stdlib.js");

const compare = Caml.caml_string_compare;

const funarg = {
  compare: compare
};

function height(param) {
  if (/* tag */ typeof param === "number" || typeof param === "string") {
    return 0;
  } else {
    return param.h;
  }
}

function create(l, x, d, r) {
  const hl = height(l);
  const hr = height(r);
  return {
    TAG: /* Node */ 0,
    l: l,
    v: x,
    d: d,
    r: r,
    h: hl >= hr ? hl + 1 | 0 : hr + 1 | 0
  };
}

function bal(l, x, d, r) {
  let hl;
  hl = /* tag */ typeof l === "number" || typeof l === "string" ? 0 : l.h;
  let hr;
  hr = /* tag */ typeof r === "number" || typeof r === "string" ? 0 : r.h;
  if (hl > (hr + 2 | 0)) {
    if (/* tag */ typeof l === "number" || typeof l === "string") {
      throw new Caml_js_exceptions.MelangeError("Invalid_argument", {
          MEL_EXN_ID: "Invalid_argument",
          _1: "Map.bal"
        });
    }
    const lr = l.r;
    const ld = l.d;
    const lv = l.v;
    const ll = l.l;
    if (height(ll) >= height(lr)) {
      return create(ll, lv, ld, create(lr, x, d, r));
    }
    if (!/* tag */ (typeof lr === "number" || typeof lr === "string")) {
      return create(create(ll, lv, ld, lr.l), lr.v, lr.d, create(lr.r, x, d, r));
    }
    throw new Caml_js_exceptions.MelangeError("Invalid_argument", {
        MEL_EXN_ID: "Invalid_argument",
        _1: "Map.bal"
      });
  }
  if (hr <= (hl + 2 | 0)) {
    return {
      TAG: /* Node */ 0,
      l: l,
      v: x,
      d: d,
      r: r,
      h: hl >= hr ? hl + 1 | 0 : hr + 1 | 0
    };
  }
  if (/* tag */ typeof r === "number" || typeof r === "string") {
    throw new Caml_js_exceptions.MelangeError("Invalid_argument", {
        MEL_EXN_ID: "Invalid_argument",
        _1: "Map.bal"
      });
  }
  const rr = r.r;
  const rd = r.d;
  const rv = r.v;
  const rl = r.l;
  if (height(rr) >= height(rl)) {
    return create(create(l, x, d, rl), rv, rd, rr);
  }
  if (!/* tag */ (typeof rl === "number" || typeof rl === "string")) {
    return create(create(l, x, d, rl.l), rl.v, rl.d, create(rl.r, rv, rd, rr));
  }
  throw new Caml_js_exceptions.MelangeError("Invalid_argument", {
      MEL_EXN_ID: "Invalid_argument",
      _1: "Map.bal"
    });
}

function add(x, data, m) {
  if (/* tag */ typeof m === "number" || typeof m === "string") {
    return {
      TAG: /* Node */ 0,
      l: /* Empty */ 0,
      v: x,
      d: data,
      r: /* Empty */ 0,
      h: 1
    };
  }
  const r = m.r;
  const d = m.d;
  const v = m.v;
  const l = m.l;
  const c = Curry._2(funarg.compare, x, v);
  if (c === 0) {
    if (d === data) {
      return m;
    } else {
      return {
        TAG: /* Node */ 0,
        l: l,
        v: x,
        d: data,
        r: r,
        h: m.h
      };
    }
  }
  if (c < 0) {
    const ll = add(x, data, l);
    if (l === ll) {
      return m;
    } else {
      return bal(ll, v, d, r);
    }
  }
  const rr = add(x, data, r);
  if (r === rr) {
    return m;
  } else {
    return bal(l, v, d, rr);
  }
}

function find(x, _param) {
  while (true) {
    const param = _param;
    if (/* tag */ typeof param === "number" || typeof param === "string") {
      throw new Caml_js_exceptions.MelangeError(Stdlib.Not_found, {
          MEL_EXN_ID: Stdlib.Not_found
        });
    }
    const c = Curry._2(funarg.compare, x, param.v);
    if (c === 0) {
      return param.d;
    }
    _param = c < 0 ? param.l : param.r;
    continue;
  };
}

function timing(label, f) {
  console.time(label);
  Curry._1(f, undefined);
  console.timeEnd(label);
}

function assertion_test(param) {
  const m = {
    contents: /* Empty */ 0
  };
  timing("building", (function (param) {
    for (let i = 0; i <= 1000000; ++i) {
      m.contents = Curry._3(add, String(i), String(i), m.contents);
    }
  }));
  timing("querying", (function (param) {
    for (let i = 0; i <= 1000000; ++i) {
      Curry._2(find, String(i), m.contents);
    }
  }));
}

module.exports = {
  assertion_test,
}
/* StringMap Not a pure module */
