

import * as Obj from "./obj.mjs";
import * as CamlinternalLazy from "./camlinternalLazy.mjs";
import * as Caml_external_polyfill from "./caml_external_polyfill.mjs";

function from_fun(f) {
  var x = Caml_external_polyfill.resolve("caml_obj_block")(Obj.lazy_tag, 1);
  x[0] = f;
  return x;
}

function from_val(v) {
  var t = v.TAG | 0;
  if (t === Obj.forward_tag || t === Obj.lazy_tag || t === Obj.double_tag) {
    return Caml_external_polyfill.resolve("caml_lazy_make_forward")(v);
  } else {
    return v;
  }
}

function is_val(l) {
  return (l.TAG | 0) !== Obj.lazy_tag;
}

var Undefined = CamlinternalLazy.Undefined;

var force_val = CamlinternalLazy.force_val;

var lazy_from_fun = from_fun;

var lazy_from_val = from_val;

var lazy_is_val = is_val;

export {
  Undefined ,
  force_val ,
  from_fun ,
  from_val ,
  is_val ,
  lazy_from_fun ,
  lazy_from_val ,
  lazy_is_val ,
  
}
/* No side effect */
