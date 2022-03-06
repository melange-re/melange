'use strict';

var Caml = require("../../lib/js/caml.js");
var Belt_Id = require("../../lib/js/belt_Id.js");
var Hashtbl = require("../../lib/js/hashtbl.js");
var Belt_HashMap = require("../../lib/js/belt_HashMap.js");
var Belt_MapDict = require("../../lib/js/belt_MapDict.js");
var Belt_HashMapInt = require("../../lib/js/belt_HashMapInt.js");
var Belt_HashSetInt = require("../../lib/js/belt_HashSetInt.js");
var Belt_HashMapString = require("../../lib/js/belt_HashMapString.js");
var Caml_hash_primitive = require("../../lib/js/caml_hash_primitive.js");
var Belt_internalBucketsType = require("../../lib/js/belt_internalBucketsType.js");

function hash_string(s) {
  return Caml_hash_primitive.caml_hash_final_mix(Caml_hash_primitive.caml_hash_mix_string(0, s));
}

var hashString = (function(str){ 
                                              var hash = 5381,
                                              i    = str.length | 0;

                                              while(i !== 0) {
                                              hash = (hash * 33) ^ str.charCodeAt(--i);
                                              }
                                              return hash});

var $$String = Belt_Id.hashable(Hashtbl.hash, (function (x, y) {
        return x === y;
      }));

var String1 = Belt_Id.hashable(hashString, (function (x, y) {
        return x === y;
      }));

var String2 = Belt_Id.hashable((function (x) {
        return Caml_hash_primitive.caml_hash_final_mix(Caml_hash_primitive.caml_hash_mix_string(0, x));
      }), (function (x, y) {
        return x === y;
      }));

var Int = Belt_Id.hashable(Hashtbl.hash, (function (x, y) {
        return x === y;
      }));

var empty = Belt_internalBucketsType.make(Int.hash, Int.eq, 500000);

function bench(param) {
  for(var i = 0; i <= 1000000; ++i){
    Belt_HashMap.set(empty, i, i);
  }
  for(var i$1 = 0; i$1 <= 1000000; ++i$1){
    if (!Belt_HashMap.has(empty, i$1)) {
      throw {
            RE_EXN_ID: "Assert_failure",
            _1: [
              "bs_hashtbl_string_test.ml",
              50,
              4
            ],
            Error: new Error()
          };
    }
    
  }
  Belt_HashMap.logStats(empty);
}

function bench2(m) {
  var empty = Belt_internalBucketsType.make(m.hash, m.eq, 1000000);
  for(var i = 0; i <= 1000000; ++i){
    Belt_HashMap.set(empty, String(i), i);
  }
  for(var i$1 = 0; i$1 <= 1000000; ++i$1){
    if (!Belt_HashMap.has(empty, String(i$1))) {
      throw {
            RE_EXN_ID: "Assert_failure",
            _1: [
              "bs_hashtbl_string_test.ml",
              76,
              4
            ],
            Error: new Error()
          };
    }
    
  }
  for(var i$2 = 0; i$2 <= 1000000; ++i$2){
    Belt_HashMap.remove(empty, String(i$2));
  }
  if (empty.size === 0) {
    return ;
  }
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "bs_hashtbl_string_test.ml",
          82,
          2
        ],
        Error: new Error()
      };
}

function bench3(m) {
  var empty_cmp = m.cmp;
  var cmp = m.cmp;
  var table = undefined;
  for(var i = 0; i <= 1000000; ++i){
    table = Belt_MapDict.set(table, String(i), i, cmp);
  }
  for(var i$1 = 0; i$1 <= 1000000; ++i$1){
    if (!Belt_MapDict.has(table, String(i$1), cmp)) {
      throw {
            RE_EXN_ID: "Assert_failure",
            _1: [
              "bs_hashtbl_string_test.ml",
              98,
              4
            ],
            Error: new Error()
          };
    }
    
  }
  for(var i$2 = 0; i$2 <= 1000000; ++i$2){
    table = Belt_MapDict.remove(table, String(i$2), cmp);
  }
  if (Belt_MapDict.size(table) === 0) {
    return ;
  }
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "bs_hashtbl_string_test.ml",
          105,
          2
        ],
        Error: new Error()
      };
}

var Sx = Belt_Id.comparable(Caml.caml_string_compare);

