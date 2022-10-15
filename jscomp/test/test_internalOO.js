'use strict';

var $$Map = require("melange/lib/js/map.js");
var Sys = require("melange/lib/js/sys.js");
var Caml = require("melange/lib/js/caml.js");
var List = require("melange/lib/js/list.js");
var $$Array = require("melange/lib/js/array.js");
var Curry = require("melange/lib/js/curry.js");
var Stdlib = require("melange/lib/js/stdlib.js");
var Caml_oo = require("melange/lib/js/caml_oo.js");
var Caml_obj = require("melange/lib/js/caml_obj.js");
var Caml_array = require("melange/lib/js/caml_array.js");
var Caml_int32 = require("melange/lib/js/caml_int32.js");
var Caml_string = require("melange/lib/js/caml_string.js");
var Caml_js_exceptions = require("melange/lib/js/caml_js_exceptions.js");

function copy(o) {
  return Caml_oo.caml_set_oo_id(Caml_obj.caml_obj_dup(o));
}

var params = {
  compact_table: true,
  copy_parent: true,
  clean_when_copying: true,
  retry_count: 3,
  bucket_small_size: 16
};

var step = Sys.word_size / 16 | 0;

function public_method_label(s) {
  var accu = 0;
  for(var i = 0 ,i_finish = s.length; i < i_finish; ++i){
    accu = Math.imul(223, accu) + Caml_string.get(s, i) | 0;
  }
  accu = accu & 2147483647;
  if (accu > 1073741823) {
    return accu - -2147483648 | 0;
  } else {
    return accu;
  }
}

var compare = Caml.caml_string_compare;

var Vars = $$Map.Make({
      compare: compare
    });

var compare$1 = Caml.caml_string_compare;

var Meths = $$Map.Make({
      compare: compare$1
    });

var compare$2 = Caml.caml_int_compare;

var Labs = $$Map.Make({
      compare: compare$2
    });

var dummy_table = {
  size: 0,
  methods: [undefined],
  methods_by_name: Meths.empty,
  methods_by_label: Labs.empty,
  previous_states: /* [] */0,
  hidden_meths: /* [] */0,
  vars: Vars.empty,
  initializers: /* [] */0
};

var table_count = {
  contents: 0
};

function fit_size(n) {
  if (n <= 2) {
    return n;
  } else {
    return (fit_size((n + 1 | 0) / 2 | 0) << 1);
  }
}

function new_table(pub_labels) {
  table_count.contents = table_count.contents + 1 | 0;
  var len = pub_labels.length;
  var methods = Caml_array.make((len << 1) + 2 | 0, /* DummyA */0);
  Caml_array.set(methods, 0, len);
  Caml_array.set(methods, 1, (Math.imul(fit_size(len), Sys.word_size) / 8 | 0) - 1 | 0);
  for(var i = 0; i < len; ++i){
    Caml_array.set(methods, (i << 1) + 3 | 0, Caml_array.get(pub_labels, i));
  }
  return {
          size: 2,
          methods: methods,
          methods_by_name: Meths.empty,
          methods_by_label: Labs.empty,
          previous_states: /* [] */0,
          hidden_meths: /* [] */0,
          vars: Vars.empty,
          initializers: /* [] */0
        };
}

function resize(array, new_size) {
  var old_size = array.methods.length;
  if (new_size <= old_size) {
    return ;
  }
  var new_buck = Caml_array.make(new_size, /* DummyA */0);
  $$Array.blit(array.methods, 0, new_buck, 0, old_size);
  array.methods = new_buck;
}

function put(array, label, element) {
  resize(array, label + 1 | 0);
  Caml_array.set(array.methods, label, element);
}

var method_count = {
  contents: 0
};

var inst_var_count = {
  contents: 0
};

function new_method(table) {
  var index = table.methods.length;
  resize(table, index + 1 | 0);
  return index;
}

function get_method_label(table, name) {
  try {
    return Curry._2(Meths.find, name, table.methods_by_name);
  }
  catch (raw_exn){
    var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
    if (exn.RE_EXN_ID === Stdlib.Not_found) {
      var label = new_method(table);
      table.methods_by_name = Curry._3(Meths.add, name, label, table.methods_by_name);
      table.methods_by_label = Curry._3(Labs.add, label, true, table.methods_by_label);
      return label;
    }
    throw exn;
  }
}

