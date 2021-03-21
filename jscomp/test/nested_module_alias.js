'use strict';

var List = require("../../lib/js/list.js");

function v(x) {
  return [
          List.length(x),
          List.length(x)
        ];
}

exports.v = v;
/* No side effect */
