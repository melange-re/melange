// Generated by Melange
'use strict';

const Caml_js_exceptions = require("melange.js/caml_js_exceptions.js");
const Rbset = require("./rbset.js");

function bench(param) {
  let data = /* Empty */ 0;
  console.time("bs_rbset_int_bench.ml 7");
  for (let i = 0; i <= 1000000; ++i) {
    data = Rbset.add(i, data);
  }
  console.timeEnd("bs_rbset_int_bench.ml 7");
  console.time("bs_rbset_int_bench.ml 11");
  for (let i$1 = 0; i$1 <= 1000000; ++i$1) {
    if (!Rbset.mem(i$1, data)) {
      throw new Caml_js_exceptions.MelangeError("Assert_failure", {
          MEL_EXN_ID: "Assert_failure",
          _1: [
            "jscomp/test/bs_rbset_int_bench.ml",
            12,
            4
          ]
        });
    }
    
  }
  console.timeEnd("bs_rbset_int_bench.ml 11");
  console.time("bs_rbset_int_bench.ml 14");
  for (let i$2 = 0; i$2 <= 1000000; ++i$2) {
    data = Rbset.remove(i$2, data);
  }
  console.timeEnd("bs_rbset_int_bench.ml 14");
  if (Rbset.cardinal(data) === 0) {
    return;
  }
  throw new Caml_js_exceptions.MelangeError("Assert_failure", {
      MEL_EXN_ID: "Assert_failure",
      _1: [
        "jscomp/test/bs_rbset_int_bench.ml",
        17,
        2
      ]
    });
}

console.time("bs_rbset_int_bench.ml 21");

bench(undefined);

console.timeEnd("bs_rbset_int_bench.ml 21");

const count = 1000000;

module.exports = {
  count,
  bench,
}
/*  Not a pure module */
