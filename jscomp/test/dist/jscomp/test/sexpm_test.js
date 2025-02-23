// Generated by Melange
'use strict';

const Curry = require("melange.js/curry.js");
const Mt = require("./mt.js");
const Sexpm = require("./sexpm.js");
const Stdlib__Format = require("melange/format.js");

const suites = {
  contents: /* [] */ 0
};

const test_id = {
  contents: 0
};

function eq(loc, param) {
  const y = param[1];
  const x = param[0];
  test_id.contents = test_id.contents + 1 | 0;
  suites.contents = {
    hd: [
      loc + (" id " + String(test_id.contents)),
      (function (param) {
        return {
          TAG: /* Eq */ 0,
          _0: x,
          _1: y
        };
      })
    ],
    tl: suites.contents
  };
}

function print_or_error(fmt, x) {
  if (x.NAME === "Error") {
    return Curry._1(Stdlib__Format.fprintf(fmt)({
      TAG: /* Format */ 0,
      _0: {
        TAG: /* Formatting_gen */ 18,
        _0: {
          TAG: /* Open_box */ 1,
          _0: {
            TAG: /* Format */ 0,
            _0: /* End_of_format */ 0,
            _1: ""
          }
        },
        _1: {
          TAG: /* String_literal */ 11,
          _0: "Error:",
          _1: {
            TAG: /* String */ 2,
            _0: /* No_padding */ 0,
            _1: {
              TAG: /* Formatting_lit */ 17,
              _0: /* Close_box */ 0,
              _1: {
                TAG: /* Formatting_lit */ 17,
                _0: /* Flush_newline */ 4,
                _1: /* End_of_format */ 0
              }
            }
          }
        }
      },
      _1: "@[Error:%s@]@."
    }), x.VAL);
  } else {
    return Curry._2(Stdlib__Format.fprintf(fmt)({
      TAG: /* Format */ 0,
      _0: {
        TAG: /* Formatting_gen */ 18,
        _0: {
          TAG: /* Open_box */ 1,
          _0: {
            TAG: /* Format */ 0,
            _0: /* End_of_format */ 0,
            _1: ""
          }
        },
        _1: {
          TAG: /* String_literal */ 11,
          _0: "Ok:",
          _1: {
            TAG: /* Alpha */ 15,
            _0: {
              TAG: /* Formatting_lit */ 17,
              _0: /* Close_box */ 0,
              _1: {
                TAG: /* Formatting_lit */ 17,
                _0: /* Flush_newline */ 4,
                _1: /* End_of_format */ 0
              }
            }
          }
        }
      },
      _1: "@[Ok:%a@]@."
    }), Sexpm.print, x.VAL);
  }
}

const a = Sexpm.parse_string("(x x gh 3 3)");

eq("File \"jscomp/test/sexpm_test.ml\", line 17, characters 7-14", [
  {
    NAME: "Ok",
    VAL: {
      NAME: "List",
      VAL: {
        hd: {
          NAME: "Atom",
          VAL: "x"
        },
        tl: {
          hd: {
            NAME: "Atom",
            VAL: "x"
          },
          tl: {
            hd: {
              NAME: "Atom",
              VAL: "gh"
            },
            tl: {
              hd: {
                NAME: "Atom",
                VAL: "3"
              },
              tl: {
                hd: {
                  NAME: "Atom",
                  VAL: "3"
                },
                tl: /* [] */ 0
              }
            }
          }
        }
      }
    }
  },
  a
]);

eq("File \"jscomp/test/sexpm_test.ml\", line 21, characters 7-14", [
  Curry._2(Stdlib__Format.asprintf({
    TAG: /* Format */ 0,
    _0: {
      TAG: /* Alpha */ 15,
      _0: /* End_of_format */ 0
    },
    _1: "%a"
  }), print_or_error, a).trim(),
  "Ok:(x x gh 3 3)\n".trim()
]);

Mt.from_pair_suites("Sexpm_test", suites.contents);

module.exports = {
  suites,
  test_id,
  eq,
  print_or_error,
}
/* a Not a pure module */