function get_method_labels(table, names) {
  return $$Array.map((function (param) {
                return get_method_label(table, param);
              }), names);
}

function set_method(table, label, element) {
  method_count.contents = method_count.contents + 1 | 0;
  if (Curry._2(Labs.find, label, table.methods_by_label)) {
    return put(table, label, element);
  } else {
    table.hidden_meths = {
      hd: [
        label,
        element
      ],
      tl: table.hidden_meths
    };
    return ;
  }
}

function get_method(table, label) {
  try {
    return List.assoc(label, table.hidden_meths);
  }
  catch (raw_exn){
    var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
    if (exn.RE_EXN_ID === Stdlib.Not_found) {
      return Caml_array.get(table.methods, label);
    }
    throw exn;
  }
}

function to_list(arr) {
  if (arr === 0) {
    return /* [] */0;
  } else {
    return $$Array.to_list(arr);
  }
}

function narrow(table, vars, virt_meths, concr_meths) {
  var vars$1 = to_list(vars);
  var virt_meths$1 = to_list(virt_meths);
  var concr_meths$1 = to_list(concr_meths);
  var virt_meth_labs = List.map((function (param) {
          return get_method_label(table, param);
        }), virt_meths$1);
  var concr_meth_labs = List.map((function (param) {
          return get_method_label(table, param);
        }), concr_meths$1);
  table.previous_states = {
    hd: [
      table.methods_by_name,
      table.methods_by_label,
      table.hidden_meths,
      table.vars,
      virt_meth_labs,
      vars$1
    ],
    tl: table.previous_states
  };
  table.vars = Curry._3(Vars.fold, (function (lab, info, tvars) {
          if (List.mem(lab, vars$1)) {
            return Curry._3(Vars.add, lab, info, tvars);
          } else {
            return tvars;
          }
        }), table.vars, Vars.empty);
  var by_name = {
    contents: Meths.empty
  };
  var by_label = {
    contents: Labs.empty
  };
  List.iter2((function (met, label) {
          by_name.contents = Curry._3(Meths.add, met, label, by_name.contents);
          var tmp;
          try {
            tmp = Curry._2(Labs.find, label, table.methods_by_label);
          }
          catch (raw_exn){
            var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
            if (exn.RE_EXN_ID === Stdlib.Not_found) {
              tmp = true;
            } else {
              throw exn;
            }
          }
          by_label.contents = Curry._3(Labs.add, label, tmp, by_label.contents);
        }), concr_meths$1, concr_meth_labs);
  List.iter2((function (met, label) {
          by_name.contents = Curry._3(Meths.add, met, label, by_name.contents);
          by_label.contents = Curry._3(Labs.add, label, false, by_label.contents);
        }), virt_meths$1, virt_meth_labs);
  table.methods_by_name = by_name.contents;
  table.methods_by_label = by_label.contents;
  table.hidden_meths = List.fold_right((function (met, hm) {
          if (List.mem(met[0], virt_meth_labs)) {
            return hm;
          } else {
            return {
                    hd: met,
                    tl: hm
                  };
          }
        }), table.hidden_meths, /* [] */0);
}

function widen(table) {
  var match = List.hd(table.previous_states);
  var virt_meths = match[4];
  table.previous_states = List.tl(table.previous_states);
  table.vars = List.fold_left((function (s, v) {
          return Curry._3(Vars.add, v, Curry._2(Vars.find, v, table.vars), s);
        }), match[3], match[5]);
  table.methods_by_name = match[0];
  table.methods_by_label = match[1];
  table.hidden_meths = List.fold_right((function (met, hm) {
          if (List.mem(met[0], virt_meths)) {
            return hm;
          } else {
            return {
                    hd: met,
                    tl: hm
                  };
          }
        }), table.hidden_meths, match[2]);
}

function new_slot(table) {
  var index = table.size;
  table.size = index + 1 | 0;
  return index;
}

function new_variable(table, name) {
  try {
    return Curry._2(Vars.find, name, table.vars);
  }
  catch (raw_exn){
    var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
    if (exn.RE_EXN_ID === Stdlib.Not_found) {
      var index = new_slot(table);
      if (name !== "") {
        table.vars = Curry._3(Vars.add, name, index, table.vars);
      }
      return index;
    }
    throw exn;
  }
}

