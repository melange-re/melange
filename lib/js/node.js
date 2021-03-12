'use strict';


function test(x) {
  if (typeof x === "string") {
    return [
            /* String */0,
            x
          ];
  } else {
    return [
            /* Buffer */1,
            x
          ];
  }
}

exports.test = test;
/* No side effect */
