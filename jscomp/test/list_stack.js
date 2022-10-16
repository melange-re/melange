'use strict';

var List = require("melange/lib/js/list.js");

List.find((function (x) {
        return x > 3;
      }), /* [] */0);

/*  Not a pure module */