function to_array(arr) {
  if (Caml_obj.caml_equal(arr, 0)) {
    return [];
  } else {
    return arr;
  }
}

function new_methods_variables(table, meths, vals) {
  var meths$1 = to_array(meths);
  var nmeths = meths$1.length;
  var nvals = vals.length;
  var res = Caml_array.make(nmeths + nvals | 0, 0);
  for(var i = 0; i < nmeths; ++i){
    Caml_array.set(res, i, get_method_label(table, Caml_array.get(meths$1, i)));
  }
  for(var i$1 = 0; i$1 < nvals; ++i$1){
    Caml_array.set(res, i$1 + nmeths | 0, new_variable(table, Caml_array.get(vals, i$1)));
  }
  return res;
}

function get_variable(table, name) {
  try {
    return Curry._2(Vars.find, name, table.vars);
  }
  catch (raw_exn){
    var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
    if (exn.RE_EXN_ID === Stdlib.Not_found) {
      throw {
            RE_EXN_ID: "Assert_failure",
            _1: [
              "test_internalOO.ml",
              280,
              50
            ],
            Error: new Error()
          };
    }
    throw exn;
  }
}

function get_variables(table, names) {
  return $$Array.map((function (param) {
                return get_variable(table, param);
              }), names);
}

function add_initializer(table, f) {
  table.initializers = {
    hd: f,
    tl: table.initializers
  };
}

function create_table(public_methods) {
  if (public_methods === 0) {
    return new_table([]);
  }
  var tags = $$Array.map(public_method_label, public_methods);
  var table = new_table(tags);
  $$Array.iteri((function (i, met) {
          var lab = (i << 1) + 2 | 0;
          table.methods_by_name = Curry._3(Meths.add, met, lab, table.methods_by_name);
          table.methods_by_label = Curry._3(Labs.add, lab, true, table.methods_by_label);
        }), public_methods);
  return table;
}

function init_class(table) {
  inst_var_count.contents = (inst_var_count.contents + table.size | 0) - 1 | 0;
  table.initializers = List.rev(table.initializers);
  resize(table, 3 + Caml_int32.div((Caml_array.get(table.methods, 1) << 4), Sys.word_size) | 0);
}

function inherits(cla, vals, virt_meths, concr_meths, param, top) {
  var $$super = param[1];
  narrow(cla, vals, virt_meths, concr_meths);
  var init = top ? Curry._2($$super, cla, param[3]) : Curry._1($$super, cla);
  widen(cla);
  return $$Array.concat({
              hd: [init],
              tl: {
                hd: $$Array.map((function (param) {
                        return get_variable(cla, param);
                      }), to_array(vals)),
                tl: {
                  hd: $$Array.map((function (nm) {
                          return get_method(cla, get_method_label(cla, nm));
                        }), to_array(concr_meths)),
                  tl: /* [] */0
                }
              }
            });
}

function make_class(pub_meths, class_init) {
  var table = create_table(pub_meths);
  var env_init = Curry._1(class_init, table);
  init_class(table);
  return [
          Curry._1(env_init, 0),
          class_init,
          env_init,
          0
        ];
}

function make_class_store(pub_meths, class_init, init_table) {
  var table = create_table(pub_meths);
  var env_init = Curry._1(class_init, table);
  init_class(table);
  init_table.class_init = class_init;
  init_table.env_init = env_init;
}

function dummy_class(loc) {
  var undef = function (param) {
    throw {
          RE_EXN_ID: Stdlib.Undefined_recursive_module,
          _1: loc,
          Error: new Error()
        };
  };
  return [
          undef,
          undef,
          undef,
          0
        ];
}

function iter_f(obj, _param) {
  while(true) {
    var param = _param;
    if (!param) {
      return ;
    }
    Curry._1(param.hd, obj);
    _param = param.tl;
    continue ;
  };
}

function run_initializers(obj, table) {
  var inits = table.initializers;
  if (Caml_obj.caml_notequal(inits, /* [] */0)) {
    return iter_f(obj, inits);
  }
  
}

