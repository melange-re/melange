'use strict';

var Mt = require("./mt.js");
var Curry = require("../../lib/js/curry.js");
var Caml_oo_curry = require("../../lib/js/caml_oo_curry.js");
var CamlinternalOO = require("../../lib/js/camlinternalOO.js");

function f(u) {
  return Caml_oo_curry.js2(5740587, 1, u, 32);
}

function f_js(u) {
  return u.say(32);
}

var object_tables = /* Cons */{
  key: undefined,
  data: undefined,
  next: undefined
};

var suites_0 = [
  "caml_obj",
  (function (param) {
      if (!object_tables.key) {
        var $$class = CamlinternalOO.create_table(["say"]);
        var env = CamlinternalOO.new_variable($$class, "");
        var say = CamlinternalOO.get_method_label($$class, "say");
        CamlinternalOO.set_method($$class, say, (function (self$1, x) {
                return 1 + x | 0;
              }));
        var env_init = function (env$1) {
          var self = CamlinternalOO.create_object_opt(undefined, $$class);
          self[env] = env$1;
          return self;
        };
        CamlinternalOO.init_class($$class);
        object_tables.key = env_init;
      }
      return {
              TAG: /* Eq */0,
              _0: 33,
              _1: f(Curry._1(object_tables.key, undefined))
            };
    })
];

var suites_1 = {
  hd: [
    "js_obj",
    (function (param) {
        return {
                TAG: /* Eq */0,
                _0: 34,
                _1: ({
                      say: (function (x) {
                          return x + 2 | 0;
                        })
                    }).say(32)
              };
      })
  ],
  tl: {
    hd: [
      "js_obj2",
      (function (param) {
          return {
                  TAG: /* Eq */0,
                  _0: 34,
                  _1: ({
                        say: (function (x) {
                            return x + 2 | 0;
                          })
                      }).say(32)
                };
        })
    ],
    tl: {
      hd: [
        "empty",
        (function (param) {
            return {
                    TAG: /* Eq */0,
                    _0: 0,
                    _1: Object.keys({}).length
                  };
          })
      ],
      tl: {
        hd: [
          "assign",
          (function (param) {
              return {
                      TAG: /* Eq */0,
                      _0: {
                        a: 1
                      },
                      _1: Object.assign({}, {
                            a: 1
                          })
                    };
            })
        ],
        tl: /* [] */0
      }
    }
  }
};

var suites = {
  hd: suites_0,
  tl: suites_1
};

Mt.from_pair_suites("Js_obj_test", suites);

exports.f = f;
exports.f_js = f_js;
exports.suites = suites;
/*  Not a pure module */
