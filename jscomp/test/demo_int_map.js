'use strict';

var $$Map = require("melange/jscomp/stdlib-412/stdlib_modules/map.js");
var Curry = require("melange/lib/js/curry.js");

function compare(x, y) {
  return x - y | 0;
}

var IntMap = $$Map.Make({
      compare: compare
    });

function test(param) {
  var m = IntMap.empty;
  for(var i = 0; i <= 1000000; ++i){
    m = Curry._3(IntMap.add, i, i, m);
  }
  for(var i$1 = 0; i$1 <= 1000000; ++i$1){
    Curry._2(IntMap.find, i$1, m);
  }
}

test(undefined);

/* IntMap Not a pure module */
