'use strict';

var Sys = require("./sys.js");
var Marshal = require("./marshal.js");
var Caml_external_polyfill = require("./caml_external_polyfill.js");

function is_block(a) {
  return typeof a !== "number";
}

function double_field(x, i) {
  return Caml_external_polyfill.resolve("caml_floatarray_get")(x, i);
}

function set_double_field(x, i, v) {
  return Caml_external_polyfill.resolve("caml_floatarray_set")(x, i, v);
}

function marshal(obj) {
  return Caml_external_polyfill.resolve("caml_output_value_to_bytes")(obj, /* [] */0);
}

function unmarshal(str, pos) {
  return [
          Marshal.from_bytes(str, pos),
          pos + Marshal.total_size(str, pos) | 0
        ];
}

var Closure = {};

function of_val(x) {
  var slot = typeof x !== "number" && (x.TAG | 0) !== 248 && (x.length | 0) >= 1 ? x[0] : x;
  var name;
  if (typeof slot !== "number" && slot.TAG === 248) {
    name = slot[0];
  } else {
    throw {
          RE_EXN_ID: "Invalid_argument",
          _1: "Obj.extension_constructor",
          Error: new Error()
        };
  }
  if (name.TAG === 252) {
    return slot;
  }
  throw {
        RE_EXN_ID: "Invalid_argument",
        _1: "Obj.extension_constructor",
        Error: new Error()
      };
}

function name(slot) {
  return slot[0];
}

function id(slot) {
  return slot[1];
}

var Extension_constructor = {
  of_val: of_val,
  name: name,
  id: id
};

var max_ephe_length = Sys.max_array_length - 2 | 0;

function create(l) {
  if (!(0 <= l && l <= max_ephe_length)) {
    throw {
          RE_EXN_ID: "Invalid_argument",
          _1: "Obj.Ephemeron.create",
          Error: new Error()
        };
  }
  return Caml_external_polyfill.resolve("caml_ephe_create")(l);
}

function length(x) {
  return (x.length | 0) - 2 | 0;
}

function raise_if_invalid_offset(e, o, msg) {
  if (0 <= o && o < ((e.length | 0) - 2 | 0)) {
    return ;
  }
  throw {
        RE_EXN_ID: "Invalid_argument",
        _1: msg,
        Error: new Error()
      };
}

function get_key(e, o) {
  raise_if_invalid_offset(e, o, "Obj.Ephemeron.get_key");
  return Caml_external_polyfill.resolve("caml_ephe_get_key")(e, o);
}

function get_key_copy(e, o) {
  raise_if_invalid_offset(e, o, "Obj.Ephemeron.get_key_copy");
  return Caml_external_polyfill.resolve("caml_ephe_get_key_copy")(e, o);
}

function set_key(e, o, x) {
  raise_if_invalid_offset(e, o, "Obj.Ephemeron.set_key");
  return Caml_external_polyfill.resolve("caml_ephe_set_key")(e, o, x);
}

function unset_key(e, o) {
  raise_if_invalid_offset(e, o, "Obj.Ephemeron.unset_key");
  return Caml_external_polyfill.resolve("caml_ephe_unset_key")(e, o);
}

function check_key(e, o) {
  raise_if_invalid_offset(e, o, "Obj.Ephemeron.check_key");
  return Caml_external_polyfill.resolve("caml_ephe_check_key")(e, o);
}

function blit_key(e1, o1, e2, o2, l) {
  if (l < 0 || o1 < 0 || o1 > (((e1.length | 0) - 2 | 0) - l | 0) || o2 < 0 || o2 > (((e2.length | 0) - 2 | 0) - l | 0)) {
    throw {
          RE_EXN_ID: "Invalid_argument",
          _1: "Obj.Ephemeron.blit_key",
          Error: new Error()
        };
  }
  if (l !== 0) {
    return Caml_external_polyfill.resolve("caml_ephe_blit_key")(e1, o1, e2, o2, l);
  }
  
}

var first_non_constant_constructor_tag = 0;

var last_non_constant_constructor_tag = 245;

var lazy_tag = 246;

var closure_tag = 247;

var object_tag = 248;

var infix_tag = 249;

var forward_tag = 250;

var no_scan_tag = 251;

var abstract_tag = 251;

var string_tag = 252;

var double_tag = 253;

var double_array_tag = 254;

var custom_tag = 255;

var final_tag = 255;

var int_tag = 1000;

var out_of_heap_tag = 1001;

var unaligned_tag = 1002;

var extension_constructor = of_val;

var extension_name = name;

var extension_id = id;

function Ephemeron_get_data(prim) {
  return Caml_external_polyfill.resolve("caml_ephe_get_data")(prim);
}

function Ephemeron_get_data_copy(prim) {
  return Caml_external_polyfill.resolve("caml_ephe_get_data_copy")(prim);
}

function Ephemeron_set_data(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_ephe_set_data")(prim, prim$1);
}

function Ephemeron_unset_data(prim) {
  return Caml_external_polyfill.resolve("caml_ephe_unset_data")(prim);
}

function Ephemeron_check_data(prim) {
  return Caml_external_polyfill.resolve("caml_ephe_check_data")(prim);
}

function Ephemeron_blit_data(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_ephe_blit_data")(prim, prim$1);
}

var Ephemeron = {
  create: create,
  length: length,
  get_key: get_key,
  get_key_copy: get_key_copy,
  set_key: set_key,
  unset_key: unset_key,
  check_key: check_key,
  blit_key: blit_key,
  get_data: Ephemeron_get_data,
  get_data_copy: Ephemeron_get_data_copy,
  set_data: Ephemeron_set_data,
  unset_data: Ephemeron_unset_data,
  check_data: Ephemeron_check_data,
  blit_data: Ephemeron_blit_data,
  max_ephe_length: max_ephe_length
};

exports.is_block = is_block;
exports.double_field = double_field;
exports.set_double_field = set_double_field;
exports.first_non_constant_constructor_tag = first_non_constant_constructor_tag;
exports.last_non_constant_constructor_tag = last_non_constant_constructor_tag;
exports.lazy_tag = lazy_tag;
exports.closure_tag = closure_tag;
exports.object_tag = object_tag;
exports.infix_tag = infix_tag;
exports.forward_tag = forward_tag;
exports.no_scan_tag = no_scan_tag;
exports.abstract_tag = abstract_tag;
exports.string_tag = string_tag;
exports.double_tag = double_tag;
exports.double_array_tag = double_array_tag;
exports.custom_tag = custom_tag;
exports.final_tag = final_tag;
exports.int_tag = int_tag;
exports.out_of_heap_tag = out_of_heap_tag;
exports.unaligned_tag = unaligned_tag;
exports.Closure = Closure;
exports.Extension_constructor = Extension_constructor;
exports.extension_constructor = extension_constructor;
exports.extension_name = extension_name;
exports.extension_id = extension_id;
exports.marshal = marshal;
exports.unmarshal = unmarshal;
exports.Ephemeron = Ephemeron;
/* No side effect */
