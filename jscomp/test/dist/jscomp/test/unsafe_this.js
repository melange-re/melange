// Generated by Melange
'use strict';


const u = {
  x: 3,
  y: 32,
  bark: (function ($$this, x, y) {
    console.log([
      $$this.length,
      $$this.x,
      $$this.y
    ]);
  }),
  length: 32
};

u.bark(u, 1, 2);

function uux_this(x, y) {
  let o = this;
  return (o.length + x | 0) + y | 0;
}

const js_obj = {
  x: 3,
  y: 32,
  bark: (function (x, y) {
    let o = this;
    console.log([
      o.length,
      o.x,
      o.y,
      x,
      y
    ]);
    return x + y | 0;
  }),
  length: 32
};

module.exports = {
  js_obj,
  uux_this,
}
/*  Not a pure module */
