'use strict';

var $$Map = require("melange/lib/js/map.js");
var Curry = require("melange/lib/js/curry.js");
var $$String = require("melange/lib/js/string.js");

var M = $$Map.Make({
      compare: $$String.compare
    });

var v = Curry._1(M.is_empty, M.empty);

exports.v = v;
/* M Not a pure module */
