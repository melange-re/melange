'use strict';

var Immutable = require("immutable");
var Belt_Array = require("melange/lib/js/belt_Array.js");
var Belt_MapInt = require("melange/lib/js/belt_MapInt.js");

var empty = new Immutable.OrderedMap();

function fromArray(kvs) {
  var v = empty;
  for(var i = 0 ,i_finish = kvs.length; i < i_finish; ++i){
    var match = kvs[i];
    v = v.set(match[0], match[1]);
  }
  return v;
}

function should(b) {
  if (b) {
    return ;
  }
  throw new Error("impossible");
}

var shuffledDataAdd = Belt_Array.makeByAndShuffle(1000001, (function (i) {
        return [
                i,
                i
              ];
      }));

function test(param) {
  var v = fromArray(shuffledDataAdd);
  for(var j = 0; j <= 1000000; ++j){
    should(v.has(j));
  }
}

function test2(param) {
  var v = Belt_MapInt.fromArray(shuffledDataAdd);
  for(var j = 0; j <= 1000000; ++j){
    should(Belt_MapInt.has(v, j));
  }
}

console.time("imm_map_bench.ml 44");

test(undefined);

console.timeEnd("imm_map_bench.ml 44");

console.time("imm_map_bench.ml 45");

test2(undefined);

console.timeEnd("imm_map_bench.ml 45");

var count = 1000000;

exports.empty = empty;
exports.fromArray = fromArray;
exports.should = should;
exports.count = count;
exports.shuffledDataAdd = shuffledDataAdd;
exports.test = test;
exports.test2 = test2;
/* empty Not a pure module */
