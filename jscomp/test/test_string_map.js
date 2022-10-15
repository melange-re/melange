'use strict';

var $$Map = require("melange/lib/js/map.js");
var Caml = require("melange/lib/js/caml.js");
var Curry = require("melange/lib/js/curry.js");

var compare = Caml.caml_string_compare;

var StringMap = $$Map.Make({
      compare: compare
    });

function timing(label, f) {
  console.time(label);
  Curry._1(f, undefined);
  console.timeEnd(label);
}

function assertion_test(param) {
  var m = {
    contents: StringMap.empty
  };
  timing("building", (function (param) {
          for(var i = 0; i <= 1000000; ++i){
            m.contents = Curry._3(StringMap.add, String(i), String(i), m.contents);
          }
        }));
  timing("querying", (function (param) {
          for(var i = 0; i <= 1000000; ++i){
            Curry._2(StringMap.find, String(i), m.contents);
          }
        }));
}

exports.assertion_test = assertion_test;
/* StringMap Not a pure module */
