'use strict';

var CamlinternalAtomic = require("./camlinternalAtomic.js");

var make = CamlinternalAtomic.make;

var get = CamlinternalAtomic.get;

var set = CamlinternalAtomic.set;

var exchange = CamlinternalAtomic.exchange;

var compare_and_set = CamlinternalAtomic.compare_and_set;

var fetch_and_add = CamlinternalAtomic.fetch_and_add;

var incr = CamlinternalAtomic.incr;

var decr = CamlinternalAtomic.decr;

exports.make = make;
exports.get = get;
exports.set = set;
exports.exchange = exchange;
exports.compare_and_set = compare_and_set;
exports.fetch_and_add = fetch_and_add;
exports.incr = incr;
exports.decr = decr;
/* No side effect */
