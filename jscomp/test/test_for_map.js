'use strict';

var $$Map = require("melange/lib/js/map.js");
var Caml = require("melange/lib/js/caml.js");
var Curry = require("melange/lib/js/curry.js");

var compare = Caml.caml_int_compare;

var IntMap = $$Map.Make({
      compare: compare
    });

function assertion_test(param) {
  var m = IntMap.empty;
  for(var i = 0; i <= 1000000; ++i){
    m = Curry._3(IntMap.add, i, i, m);
  }
  for(var i$1 = 0; i$1 <= 1000000; ++i$1){
    Curry._2(IntMap.find, i$1, m);
  }
}

exports.IntMap = IntMap;
exports.assertion_test = assertion_test;
/* IntMap Not a pure module */
