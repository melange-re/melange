'use strict';

var Mt = require("./mt.js");
var Curry = require("../../lib/js/curry.js");
var Caml_oo = require("../../lib/js/caml_oo.js");
var Caml_obj = require("../../lib/js/caml_obj.js");
var Caml_option = require("../../lib/js/caml_option.js");
var Caml_oo_curry = require("../../lib/js/caml_oo_curry.js");
var CamlinternalOO = require("../../lib/js/camlinternalOO.js");

var shared = ["copy"];

var shared$1 = [
  "get",
  "set"
];

var shared$2 = ["window"];

var shared$3 = ["x"];

var shared$4 = ["top_widget"];

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

function point_init($$class) {
  var x_init = CamlinternalOO.new_variable($$class, "");
  var ids = CamlinternalOO.new_methods_variables($$class, [
        "move",
        "get_x",
        "*dummy method*"
      ], shared$3);
  var move = ids[0];
  var get_x = ids[1];
  var x = ids[3];
  CamlinternalOO.set_methods($$class, [
        get_x,
        (function (self$1) {
            return self$1[x];
          }),
        move,
        (function (self$1, d) {
            self$1[x] = self$1[x] + d | 0;
            
          })
      ]);
  return function (env, self, x_init$1) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[x_init] = x_init$1;
    self$1[x] = x_init$1;
    return self$1;
  };
}

var point = CamlinternalOO.make_class([
      "move",
      "get_x"
    ], point_init);

var p = Curry._2(point[0], undefined, 55);

var q = Caml_oo.caml_set_oo_id(Caml_obj.caml_obj_dup(p));

Caml_oo_curry.js2(-933174511, 1, q, 7);

eq("File \"class7_test.ml\", line 22, characters 5-12", [
      55,
      62
    ], [
      Caml_oo_curry.js1(291546447, 2, p),
      Caml_oo_curry.js1(291546447, 3, q)
    ]);

function ref_init($$class) {
  var x_init = CamlinternalOO.new_variable($$class, "");
  var ids = CamlinternalOO.new_methods_variables($$class, [
        "set",
        "get",
        "*dummy method*"
      ], shared$3);
  var set = ids[0];
  var get = ids[1];
  var x = ids[3];
  CamlinternalOO.set_methods($$class, [
        get,
        (function (self$2) {
            return self$2[x];
          }),
        set,
        (function (self$2, y) {
            self$2[x] = y;
            
          })
      ]);
  return function (env, self, x_init$1) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[x_init] = x_init$1;
    self$1[x] = x_init$1;
    return self$1;
  };
}

var ref = CamlinternalOO.make_class(shared$1, ref_init);

function backup_init($$class) {
  var ids = CamlinternalOO.new_methods_variables($$class, [
        "save",
        "restore",
        "*dummy method*"
      ], shared);
  var save = ids[0];
  var restore = ids[1];
  var copy = ids[3];
  CamlinternalOO.set_methods($$class, [
        save,
        (function (self$3) {
            var copy$1 = Caml_oo.caml_set_oo_id(Caml_obj.caml_obj_dup(self$3));
            self$3[copy] = Caml_option.some((copy$1[copy] = undefined, copy$1));
            
          }),
        restore,
        (function (self$3) {
            var x = self$3[copy];
            if (x !== undefined) {
              return Caml_option.valFromOption(x);
            } else {
              return self$3;
            }
          })
      ]);
  return function (env, self) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[copy] = undefined;
    return self$1;
  };
}

var backup = CamlinternalOO.make_class([
      "save",
      "restore"
    ], backup_init);

function backup_ref_init($$class) {
  var x = CamlinternalOO.new_variable($$class, "");
  CamlinternalOO.get_method_labels($$class, [
        "set",
        "save",
        "restore",
        "get",
        "*dummy method*"
      ]);
  var inh = CamlinternalOO.inherits($$class, shared$3, 0, shared$1, ref, true);
  var obj_init = inh[0];
  var inh$1 = CamlinternalOO.inherits($$class, shared, 0, [
        "restore",
        "save"
      ], backup, true);
  var obj_init$1 = inh$1[0];
  return function (env, self, x$1) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[x] = x$1;
    Curry._2(obj_init, self$1, x$1);
    Curry._1(obj_init$1, self$1);
    return CamlinternalOO.run_initializers_opt(self, self$1, $$class);
  };
}

var backup_ref = CamlinternalOO.make_class([
      "save",
      "restore",
      "get",
      "set"
    ], backup_ref_init);

function get(_p, _n) {
  while(true) {
    var n = _n;
    var p = _p;
    if (n === 0) {
      return Caml_oo_curry.js1(5144726, 6, p);
    }
    _n = n - 1 | 0;
    _p = Caml_oo_curry.js1(-357537970, 7, p);
    continue ;
  };
}

