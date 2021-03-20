

import * as Curry from "./curry.js";
import * as $$Buffer from "./buffer.js";
import * as CamlinternalFormat from "./camlinternalFormat.js";
import * as Stdlib__no_aliases from "./stdlib__no_aliases.js";

function kfprintf(k, o, param) {
  return CamlinternalFormat.make_printf((function (acc) {
                CamlinternalFormat.output_acc(o, acc);
                return Curry._1(k, o);
              }), /* End_of_acc */0, param._0);
}

function kbprintf(k, b, param) {
  return CamlinternalFormat.make_printf((function (acc) {
                CamlinternalFormat.bufput_acc(b, acc);
                return Curry._1(k, b);
              }), /* End_of_acc */0, param._0);
}

function ikfprintf(k, oc, param) {
  return CamlinternalFormat.make_iprintf(k, oc, param._0);
}

function fprintf(oc, fmt) {
  return kfprintf((function (prim) {
                
              }), oc, fmt);
}

function bprintf(b, fmt) {
  return kbprintf((function (prim) {
                
              }), b, fmt);
}

function ifprintf(oc, fmt) {
  return ikfprintf((function (prim) {
                
              }), oc, fmt);
}

function ibprintf(b, fmt) {
  return ikfprintf((function (prim) {
                
              }), b, fmt);
}

function printf(fmt) {
  return fprintf(Stdlib__no_aliases.stdout, fmt);
}

function eprintf(fmt) {
  return fprintf(Stdlib__no_aliases.stderr, fmt);
}

function ksprintf(k, param) {
  var k$p = function (acc) {
    var buf = $$Buffer.create(64);
    CamlinternalFormat.strput_acc(buf, acc);
    return Curry._1(k, $$Buffer.contents(buf));
  };
  return CamlinternalFormat.make_printf(k$p, /* End_of_acc */0, param._0);
}

function sprintf(fmt) {
  return ksprintf((function (s) {
                return s;
              }), fmt);
}

var ikbprintf = ikfprintf;

var kprintf = ksprintf;

export {
  fprintf ,
  printf ,
  eprintf ,
  sprintf ,
  bprintf ,
  ifprintf ,
  ibprintf ,
  kfprintf ,
  ikfprintf ,
  ksprintf ,
  kbprintf ,
  ikbprintf ,
  kprintf ,
  
}
/* No side effect */
