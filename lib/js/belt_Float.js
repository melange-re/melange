'use strict';

var Caml_option = require("./caml_option.js");

function fromString(i) {
  var i$1 = parseFloat(i);
  if (isNaN(i$1)) {
    return ;
  } else {
    return Caml_option.some(i$1);
  }
}

exports.fromString = fromString;
/* No side effect */
