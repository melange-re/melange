// Generated by Melange
'use strict';

const Mt = require("./mt.js");

const suites = {
  contents: /* [] */ 0
};

const test_id = {
  contents: 0
};

function eq(loc, x, y) {
  Mt.eq_suites(test_id, suites, loc, x, y);
}

Mt.from_pair_suites("Gpr_2789_test", suites.contents);

module.exports = {
  suites,
  test_id,
  eq,
}
/*  Not a pure module */
