'use strict';


f(3);

function h() {
  f2(3);
  return /* () */0;
}

exports.h = h;
/*  Not a pure module */
