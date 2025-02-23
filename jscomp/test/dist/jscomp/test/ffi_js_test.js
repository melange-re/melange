// Generated by Melange
'use strict';

const Mt = require("./mt.js");

const keys = (function (x){return Object.keys(x)}
);

function $$higher_order(x){
   return function(y,z){
      return x + y + z
   }
  }
;

const suites = {
  contents: /* [] */ 0
};

const test_id = {
  contents: 0
};

function eq(loc, param) {
  const y = param[1];
  const x = param[0];
  test_id.contents = test_id.contents + 1 | 0;
  suites.contents = {
    hd: [
      loc + (" id " + String(test_id.contents)),
      (function (param) {
        return {
          TAG: /* Eq */ 0,
          _0: x,
          _1: y
        };
      })
    ],
    tl: suites.contents
  };
}

const int_config = {
  hi: 3,
  low: 32
};

const string_config = {
  hi: 3,
  low: "32"
};

eq("File \"jscomp/test/ffi_js_test.ml\", line 32, characters 5-12", [
  6,
  $$higher_order(1)(2, 3)
]);

const same_type_0 = {
  hd: int_config,
  tl: {
    hd: {
      hi: 3,
      low: 32
    },
    tl: /* [] */ 0
  }
};

const same_type_1 = {
  hd: string_config,
  tl: {
    hd: {
      hi: 3,
      low: "32"
    },
    tl: /* [] */ 0
  }
};

const same_type = [
  same_type_0,
  same_type_1
];

const v_obj = {
  hi: (function () {
    console.log("hei");
  })
};

eq("File \"jscomp/test/ffi_js_test.ml\", line 44, characters 5-12", [
  Object.keys(int_config).length,
  2
]);

eq("File \"jscomp/test/ffi_js_test.ml\", line 45, characters 5-12", [
  Object.keys(string_config).length,
  2
]);

eq("File \"jscomp/test/ffi_js_test.ml\", line 46, characters 5-12", [
  Object.keys(v_obj).indexOf("hi_x", undefined),
  -1
]);

eq("File \"jscomp/test/ffi_js_test.ml\", line 47, characters 5-12", [
  Object.keys(v_obj).indexOf("hi", undefined),
  0
]);

const u = {
  contents: 3
};

const side_effect_config = (u.contents = u.contents + 1 | 0, {
  hi: 3,
  low: 32
});

eq("File \"jscomp/test/ffi_js_test.ml\", line 54, characters 5-12", [
  u.contents,
  4
]);

function vv(z) {
  return z.hh();
}

function v(z) {
  return z.ff();
}

function vvv(z) {
  return z.ff_pipe();
}

function vvvv(z) {
  return z.ff_pipe2();
}

function create_prim(param) {
  return {
    "x'": 3,
    "x''": 3,
    "x''''": 2
  };
}

function ffff(x) {
  x.setGADT = 3;
  x.setGADT2 = [
    3,
    "3"
  ];
  x.setGADT2 = [
    "3",
    3
  ];
  const match = x[3];
  console.log([
    match[0],
    match[1]
  ]);
  console.log(x.getGADT);
  const match$1 = x.getGADT2;
  console.log(match$1[0], match$1[1]);
  const match$2 = x[0];
  console.log(match$2[0], match$2[1]);
  x[0] = [
    1,
    "x"
  ];
  x[3] = [
    3,
    "x"
  ];
}

Mt.from_pair_suites("Ffi_js_test", suites.contents);

module.exports = {
  keys,
  suites,
  test_id,
  eq,
  int_config,
  string_config,
  same_type,
  v_obj,
  u,
  side_effect_config,
  vv,
  v,
  vvv,
  vvvv,
  create_prim,
  ffff,
}
/*  Not a pure module */
