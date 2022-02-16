'use strict';

var Mt = require("./mt.js");
var List = require("../../lib/js/list.js");
var Curry = require("../../lib/js/curry.js");
var Lexing = require("../../lib/js/lexing.js");
var Stdlib = require("../../lib/js/stdlib.js");
var Caml_obj = require("../../lib/js/caml_obj.js");
var Arith_lexer = require("./arith_lexer.js");
var Arith_parser = require("./arith_parser.js");
var Arith_syntax = require("./arith_syntax.js");
var Number_lexer = require("./number_lexer.js");

function get_tokens(lex, str) {
  var buf = Lexing.from_string(undefined, str);
  var _acc = /* [] */0;
  while(true) {
    var acc = _acc;
    var v = Curry._1(lex, buf);
    if (Caml_obj.caml_equal(v, /* EOF */7)) {
      return List.rev(acc);
    }
    _acc = {
      hd: v,
      tl: acc
    };
    continue ;
  };
}

function f(param) {
  return get_tokens(Arith_lexer.lexeme, param);
}

function from_tokens(lst) {
  var l = {
    contents: lst
  };
  return function (param) {
    var match = l.contents;
    if (match) {
      l.contents = match.tl;
      return match.hd;
    }
    throw {
          RE_EXN_ID: Stdlib.End_of_file,
          Error: new Error()
        };
  };
}

var lexer_suites_0 = [
  "arith_token",
  (function (param) {
      return {
              TAG: /* Eq */0,
              _0: get_tokens(Arith_lexer.lexeme, "x + 3 + 4 + y"),
              _1: {
                hd: {
                  TAG: /* IDENT */1,
                  _0: "x"
                },
                tl: {
                  hd: /* PLUS */0,
                  tl: {
                    hd: {
                      TAG: /* NUMERAL */0,
                      _0: 3
                    },
                    tl: {
                      hd: /* PLUS */0,
                      tl: {
                        hd: {
                          TAG: /* NUMERAL */0,
                          _0: 4
                        },
                        tl: {
                          hd: /* PLUS */0,
                          tl: {
                            hd: {
                              TAG: /* IDENT */1,
                              _0: "y"
                            },
                            tl: /* [] */0
                          }
                        }
                      }
                    }
                  }
                }
              }
            };
    })
];

var lexer_suites_1 = {
  hd: [
    "simple token",
    (function (param) {
        return {
                TAG: /* Eq */0,
                _0: Arith_lexer.lexeme(Lexing.from_string(undefined, "10")),
                _1: {
                  TAG: /* NUMERAL */0,
                  _0: 10
                }
              };
      })
  ],
  tl: {
    hd: [
      "number_lexer",
      (function (param) {
          var v = {
            contents: /* [] */0
          };
          var add = function (t) {
            v.contents = {
              hd: t,
              tl: v.contents
            };
          };
          Number_lexer.token(add, Lexing.from_string(undefined, "32 + 32 ( ) * / "));
          return {
                  TAG: /* Eq */0,
                  _0: List.rev(v.contents),
                  _1: {
                    hd: "number",
                    tl: {
                      hd: "32",
                      tl: {
                        hd: "new line",
                        tl: {
                          hd: "+",
                          tl: {
                            hd: "new line",
                            tl: {
                              hd: "number",
                              tl: {
                                hd: "32",
                                tl: {
                                  hd: "new line",
                                  tl: {
                                    hd: "(",
                                    tl: {
                                      hd: "new line",
                                      tl: {
                                        hd: ")",
                                        tl: {
                                          hd: "new line",
                                          tl: {
                                            hd: "*",
                                            tl: {
                                              hd: "new line",
                                              tl: {
                                                hd: "/",
                                                tl: {
                                                  hd: "new line",
                                                  tl: {
                                                    hd: "eof",
                                                    tl: /* [] */0
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                };
        })
    ],
    tl: {
      hd: [
        "simple number",
        (function (param) {
            return {
                    TAG: /* Eq */0,
                    _0: Arith_syntax.str(Arith_parser.toplevel(Arith_lexer.lexeme, Lexing.from_string(undefined, "10"))),
                    _1: "10."
                  };
          })
      ],
      tl: {
        hd: [
          "arith",
          (function (param) {
              return {
                      TAG: /* Eq */0,
                      _0: Arith_syntax.str(Arith_parser.toplevel(Arith_lexer.lexeme, Lexing.from_string(undefined, "x + 3 + 4 + y"))),
                      _1: "x+3.+4.+y"
                    };
            })
        ],
        tl: /* [] */0
      }
    }
  }
};

var lexer_suites = {
  hd: lexer_suites_0,
  tl: lexer_suites_1
};

Mt.from_pair_suites("Lexer_test", lexer_suites);

exports.get_tokens = get_tokens;
exports.f = f;
exports.from_tokens = from_tokens;
exports.lexer_suites = lexer_suites;
/*  Not a pure module */