function run_initializers_opt(obj_0, obj, table) {
  if (obj_0) {
    return obj;
  }
  var inits = table.initializers;
  if (Caml_obj.caml_notequal(inits, /* [] */0)) {
    iter_f(obj, inits);
  }
  return obj;
}

function build_path(n, keys, tables) {
  var res = {
    key: 0,
    data: /* Empty */0,
    next: /* Empty */0
  };
  var r = res;
  for(var i = 0; i <= n; ++i){
    r = /* Cons */{
      _0: Caml_array.get(keys, i),
      _1: r,
      _2: /* Empty */0
    };
  }
  tables.data = r;
  return res;
}

function lookup_keys(i, keys, tables) {
  if (i < 0) {
    return tables;
  }
  var key = Caml_array.get(keys, i);
  var _tables = tables;
  while(true) {
    var tables$1 = _tables;
    if (tables$1.key === key) {
      return lookup_keys(i - 1 | 0, keys, tables$1.data);
    }
    if (Caml_obj.caml_notequal(tables$1.next, /* Empty */0)) {
      _tables = tables$1.next;
      continue ;
    }
    var next = /* Cons */{
      _0: key,
      _1: /* Empty */0,
      _2: /* Empty */0
    };
    tables$1.next = next;
    return build_path(i - 1 | 0, keys, next);
  };
}

function lookup_tables(root, keys) {
  if (Caml_obj.caml_notequal(root.data, /* Empty */0)) {
    return lookup_keys(keys.length - 1 | 0, keys, root.data);
  } else {
    return build_path(keys.length - 1 | 0, keys, root);
  }
}

function get_const(x) {
  return function (obj) {
    return x;
  };
}

function get_var(n) {
  return function (obj) {
    return obj[n];
  };
}

function get_env(e, n) {
  return function (obj) {
    return obj[e][n];
  };
}

function get_meth(n) {
  return function (obj) {
    return Curry._1(obj[0][n], obj);
  };
}

function set_var(n) {
  return function (obj, x) {
    obj[n] = x;
  };
}

function app_const(f, x) {
  return function (obj) {
    return Curry._1(f, x);
  };
}

function app_var(f, n) {
  return function (obj) {
    return Curry._1(f, obj[n]);
  };
}

function app_env(f, e, n) {
  return function (obj) {
    return Curry._1(f, obj[e][n]);
  };
}

function app_meth(f, n) {
  return function (obj) {
    return Curry._1(f, Curry._1(obj[0][n], obj));
  };
}

function app_const_const(f, x, y) {
  return function (obj) {
    return Curry._2(f, x, y);
  };
}

function app_const_var(f, x, n) {
  return function (obj) {
    return Curry._2(f, x, obj[n]);
  };
}

function app_const_meth(f, x, n) {
  return function (obj) {
    return Curry._2(f, x, Curry._1(obj[0][n], obj));
  };
}

function app_var_const(f, n, x) {
  return function (obj) {
    return Curry._2(f, obj[n], x);
  };
}

function app_meth_const(f, n, x) {
  return function (obj) {
    return Curry._2(f, Curry._1(obj[0][n], obj), x);
  };
}

function app_const_env(f, x, e, n) {
  return function (obj) {
    return Curry._2(f, x, obj[e][n]);
  };
}

function app_env_const(f, e, n, x) {
  return function (obj) {
    return Curry._2(f, obj[e][n], x);
  };
}

function meth_app_const(n, x) {
  return function (obj) {
    return Curry._2(obj[0][n], obj, x);
  };
}

function meth_app_var(n, m) {
  return function (obj) {
    return Curry._2(obj[0][n], obj, obj[m]);
  };
}

function meth_app_env(n, e, m) {
  return function (obj) {
    return Curry._2(obj[0][n], obj, obj[e][m]);
  };
}

function meth_app_meth(n, m) {
  return function (obj) {
    return Curry._2(obj[0][n], obj, Curry._1(obj[0][m], obj));
  };
}

function send_const(m, x, c) {
  return function (obj) {
    return Curry._3(Curry._3(Caml_oo.caml_get_public_method, x, m, 1), x, obj[0], c);
  };
}

function send_var(m, n, c) {
  return function (obj) {
    var tmp = obj[n];
    return Curry._3(Curry._3(Caml_oo.caml_get_public_method, tmp, m, 2), tmp, obj[0], c);
  };
}

