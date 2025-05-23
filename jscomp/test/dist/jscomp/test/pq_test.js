// Generated by Melange
'use strict';

const Caml_exceptions = require("melange.js/caml_exceptions.js");
const Caml_js_exceptions = require("melange.js/caml_js_exceptions.js");

function insert(queue, prio, elt) {
  if (/* tag */ typeof queue === "number" || typeof queue === "string") {
    return {
      TAG: /* Node */ 0,
      _0: prio,
      _1: elt,
      _2: /* Empty */ 0,
      _3: /* Empty */ 0
    };
  }
  const right = queue._3;
  const left = queue._2;
  const e = queue._1;
  const p = queue._0;
  if (prio <= p) {
    return {
      TAG: /* Node */ 0,
      _0: prio,
      _1: elt,
      _2: insert(right, p, e),
      _3: left
    };
  } else {
    return {
      TAG: /* Node */ 0,
      _0: p,
      _1: e,
      _2: insert(right, prio, elt),
      _3: left
    };
  }
}

const Queue_is_empty = /* @__PURE__ */ Caml_exceptions.create("Pq_test.PrioQueue.Queue_is_empty");

function remove_top(param) {
  if (/* tag */ typeof param === "number" || typeof param === "string") {
    throw new Caml_js_exceptions.MelangeError(Queue_is_empty, {
        MEL_EXN_ID: Queue_is_empty
      });
  }
  const left = param._2;
  let tmp = param._3;
  if (/* tag */ typeof tmp === "number" || typeof tmp === "string") {
    return left;
  }
  if (/* tag */ typeof left === "number" || typeof left === "string") {
    return param._3;
  }
  const right = param._3;
  const rprio = right._0;
  const lprio = left._0;
  if (lprio <= rprio) {
    return {
      TAG: /* Node */ 0,
      _0: lprio,
      _1: left._1,
      _2: remove_top(left),
      _3: right
    };
  } else {
    return {
      TAG: /* Node */ 0,
      _0: rprio,
      _1: right._1,
      _2: left,
      _3: remove_top(right)
    };
  }
}

function extract(queue) {
  if (!/* tag */ (typeof queue === "number" || typeof queue === "string")) {
    return [
      queue._0,
      queue._1,
      remove_top(queue)
    ];
  }
  throw new Caml_js_exceptions.MelangeError(Queue_is_empty, {
      MEL_EXN_ID: Queue_is_empty
    });
}

const PrioQueue = {
  empty: /* Empty */ 0,
  insert: insert,
  Queue_is_empty: Queue_is_empty,
  remove_top: remove_top,
  extract: extract
};

module.exports = {
  PrioQueue,
}
/* No side effect */
