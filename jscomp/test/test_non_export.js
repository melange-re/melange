'use strict';

var $$Set = require("melange/lib/js/set.js");
var $$String = require("melange/lib/js/string.js");

var v = {
  compare: $$String.compare
};

$$Set.Make(v);

$$Set.Make({
      compare: $$String.compare
    });

$$Set.Make({
      compare: $$String.compare
    });

$$Set.Make({
      compare: $$String.compare
    });

/*  Not a pure module */
