'use strict';

var Mt = require("./mt.js");

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

function Make (){
  this.data = []
  for(var i = 0; i < arguments.length; ++i){
   this.data[i] = arguments[i]
}
}

Make.prototype.sum = function(){
  var result  = 0;
  for(var k = 0; k < this.data.length; ++k){
    result = result + this.data[k]
  };
  return result
}  

Make.prototype.add = function(){
  
}
;

function f(x) {
  return x.test("a", "b").test("a", "b");
}

var v = new Make(1, 2, 3, 4);

var u = v.sum();

eq("File \"ffi_splice_test.ml\", line 61, characters 12-19", u, 10);

Mt.from_pair_suites("Ffi_splice_test", suites.contents);

exports.suites = suites;
exports.test_id = test_id;
exports.eq = eq;
exports.f = f;
exports.v = v;
exports.u = u;
/*  Not a pure module */