var p$1 = Curry._2(backup_ref[0], undefined, 0);

Caml_oo_curry.js1(-867333315, 8, p$1);

Caml_oo_curry.js2(5741474, 9, p$1, 1);

Caml_oo_curry.js1(-867333315, 10, p$1);

Caml_oo_curry.js2(5741474, 11, p$1, 2);

eq("File \"class7_test.ml\", line 47, characters 5-12", [
      2,
      1,
      1,
      1,
      1
    ], [
      get(p$1, 0),
      get(p$1, 1),
      get(p$1, 2),
      get(p$1, 3),
      get(p$1, 4)
    ]);

function backup2_init($$class) {
  var ids = CamlinternalOO.new_methods_variables($$class, [
        "save",
        "restore",
        "clear",
        "*dummy method*"
      ], shared);
  var save = ids[0];
  var restore = ids[1];
  var clear = ids[2];
  var copy = ids[4];
  CamlinternalOO.set_methods($$class, [
        save,
        (function (self$5) {
            self$5[copy] = Caml_option.some(Caml_oo.caml_set_oo_id(Caml_obj.caml_obj_dup(self$5)));
            
          }),
        restore,
        (function (self$5) {
            var x = self$5[copy];
            if (x !== undefined) {
              return Caml_option.valFromOption(x);
            } else {
              return self$5;
            }
          }),
        clear,
        (function (self$5) {
            self$5[copy] = undefined;
            
          })
      ]);
  return function (env, self) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[copy] = undefined;
    return self$1;
  };
}

var backup2 = CamlinternalOO.make_class([
      "clear",
      "save",
      "restore"
    ], backup2_init);

function backup_ref2_init($$class) {
  var x = CamlinternalOO.new_variable($$class, "");
  CamlinternalOO.get_method_labels($$class, [
        "set",
        "save",
        "restore",
        "get",
        "clear",
        "*dummy method*"
      ]);
  var inh = CamlinternalOO.inherits($$class, shared$3, 0, shared$1, ref, true);
  var obj_init = inh[0];
  var inh$1 = CamlinternalOO.inherits($$class, shared, 0, [
        "clear",
        "restore",
        "save"
      ], backup2, true);
  var obj_init$1 = inh$1[0];
  return function (env, self, x$1) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[x] = x$1;
    Curry._2(obj_init, self$1, x$1);
    Curry._1(obj_init$1, self$1);
    return CamlinternalOO.run_initializers_opt(self, self$1, $$class);
  };
}

var backup_ref2 = CamlinternalOO.make_class([
      "clear",
      "save",
      "restore",
      "get",
      "set"
    ], backup_ref2_init);

var p$2 = Curry._2(backup_ref2[0], undefined, 0);

Caml_oo_curry.js1(-867333315, 12, p$2);

Caml_oo_curry.js2(5741474, 13, p$2, 1);

Caml_oo_curry.js1(-867333315, 14, p$2);

Caml_oo_curry.js2(5741474, 15, p$2, 2);

eq("File \"class7_test.ml\", line 63, characters 5-12", [
      2,
      1,
      0,
      0,
      0
    ], [
      get(p$2, 0),
      get(p$2, 1),
      get(p$2, 2),
      get(p$2, 3),
      get(p$2, 4)
    ]);

function window_init($$class) {
  var ids = CamlinternalOO.new_methods_variables($$class, [
        "top_widget",
        "*dummy method*"
      ], shared$4);
  var top_widget = ids[0];
  var top_widget$1 = ids[2];
  CamlinternalOO.set_method($$class, top_widget, (function (self$7) {
          return self$7[top_widget$1];
        }));
  return function (env, self) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[top_widget$1] = undefined;
    return self$1;
  };
}

var $$window = CamlinternalOO.make_class(shared$4, window_init);

function widget_init($$class) {
  var w = CamlinternalOO.new_variable($$class, "");
  var ids = CamlinternalOO.new_methods_variables($$class, [
        "window",
        "*dummy method*"
      ], shared$2);
  var $$window = ids[0];
  var $$window$1 = ids[2];
  CamlinternalOO.set_method($$class, $$window, (function (self$8) {
          return self$8[$$window$1];
        }));
  return function (env, self, w$1) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[w] = w$1;
    self$1[$$window$1] = w$1;
    return self$1;
  };
}

var widget = CamlinternalOO.make_class(shared$2, widget_init);

Mt.from_pair_suites("Class7_test", suites.contents);

exports.suites = suites;
exports.test_id = test_id;
exports.eq = eq;
exports.point = point;
exports.ref = ref;
exports.backup = backup;
exports.backup_ref = backup_ref;
exports.get = get;
exports.backup2 = backup2;
exports.backup_ref2 = backup_ref2;
exports.$$window = $$window;
exports.widget = widget;
/* point Not a pure module */