function send_env(m, e, n, c) {
  return function (obj) {
    var tmp = obj[e][n];
    return Curry._3(Curry._3(Caml_oo.caml_get_public_method, tmp, m, 3), tmp, obj[0], c);
  };
}

function send_meth(m, n, c) {
  return function (obj) {
    var tmp = Curry._1(obj[0][n], obj);
    return Curry._3(Curry._3(Caml_oo.caml_get_public_method, tmp, m, 4), tmp, obj[0], c);
  };
}

function new_cache(table) {
  var n = new_method(table);
  var n$1 = n % 2 === 0 || n > (2 + Caml_int32.div((Caml_array.get(table.methods, 1) << 4), Sys.word_size) | 0) ? n : new_method(table);
  Caml_array.set(table.methods, n$1, 0);
  return n$1;
}

function method_impl(table, i, arr) {
  var next = function (param) {
    i.contents = i.contents + 1 | 0;
    return Caml_array.get(arr, i.contents);
  };
  var clo = next(undefined);
  if (typeof clo !== "number") {
    return clo;
  }
  switch (clo) {
    case /* GetConst */0 :
        var x = next(undefined);
        return function (obj) {
          return x;
        };
    case /* GetVar */1 :
        var n = next(undefined);
        return function (obj) {
          return obj[n];
        };
    case /* GetEnv */2 :
        var e = next(undefined);
        var n$1 = next(undefined);
        return get_env(e, n$1);
    case /* GetMeth */3 :
        return get_meth(next(undefined));
    case /* SetVar */4 :
        var n$2 = next(undefined);
        return function (obj, x) {
          obj[n$2] = x;
        };
    case /* AppConst */5 :
        var f = next(undefined);
        var x$1 = next(undefined);
        return function (obj) {
          return Curry._1(f, x$1);
        };
    case /* AppVar */6 :
        var f$1 = next(undefined);
        var n$3 = next(undefined);
        return function (obj) {
          return Curry._1(f$1, obj[n$3]);
        };
    case /* AppEnv */7 :
        var f$2 = next(undefined);
        var e$1 = next(undefined);
        var n$4 = next(undefined);
        return app_env(f$2, e$1, n$4);
    case /* AppMeth */8 :
        var f$3 = next(undefined);
        var n$5 = next(undefined);
        return app_meth(f$3, n$5);
    case /* AppConstConst */9 :
        var f$4 = next(undefined);
        var x$2 = next(undefined);
        var y = next(undefined);
        return function (obj) {
          return Curry._2(f$4, x$2, y);
        };
    case /* AppConstVar */10 :
        var f$5 = next(undefined);
        var x$3 = next(undefined);
        var n$6 = next(undefined);
        return app_const_var(f$5, x$3, n$6);
    case /* AppConstEnv */11 :
        var f$6 = next(undefined);
        var x$4 = next(undefined);
        var e$2 = next(undefined);
        var n$7 = next(undefined);
        return app_const_env(f$6, x$4, e$2, n$7);
    case /* AppConstMeth */12 :
        var f$7 = next(undefined);
        var x$5 = next(undefined);
        var n$8 = next(undefined);
        return app_const_meth(f$7, x$5, n$8);
    case /* AppVarConst */13 :
        var f$8 = next(undefined);
        var n$9 = next(undefined);
        var x$6 = next(undefined);
        return app_var_const(f$8, n$9, x$6);
    case /* AppEnvConst */14 :
        var f$9 = next(undefined);
        var e$3 = next(undefined);
        var n$10 = next(undefined);
        var x$7 = next(undefined);
        return app_env_const(f$9, e$3, n$10, x$7);
    case /* AppMethConst */15 :
        var f$10 = next(undefined);
        var n$11 = next(undefined);
        var x$8 = next(undefined);
        return app_meth_const(f$10, n$11, x$8);
    case /* MethAppConst */16 :
        var n$12 = next(undefined);
        var x$9 = next(undefined);
        return meth_app_const(n$12, x$9);
    case /* MethAppVar */17 :
        var n$13 = next(undefined);
        var m = next(undefined);
        return meth_app_var(n$13, m);
    case /* MethAppEnv */18 :
        var n$14 = next(undefined);
        var e$4 = next(undefined);
        var m$1 = next(undefined);
        return meth_app_env(n$14, e$4, m$1);
    case /* MethAppMeth */19 :
        var n$15 = next(undefined);
        var m$2 = next(undefined);
        return meth_app_meth(n$15, m$2);
    case /* SendConst */20 :
        var m$3 = next(undefined);
        var x$10 = next(undefined);
        return send_const(m$3, x$10, new_cache(table));
    case /* SendVar */21 :
        var m$4 = next(undefined);
        var n$16 = next(undefined);
        return send_var(m$4, n$16, new_cache(table));
    case /* SendEnv */22 :
        var m$5 = next(undefined);
        var e$5 = next(undefined);
        var n$17 = next(undefined);
        return send_env(m$5, e$5, n$17, new_cache(table));
    case /* SendMeth */23 :
        var m$6 = next(undefined);
        var n$18 = next(undefined);
        return send_meth(m$6, n$18, new_cache(table));
    
  }
}

