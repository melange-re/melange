

import * as CamlinternalAtomic from "./camlinternalAtomic.js";

var make = CamlinternalAtomic.make;

var get = CamlinternalAtomic.get;

var set = CamlinternalAtomic.set;

var exchange = CamlinternalAtomic.exchange;

var compare_and_set = CamlinternalAtomic.compare_and_set;

var fetch_and_add = CamlinternalAtomic.fetch_and_add;

var incr = CamlinternalAtomic.incr;

var decr = CamlinternalAtomic.decr;

export {
  make ,
  get ,
  set ,
  exchange ,
  compare_and_set ,
  fetch_and_add ,
  incr ,
  decr ,
  
}
/* No side effect */
