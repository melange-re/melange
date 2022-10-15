'use strict';

var $$Map = require("melange/jscomp/stdlib-412/stdlib_modules/map.js");
var Curry = require("melange/lib/js/curry.js");
var $$String = require("melange/jscomp/stdlib-412/stdlib_modules/string.js");

var M = $$Map.Make({
      compare: $$String.compare
    });

var v = Curry._1(M.is_empty, M.empty);

exports.v = v;
/* M Not a pure module */
