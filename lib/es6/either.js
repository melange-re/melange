

import * as Curry from "./curry.js";
import * as Caml_option from "./caml_option.js";

function left(v) {
  return {
          TAG: /* Left */0,
          _0: v
        };
}

function right(v) {
  return {
          TAG: /* Right */1,
          _0: v
        };
}

function is_left(param) {
  if (param.TAG === /* Left */0) {
    return true;
  } else {
    return false;
  }
}

function is_right(param) {
  if (param.TAG === /* Left */0) {
    return false;
  } else {
    return true;
  }
}

function find_left(v) {
  if (v.TAG === /* Left */0) {
    return Caml_option.some(v._0);
  }
  
}

function find_right(v) {
  if (v.TAG === /* Left */0) {
    return ;
  } else {
    return Caml_option.some(v._0);
  }
}

function map_left(f, v) {
  if (v.TAG === /* Left */0) {
    return {
            TAG: /* Left */0,
            _0: Curry._1(f, v._0)
          };
  } else {
    return v;
  }
}

function map_right(f, e) {
  if (e.TAG === /* Left */0) {
    return e;
  } else {
    return {
            TAG: /* Right */1,
            _0: Curry._1(f, e._0)
          };
  }
}

function map(left, right, v) {
  if (v.TAG === /* Left */0) {
    return {
            TAG: /* Left */0,
            _0: Curry._1(left, v._0)
          };
  } else {
    return {
            TAG: /* Right */1,
            _0: Curry._1(right, v._0)
          };
  }
}

function fold(left, right, v) {
  if (v.TAG === /* Left */0) {
    return Curry._1(left, v._0);
  } else {
    return Curry._1(right, v._0);
  }
}

function equal(left, right, e1, e2) {
  if (e1.TAG === /* Left */0) {
    if (e2.TAG === /* Left */0) {
      return Curry._2(left, e1._0, e2._0);
    } else {
      return false;
    }
  } else if (e2.TAG === /* Left */0) {
    return false;
  } else {
    return Curry._2(right, e1._0, e2._0);
  }
}

function compare(left, right, e1, e2) {
  if (e1.TAG === /* Left */0) {
    if (e2.TAG === /* Left */0) {
      return Curry._2(left, e1._0, e2._0);
    } else {
      return -1;
    }
  } else if (e2.TAG === /* Left */0) {
    return 1;
  } else {
    return Curry._2(right, e1._0, e2._0);
  }
}

var iter = fold;

var for_all = fold;

export {
  left ,
  right ,
  is_left ,
  is_right ,
  find_left ,
  find_right ,
  map_left ,
  map_right ,
  map ,
  fold ,
  iter ,
  for_all ,
  equal ,
  compare ,
  
}
/* No side effect */