function set_methods(table, methods) {
  var len = methods.length;
  var i = {
    contents: 0
  };
  while(i.contents < len) {
    var label = Caml_array.get(methods, i.contents);
    var clo = method_impl(table, i, methods);
    set_method(table, label, clo);
    i.contents = i.contents + 1 | 0;
  };
}

function stats(param) {
  return {
          classes: table_count.contents,
          methods: method_count.contents,
          inst_vars: inst_var_count.contents
        };
}

var initial_object_size = 2;

var dummy_item;

var dummy_met = /* DummyA */0;

exports.copy = copy;
exports.params = params;
exports.step = step;
exports.initial_object_size = initial_object_size;
exports.dummy_item = dummy_item;
exports.public_method_label = public_method_label;
exports.Vars = Vars;
exports.Meths = Meths;
exports.Labs = Labs;
exports.dummy_table = dummy_table;
exports.table_count = table_count;
exports.dummy_met = dummy_met;
exports.fit_size = fit_size;
exports.new_table = new_table;
exports.resize = resize;
exports.put = put;
exports.method_count = method_count;
exports.inst_var_count = inst_var_count;
exports.new_method = new_method;
exports.get_method_label = get_method_label;
exports.get_method_labels = get_method_labels;
exports.set_method = set_method;
exports.get_method = get_method;
exports.to_list = to_list;
exports.narrow = narrow;
exports.widen = widen;
exports.new_slot = new_slot;
exports.new_variable = new_variable;
exports.to_array = to_array;
exports.new_methods_variables = new_methods_variables;
exports.get_variable = get_variable;
exports.get_variables = get_variables;
exports.add_initializer = add_initializer;
exports.create_table = create_table;
exports.init_class = init_class;
exports.inherits = inherits;
exports.make_class = make_class;
exports.make_class_store = make_class_store;
exports.dummy_class = dummy_class;
exports.iter_f = iter_f;
exports.run_initializers = run_initializers;
exports.run_initializers_opt = run_initializers_opt;
exports.build_path = build_path;
exports.lookup_keys = lookup_keys;
exports.lookup_tables = lookup_tables;
exports.get_const = get_const;
exports.get_var = get_var;
exports.get_env = get_env;
exports.get_meth = get_meth;
exports.set_var = set_var;
exports.app_const = app_const;
exports.app_var = app_var;
exports.app_env = app_env;
exports.app_meth = app_meth;
exports.app_const_const = app_const_const;
exports.app_const_var = app_const_var;
exports.app_const_meth = app_const_meth;
exports.app_var_const = app_var_const;
exports.app_meth_const = app_meth_const;
exports.app_const_env = app_const_env;
exports.app_env_const = app_env_const;
exports.meth_app_const = meth_app_const;
exports.meth_app_var = meth_app_var;
exports.meth_app_env = meth_app_env;
exports.meth_app_meth = meth_app_meth;
exports.send_const = send_const;
exports.send_var = send_var;
exports.send_env = send_env;
exports.send_meth = send_meth;
exports.new_cache = new_cache;
exports.method_impl = method_impl;
exports.set_methods = set_methods;
exports.stats = stats;
/* Vars Not a pure module */
