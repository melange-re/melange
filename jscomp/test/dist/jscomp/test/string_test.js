// Generated by Melange
'use strict';

const Caml_bytes = require("melange.js/caml_bytes.js");
const Caml_js_exceptions = require("melange.js/caml_js_exceptions.js");
const Ext_string_test = require("./ext_string_test.js");
const Mt = require("./mt.js");
const Stdlib = require("melange/stdlib.js");
const Stdlib__Bytes = require("melange/bytes.js");
const Stdlib__List = require("melange/list.js");
const Stdlib__String = require("melange/string.js");

function ff(x) {
  let a;
  switch (x) {
    case "0" :
    case "1" :
    case "2" :
      a = 3;
      break;
    case "3" :
      a = 4;
      break;
    case "4" :
      a = 6;
      break;
    case "7" :
      a = 7;
      break;
    default:
      a = 8;
  }
  return a + 3 | 0;
}

function gg(x) {
  let a;
  switch (x) {
    case 0 :
    case 1 :
    case 2 :
      a = 3;
      break;
    case 3 :
      a = 4;
      break;
    case 4 :
      a = 6;
      break;
    case 8 :
      a = 7;
      break;
    default:
      a = 8;
  }
  return a + 3 | 0;
}

function rev_split_by_char(c, s) {
  const loop = function (i, l) {
    try {
      const i$p = Stdlib__String.index_from(s, i, c);
      const s$p = Stdlib__String.sub(s, i, i$p - i | 0);
      return loop(i$p + 1 | 0, s$p === "" ? l : ({
          hd: s$p,
          tl: l
        }));
    }
    catch (raw_exn){
      const exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
      if (exn.MEL_EXN_ID === Stdlib.Not_found) {
        return {
          hd: Stdlib__String.sub(s, i, s.length - i | 0),
          tl: l
        };
      }
      throw exn;
    }
  };
  return loop(0, /* [] */ 0);
}

function xsplit(delim, s) {
  const len = s.length;
  if (len !== 0) {
    let _l = /* [] */ 0;
    let _i = len;
    while (true) {
      const i = _i;
      const l = _l;
      if (i === 0) {
        return l;
      }
      let i$p;
      try {
        i$p = Stdlib__String.rindex_from(s, i - 1 | 0, delim);
      }
      catch (raw_exn){
        const exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
        if (exn.MEL_EXN_ID === Stdlib.Not_found) {
          return {
            hd: Stdlib__String.sub(s, 0, i),
            tl: l
          };
        }
        throw exn;
      }
      const l_0 = Stdlib__String.sub(s, i$p + 1 | 0, (i - i$p | 0) - 1 | 0);
      const l$1 = {
        hd: l_0,
        tl: l
      };
      const l$2 = i$p === 0 ? ({
          hd: "",
          tl: l$1
        }) : l$1;
      _i = i$p;
      _l = l$2;
      continue;
    };
  } else {
    return /* [] */ 0;
  }
}

function string_of_chars(x) {
  return Stdlib__String.concat("", Stdlib__List.map((function (prim) {
    return String.fromCharCode(prim);
  }), x));
}

