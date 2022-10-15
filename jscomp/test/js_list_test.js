'use strict';

var Mt = require("./mt.js");
var Js_list = require("melange/jscomp/others/js_list.js");

var suites = {
  contents: /* [] */0
};

var test_id = {
  contents: 0
};

function eq(loc, x, y) {
  test_id.contents = test_id.contents + 1 | 0;
  suites.contents = {
    hd: [
      loc + (" id " + String(test_id.contents)),
      (function (param) {
          return {
                  TAG: /* Eq */0,
                  _0: x,
                  _1: y
                };
        })
    ],
    tl: suites.contents
  };
}

eq("File \"js_list_test.ml\", line 11, characters 7-14", Js_list.flatten({
          hd: {
            hd: 1,
            tl: {
              hd: 2,
              tl: /* [] */0
            }
          },
          tl: {
            hd: {
              hd: 3,
              tl: /* [] */0
            },
            tl: {
              hd: /* [] */0,
              tl: {
                hd: {
                  hd: 1,
                  tl: {
                    hd: 2,
                    tl: {
                      hd: 3,
                      tl: /* [] */0
                    }
                  }
                },
                tl: /* [] */0
              }
            }
          }
        }), {
      hd: 1,
      tl: {
        hd: 2,
        tl: {
          hd: 3,
          tl: {
            hd: 1,
            tl: {
              hd: 2,
              tl: {
                hd: 3,
                tl: /* [] */0
              }
            }
          }
        }
      }
    });

eq("File \"js_list_test.ml\", line 14, characters 7-14", Js_list.filterMap((function (x) {
            if (x % 2 === 0) {
              return x;
            }
            
          }), {
          hd: 1,
          tl: {
            hd: 2,
            tl: {
              hd: 3,
              tl: {
                hd: 4,
                tl: {
                  hd: 5,
                  tl: {
                    hd: 6,
                    tl: {
                      hd: 7,
                      tl: /* [] */0
                    }
                  }
                }
              }
            }
          }
        }), {
      hd: 2,
      tl: {
        hd: 4,
        tl: {
          hd: 6,
          tl: /* [] */0
        }
      }
    });

eq("File \"js_list_test.ml\", line 17, characters 7-14", Js_list.filterMap((function (x) {
            if (x % 2 === 0) {
              return x;
            }
            
          }), {
          hd: 1,
          tl: {
            hd: 2,
            tl: {
              hd: 3,
              tl: {
                hd: 4,
                tl: {
                  hd: 5,
                  tl: {
                    hd: 6,
                    tl: /* [] */0
                  }
                }
              }
            }
          }
        }), {
      hd: 2,
      tl: {
        hd: 4,
        tl: {
          hd: 6,
          tl: /* [] */0
        }
      }
    });

eq("File \"js_list_test.ml\", line 20, characters 7-14", Js_list.countBy((function (x) {
            return x % 2 === 0;
          }), {
          hd: 1,
          tl: {
            hd: 2,
            tl: {
              hd: 3,
              tl: {
                hd: 4,
                tl: {
                  hd: 5,
                  tl: {
                    hd: 6,
                    tl: /* [] */0
                  }
                }
              }
            }
          }
        }), 3);

var v = Js_list.init(100000, (function (i) {
        return i;
      }));

eq("File \"js_list_test.ml\", line 23, characters 7-14", Js_list.countBy((function (x) {
            return x % 2 === 0;
          }), v), 50000);

var vv = Js_list.foldRight(Js_list.cons, v, /* [] */0);

eq("File \"js_list_test.ml\", line 27, characters 7-14", true, Js_list.equal((function (x, y) {
            return x === y;
          }), v, vv));

var vvv = Js_list.filter((function (x) {
        return x % 10 === 0;
      }), vv);

eq("File \"js_list_test.ml\", line 31, characters 7-14", Js_list.length(vvv), 10000);

eq("File \"js_list_test.ml\", line 32, characters 7-14", true, Js_list.equal((function (x, y) {
            return x === y;
          }), vvv, Js_list.init(10000, (function (x) {
                return Math.imul(x, 10);
              }))));

Mt.from_pair_suites("Js_list_test", suites.contents);

exports.suites = suites;
exports.test_id = test_id;
exports.eq = eq;
/*  Not a pure module */
