'use strict';

var Mt = require("./mt.js");
var $$Set = require("melange/jscomp/stdlib-412/stdlib_modules/set.js");
var Caml = require("melange/lib/js/caml.js");
var Curry = require("melange/lib/js/curry.js");

function even(n) {
  if (n === 0) {
    return true;
  } else if (n === 1) {
    return false;
  } else {
    return Curry._1(B.odd, n - 1 | 0);
  }
}

var A = {
  even: even
};

function odd(n) {
  if (n === 1) {
    return true;
  } else if (n === 0) {
    return false;
  } else {
    return Curry._1(A.even, n - 1 | 0);
  }
}

var B = {
  odd: odd
};

function even$1(n) {
  if (n === 0) {
    return true;
  } else if (n === 1) {
    return false;
  } else {
    return Curry._1(BB.odd, n - 1 | 0);
  }
}

function x(param) {
  return Curry._1(BB.y, undefined) + 3 | 0;
}

var AA = {
  even: even$1,
  x: x
};

function odd$1(n) {
  if (n === 1) {
    return true;
  } else if (n === 0) {
    return false;
  } else {
    return Curry._1(even$1, n - 1 | 0);
  }
}

function y(param) {
  return 32;
}

var BB = {
  odd: odd$1,
  y: y
};

var Even = {};

var Odd = {};

function compare(t1, t2) {
  if (t1.TAG === /* Leaf */0) {
    if (t2.TAG === /* Leaf */0) {
      return Caml.caml_string_compare(t1._0, t2._0);
    } else {
      return 1;
    }
  } else if (t2.TAG === /* Leaf */0) {
    return -1;
  } else {
    return Curry._2(ASet.compare, t1._0, t2._0);
  }
}

var AAA = {
  compare: compare
};

var ASet = $$Set.Make(AAA);

var suites_0 = [
  "test1",
  (function (param) {
      return {
              TAG: /* Eq */0,
              _0: [
                true,
                true,
                false,
                false
              ],
              _1: [
                Curry._1(A.even, 2),
                Curry._1(even$1, 4),
                Curry._1(B.odd, 2),
                Curry._1(odd$1, 4)
              ]
            };
    })
];

var suites_1 = {
  hd: [
    "test2",
    (function (param) {
        return {
                TAG: /* Eq */0,
                _0: Curry._1(y, undefined),
                _1: 32
              };
      })
  ],
  tl: {
    hd: [
      "test3",
      (function (param) {
          return {
                  TAG: /* Eq */0,
                  _0: Curry._1(x, undefined),
                  _1: 35
                };
        })
    ],
    tl: {
      hd: [
        "test4",
        (function (param) {
            return {
                    TAG: /* Eq */0,
                    _0: true,
                    _1: Curry._1(A.even, 2)
                  };
          })
      ],
      tl: {
        hd: [
          "test4",
          (function (param) {
              return {
                      TAG: /* Eq */0,
                      _0: true,
                      _1: Curry._1(even$1, 4)
                    };
            })
        ],
        tl: {
          hd: [
            "test5",
            (function (param) {
                return {
                        TAG: /* Eq */0,
                        _0: false,
                        _1: Curry._1(B.odd, 2)
                      };
              })
          ],
          tl: {
            hd: [
              "test6",
              (function (param) {
                  return {
                          TAG: /* Eq */0,
                          _0: 2,
                          _1: Curry._1(ASet.cardinal, Curry._1(ASet.of_list, {
                                    hd: {
                                      TAG: /* Leaf */0,
                                      _0: "a"
                                    },
                                    tl: {
                                      hd: {
                                        TAG: /* Leaf */0,
                                        _0: "b"
                                      },
                                      tl: {
                                        hd: {
                                          TAG: /* Leaf */0,
                                          _0: "a"
                                        },
                                        tl: /* [] */0
                                      }
                                    }
                                  }))
                        };
                })
            ],
            tl: /* [] */0
          }
        }
      }
    }
  }
};

var suites = {
  hd: suites_0,
  tl: suites_1
};

Mt.from_pair_suites("Rec_module_test", suites);

exports.A = A;
exports.B = B;
exports.AA = AA;
exports.BB = BB;
exports.Even = Even;
exports.Odd = Odd;
exports.AAA = AAA;
exports.ASet = ASet;
exports.suites = suites;
/* ASet Not a pure module */
