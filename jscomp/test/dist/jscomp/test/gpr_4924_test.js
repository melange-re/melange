// Generated by Melange
'use strict';

const Mt = require("./mt.js");

const suites = {
  contents: /* [] */ 0
};

const id = {
  contents: 0
};

function u(b) {
  if (/* tag */ (typeof b === "number" || typeof b === "string") && b === /* A */ 0) {
    return 0;
  } else {
    return 1;
  }
}

function u1(b) {
  if (/* tag */ (typeof b === "number" || typeof b === "string") && b === /* A */ 0) {
    return true;
  } else {
    return false;
  }
}

function u2(b) {
  if (/* tag */ (typeof b === "number" || typeof b === "string") && b === /* A */ 0) {
    return false;
  } else {
    return true;
  }
}

Mt.eq_suites(id, suites, "File \"jscomp/test/gpr_4924_test.ml\", line 25, characters 33-40", false, false);

Mt.eq_suites(id, suites, "File \"jscomp/test/gpr_4924_test.ml\", line 26, characters 33-40", true, true);

Mt.eq_suites(id, suites, "File \"jscomp/test/gpr_4924_test.ml\", line 27, characters 33-40", true, true);

function u3(b) {
  if (/* tag */ (typeof b === "number" || typeof b === "string") && b === /* A */ 0) {
    return 3;
  } else {
    return 4;
  }
}

function u4(b) {
  if (/* tag */ (typeof b === "number" || typeof b === "string") && b === /* A */ 0) {
    return 3;
  } else {
    return 4;
  }
}

function u5(b) {
  if (/* tag */ (typeof b === "number" || typeof b === "string") && b === /* A */ 0) {
    return false;
  } else {
    return true;
  }
}

function u6(b) {
  if (/* tag */ (typeof b === "number" || typeof b === "string") && b === /* A */ 0) {
    return true;
  } else {
    return false;
  }
}

Mt.from_pair_suites("File \"jscomp/test/gpr_4924_test.ml\", line 49, characters 20-27", suites.contents);

const from_pair_suites = Mt.from_pair_suites;

const eq_suites = Mt.eq_suites;

module.exports = {
  from_pair_suites,
  eq_suites,
  suites,
  id,
  u,
  u1,
  u2,
  u3,
  u4,
  u5,
  u6,
}
/*  Not a pure module */