Mt.from_pair_suites("String_test", {
  hd: [
    "mutliple switch",
    (function (param) {
      return {
        TAG: /* Eq */ 0,
        _0: 9,
        _1: ff("4")
      };
    })
  ],
  tl: {
    hd: [
      "int switch",
      (function (param) {
        return {
          TAG: /* Eq */ 0,
          _0: 9,
          _1: gg(4)
        };
      })
    ],
    tl: {
      hd: [
        "escape_normal",
        (function (param) {
          return {
            TAG: /* Eq */ 0,
            _0: "haha",
            _1: Stdlib__String.escaped("haha")
          };
        })
      ],
      tl: {
        hd: [
          "escape_bytes",
          (function (param) {
            return {
              TAG: /* Eq */ 0,
              _0: Stdlib__Bytes.of_string("haha"),
              _1: Stdlib__Bytes.escaped(Stdlib__Bytes.of_string("haha"))
            };
          })
        ],
        tl: {
          hd: [
            "escape_quote",
            (function (param) {
              return {
                TAG: /* Eq */ 0,
                _0: "\\\"\\\"",
                _1: Stdlib__String.escaped("\"\"")
              };
            })
          ],
          tl: {
            hd: [
              "rev_split_by_char",
              (function (param) {
                return {
                  TAG: /* Eq */ 0,
                  _0: {
                    hd: "",
                    tl: {
                      hd: "bbbb",
                      tl: {
                        hd: "bbbb",
                        tl: /* [] */ 0
                      }
                    }
                  },
                  _1: rev_split_by_char(/* 'a' */97, "bbbbabbbba")
                };
              })
            ],
            tl: {
              hd: [
                "File \"jscomp/test/string_test.ml\", line 74, characters 2-9",
                (function (param) {
                  return {
                    TAG: /* Eq */ 0,
                    _0: {
                      hd: "aaaa",
                      tl: /* [] */ 0
                    },
                    _1: rev_split_by_char(/* ',' */44, "aaaa")
                  };
                })
              ],
              tl: {
                hd: [
                  "xsplit",
                  (function (param) {
                    return {
                      TAG: /* Eq */ 0,
                      _0: {
                        hd: "a",
                        tl: {
                          hd: "b",
                          tl: {
                            hd: "c",
                            tl: /* [] */ 0
                          }
                        }
                      },
                      _1: xsplit(/* '.' */46, "a.b.c")
                    };
                  })
                ],
                tl: {
                  hd: [
                    "split_empty",
                    (function (param) {
                      return {
                        TAG: /* Eq */ 0,
                        _0: /* [] */ 0,
                        _1: Ext_string_test.split(undefined, "", /* '_' */95)
                      };
                    })
                  ],
                  tl: {
                    hd: [
                      "split_empty2",
                      (function (param) {
                        return {
                          TAG: /* Eq */ 0,
                          _0: {
                            hd: "test_unsafe_obj_ffi_ppx.cmi",
                            tl: /* [] */ 0
                          },
                          _1: Ext_string_test.split(false, " test_unsafe_obj_ffi_ppx.cmi", /* ' ' */32)
                        };
                      })
                    ],
                    tl: {
                      hd: [
                        "rfind",
                        (function (param) {
                          return {
                            TAG: /* Eq */ 0,
                            _0: 7,
                            _1: Ext_string_test.rfind("__", "__index__js")
                          };
                        })
                      ],
                      tl: {
                        hd: [
                          "rfind_2",
                          (function (param) {
                            return {
                              TAG: /* Eq */ 0,
                              _0: 0,
                              _1: Ext_string_test.rfind("__", "__index_js")
                            };
                          })
                        ],
                        tl: {
                          hd: [
                            "rfind_3",
                            (function (param) {
                              return {
                                TAG: /* Eq */ 0,
                                _0: -1,
                                _1: Ext_string_test.rfind("__", "_index_js")
                              };
                            })
                          ],
                          tl: {
                            hd: [
                              "find",
                              (function (param) {
                                return {
                                  TAG: /* Eq */ 0,
                                  _0: 0,
                                  _1: Ext_string_test.find(undefined, "__", "__index__js")
                                };
                              })
                            ],
                            tl: {
                              hd: [
                                "find_2",
                                (function (param) {
                                  return {
                                    TAG: /* Eq */ 0,
                                    _0: 6,
                                    _1: Ext_string_test.find(undefined, "__", "_index__js")
                                  };
                                })
                              ],
                              tl: {
                                hd: [
                                  "find_3",
                                  (function (param) {
                                    return {
                                      TAG: /* Eq */ 0,
                                      _0: -1,
                                      _1: Ext_string_test.find(undefined, "__", "_index_js")
                                    };
                                  })
                                ],
                                tl: {
                                  hd: [
                                    "of_char",
                                    (function (param) {
                                      return {
                                        TAG: /* Eq */ 0,
                                        _0: String.fromCharCode(/* '0' */48),
                                        _1: Caml_bytes.bytes_to_string(Stdlib__Bytes.make(1, /* '0' */48))
                                      };
                                    })
                                  ],
                                  tl: {
                                    hd: [
                                      "of_chars",
                                      (function (param) {
                                        return {
                                          TAG: /* Eq */ 0,
                                          _0: string_of_chars({
                                            hd: /* '0' */48,
                                            tl: {
                                              hd: /* '1' */49,
                                              tl: {
                                                hd: /* '2' */50,
                                                tl: /* [] */ 0
                                              }
                                            }
                                          }),
                                          _1: "012"
                                        };
                                      })
                                    ],
                                    tl: /* [] */ 0
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
});

module.exports = {
  ff,
  gg,
  rev_split_by_char,
  xsplit,
  string_of_chars,
}
/*  Not a pure module */