function bench4(param) {
  var table = Belt_internalBucketsType.make(undefined, undefined, 1000000);
  for(var i = 0; i <= 1000000; ++i){
    Belt_HashMapString.set(table, String(i), i);
  }
  for(var i$1 = 0; i$1 <= 1000000; ++i$1){
    if (!Belt_HashMapString.has(table, String(i$1))) {
      throw {
            RE_EXN_ID: "Assert_failure",
            _1: [
              "bs_hashtbl_string_test.ml",
              118,
              4
            ],
            Error: new Error()
          };
    }
    
  }
  for(var i$2 = 0; i$2 <= 1000000; ++i$2){
    Belt_HashMapString.remove(table, String(i$2));
  }
  if (Belt_HashMapString.isEmpty(table)) {
    return ;
  }
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "bs_hashtbl_string_test.ml",
          124,
          2
        ],
        Error: new Error()
      };
}

function bench5(param) {
  var table = Belt_internalBucketsType.make(Int.hash, Int.eq, 1000000);
  console.time("bs_hashtbl_string_test.ml 133");
  for(var i = 0; i <= 1000000; ++i){
    Belt_HashMap.set(table, i, i);
  }
  console.timeEnd("bs_hashtbl_string_test.ml 133");
  console.time("bs_hashtbl_string_test.ml 137");
  for(var i$1 = 0; i$1 <= 1000000; ++i$1){
    if (!Belt_HashMap.has(table, i$1)) {
      throw {
            RE_EXN_ID: "Assert_failure",
            _1: [
              "bs_hashtbl_string_test.ml",
              138,
              6
            ],
            Error: new Error()
          };
    }
    
  }
  console.timeEnd("bs_hashtbl_string_test.ml 137");
  console.time("bs_hashtbl_string_test.ml 141");
  for(var i$2 = 0; i$2 <= 1000000; ++i$2){
    Belt_HashMap.remove(table, i$2);
  }
  console.timeEnd("bs_hashtbl_string_test.ml 141");
  if (Belt_HashMap.isEmpty(table)) {
    return ;
  }
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "bs_hashtbl_string_test.ml",
          144,
          2
        ],
        Error: new Error()
      };
}

function bench6(param) {
  var table = Belt_internalBucketsType.make(undefined, undefined, 1000000);
  for(var i = 0; i <= 1000000; ++i){
    Belt_HashMapInt.set(table, i, i);
  }
  for(var i$1 = 0; i$1 <= 1000000; ++i$1){
    if (!Belt_HashMapInt.has(table, i$1)) {
      throw {
            RE_EXN_ID: "Assert_failure",
            _1: [
              "bs_hashtbl_string_test.ml",
              156,
              4
            ],
            Error: new Error()
          };
    }
    
  }
  for(var i$2 = 0; i$2 <= 1000000; ++i$2){
    Belt_HashMapInt.remove(table, i$2);
  }
  if (table.size === 0) {
    return ;
  }
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "bs_hashtbl_string_test.ml",
          162,
          2
        ],
        Error: new Error()
      };
}

function bench7(param) {
  var table = Belt_internalBucketsType.make(undefined, undefined, 2000000);
  for(var i = 0; i <= 1000000; ++i){
    Belt_HashSetInt.add(table, i);
  }
  for(var i$1 = 0; i$1 <= 1000000; ++i$1){
    if (!Belt_HashSetInt.has(table, i$1)) {
      throw {
            RE_EXN_ID: "Assert_failure",
            _1: [
              "bs_hashtbl_string_test.ml",
              181,
              4
            ],
            Error: new Error()
          };
    }
    
  }
  for(var i$2 = 0; i$2 <= 1000000; ++i$2){
    Belt_HashSetInt.remove(table, i$2);
  }
  if (table.size === 0) {
    return ;
  }
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "bs_hashtbl_string_test.ml",
          192,
          2
        ],
        Error: new Error()
      };
}

console.time("bs_hashtbl_string_test.ml 203");

bench7(undefined);

console.timeEnd("bs_hashtbl_string_test.ml 203");

var count = 1000000;

var initial_size = 1000000;

exports.hash_string = hash_string;
exports.hashString = hashString;
exports.$$String = $$String;
exports.String1 = String1;
exports.String2 = String2;
exports.Int = Int;
exports.empty = empty;
exports.bench = bench;
exports.count = count;
exports.initial_size = initial_size;
exports.bench2 = bench2;
exports.bench3 = bench3;
exports.Sx = Sx;
exports.bench4 = bench4;
exports.bench5 = bench5;
exports.bench6 = bench6;
exports.bench7 = bench7;
/* String Not a pure module */
