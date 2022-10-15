'use strict';

var Belt_MutableSetInt = require("melange/jscomp/others/belt_MutableSetInt.js");

var mySet = Belt_MutableSetInt.make(undefined);

Belt_MutableSetInt.add(mySet, 1);

Belt_MutableSetInt.add(mySet, 2);

Belt_MutableSetInt.remove(mySet, 1);

var a = 3;

exports.mySet = mySet;
exports.a = a;
/* mySet Not a pure module */
