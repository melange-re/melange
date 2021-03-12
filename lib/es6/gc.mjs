

import * as Sys from "./sys.mjs";
import * as Curry from "./curry.mjs";
import * as Printf from "./printf.mjs";
import * as Caml_option from "./caml_option.mjs";
import * as Stdlib__no_aliases from "./stdlib__no_aliases.mjs";
import * as Caml_external_polyfill from "./caml_external_polyfill.mjs";

function print_stat(c) {
  var st = Caml_external_polyfill.resolve("caml_gc_stat")(undefined);
  Curry._1(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "minor_collections:      ",
              _1: {
                TAG: /* Int */4,
                _0: /* Int_d */0,
                _1: /* No_padding */0,
                _2: /* No_precision */0,
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "minor_collections:      %d\n"
          }), st.minor_collections);
  Curry._1(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "major_collections:      ",
              _1: {
                TAG: /* Int */4,
                _0: /* Int_d */0,
                _1: /* No_padding */0,
                _2: /* No_precision */0,
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "major_collections:      %d\n"
          }), st.major_collections);
  Curry._1(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "compactions:            ",
              _1: {
                TAG: /* Int */4,
                _0: /* Int_d */0,
                _1: /* No_padding */0,
                _2: /* No_precision */0,
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "compactions:            %d\n"
          }), st.compactions);
  Curry._1(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "forced_major_collections: ",
              _1: {
                TAG: /* Int */4,
                _0: /* Int_d */0,
                _1: /* No_padding */0,
                _2: /* No_precision */0,
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "forced_major_collections: %d\n"
          }), st.forced_major_collections);
  Printf.fprintf(c, /* Format */{
        _0: {
          TAG: /* Char_literal */12,
          _0: /* '\n' */10,
          _1: /* End_of_format */0
        },
        _1: "\n"
      });
  var l1 = Curry._1(Printf.sprintf(/* Format */{
            _0: {
              TAG: /* Float */8,
              _0: [
                /* Float_flag_ */0,
                /* Float_f */0
              ],
              _1: /* No_padding */0,
              _2: /* Lit_precision */{
                _0: 0
              },
              _3: /* End_of_format */0
            },
            _1: "%.0f"
          }), st.minor_words).length;
  Curry._2(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "minor_words:    ",
              _1: {
                TAG: /* Float */8,
                _0: [
                  /* Float_flag_ */0,
                  /* Float_f */0
                ],
                _1: {
                  TAG: /* Arg_padding */1,
                  _0: /* Right */1
                },
                _2: /* Lit_precision */{
                  _0: 0
                },
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "minor_words:    %*.0f\n"
          }), l1, st.minor_words);
  Curry._2(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "promoted_words: ",
              _1: {
                TAG: /* Float */8,
                _0: [
                  /* Float_flag_ */0,
                  /* Float_f */0
                ],
                _1: {
                  TAG: /* Arg_padding */1,
                  _0: /* Right */1
                },
                _2: /* Lit_precision */{
                  _0: 0
                },
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "promoted_words: %*.0f\n"
          }), l1, st.promoted_words);
  Curry._2(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "major_words:    ",
              _1: {
                TAG: /* Float */8,
                _0: [
                  /* Float_flag_ */0,
                  /* Float_f */0
                ],
                _1: {
                  TAG: /* Arg_padding */1,
                  _0: /* Right */1
                },
                _2: /* Lit_precision */{
                  _0: 0
                },
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "major_words:    %*.0f\n"
          }), l1, st.major_words);
  Printf.fprintf(c, /* Format */{
        _0: {
          TAG: /* Char_literal */12,
          _0: /* '\n' */10,
          _1: /* End_of_format */0
        },
        _1: "\n"
      });
  var l2 = Curry._1(Printf.sprintf(/* Format */{
            _0: {
              TAG: /* Int */4,
              _0: /* Int_d */0,
              _1: /* No_padding */0,
              _2: /* No_precision */0,
              _3: /* End_of_format */0
            },
            _1: "%d"
          }), st.top_heap_words).length;
  Curry._2(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "top_heap_words: ",
              _1: {
                TAG: /* Int */4,
                _0: /* Int_d */0,
                _1: {
                  TAG: /* Arg_padding */1,
                  _0: /* Right */1
                },
                _2: /* No_precision */0,
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "top_heap_words: %*d\n"
          }), l2, st.top_heap_words);
  Curry._2(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "heap_words:     ",
              _1: {
                TAG: /* Int */4,
                _0: /* Int_d */0,
                _1: {
                  TAG: /* Arg_padding */1,
                  _0: /* Right */1
                },
                _2: /* No_precision */0,
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "heap_words:     %*d\n"
          }), l2, st.heap_words);
  Curry._2(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "live_words:     ",
              _1: {
                TAG: /* Int */4,
                _0: /* Int_d */0,
                _1: {
                  TAG: /* Arg_padding */1,
                  _0: /* Right */1
                },
                _2: /* No_precision */0,
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "live_words:     %*d\n"
          }), l2, st.live_words);
  Curry._2(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "free_words:     ",
              _1: {
                TAG: /* Int */4,
                _0: /* Int_d */0,
                _1: {
                  TAG: /* Arg_padding */1,
                  _0: /* Right */1
                },
                _2: /* No_precision */0,
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "free_words:     %*d\n"
          }), l2, st.free_words);
  Curry._2(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "largest_free:   ",
              _1: {
                TAG: /* Int */4,
                _0: /* Int_d */0,
                _1: {
                  TAG: /* Arg_padding */1,
                  _0: /* Right */1
                },
                _2: /* No_precision */0,
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "largest_free:   %*d\n"
          }), l2, st.largest_free);
  Curry._2(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "fragments:      ",
              _1: {
                TAG: /* Int */4,
                _0: /* Int_d */0,
                _1: {
                  TAG: /* Arg_padding */1,
                  _0: /* Right */1
                },
                _2: /* No_precision */0,
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "fragments:      %*d\n"
          }), l2, st.fragments);
  Printf.fprintf(c, /* Format */{
        _0: {
          TAG: /* Char_literal */12,
          _0: /* '\n' */10,
          _1: /* End_of_format */0
        },
        _1: "\n"
      });
  Curry._1(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "live_blocks: ",
              _1: {
                TAG: /* Int */4,
                _0: /* Int_d */0,
                _1: /* No_padding */0,
                _2: /* No_precision */0,
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "live_blocks: %d\n"
          }), st.live_blocks);
  Curry._1(Printf.fprintf(c, /* Format */{
            _0: {
              TAG: /* String_literal */11,
              _0: "free_blocks: ",
              _1: {
                TAG: /* Int */4,
                _0: /* Int_d */0,
                _1: /* No_padding */0,
                _2: /* No_precision */0,
                _3: {
                  TAG: /* Char_literal */12,
                  _0: /* '\n' */10,
                  _1: /* End_of_format */0
                }
              }
            },
            _1: "free_blocks: %d\n"
          }), st.free_blocks);
  return Curry._1(Printf.fprintf(c, /* Format */{
                  _0: {
                    TAG: /* String_literal */11,
                    _0: "heap_chunks: ",
                    _1: {
                      TAG: /* Int */4,
                      _0: /* Int_d */0,
                      _1: /* No_padding */0,
                      _2: /* No_precision */0,
                      _3: {
                        TAG: /* Char_literal */12,
                        _0: /* '\n' */10,
                        _1: /* End_of_format */0
                      }
                    }
                  },
                  _1: "heap_chunks: %d\n"
                }), st.heap_chunks);
}

function allocated_bytes(param) {
  var match = Caml_external_polyfill.resolve("caml_gc_counters")(undefined);
  return (match[0] + match[2] - match[1]) * (Sys.word_size / 8 | 0);
}

function call_alarm(arec) {
  if (arec.active[0]) {
    Caml_external_polyfill.resolve("caml_final_register")(call_alarm, arec);
    return Curry._1(arec.f, undefined);
  }
  
}

function create_alarm(f) {
  var arec_active = {
    contents: true
  };
  var arec = {
    active: arec_active,
    f: f
  };
  Caml_external_polyfill.resolve("caml_final_register")(call_alarm, arec);
  return arec_active;
}

function delete_alarm(a) {
  a[0] = false;
  
}

function null_tracker_alloc_minor(param) {
  
}

function null_tracker_alloc_major(param) {
  
}

function null_tracker_promote(param) {
  
}

function null_tracker_dealloc_minor(param) {
  
}

function null_tracker_dealloc_major(param) {
  
}

var null_tracker = {
  alloc_minor: null_tracker_alloc_minor,
  alloc_major: null_tracker_alloc_major,
  promote: null_tracker_promote,
  dealloc_minor: null_tracker_dealloc_minor,
  dealloc_major: null_tracker_dealloc_major
};

function start(sampling_rate, callstack_sizeOpt, tracker) {
  var callstack_size = callstack_sizeOpt !== undefined ? Caml_option.valFromOption(callstack_sizeOpt) : Stdlib__no_aliases.max_int;
  return Caml_external_polyfill.resolve("caml_memprof_start")(sampling_rate, callstack_size, tracker);
}

function finalise(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_final_register")(prim, prim$1);
}

function finalise_last(prim, prim$1) {
  return Caml_external_polyfill.resolve("caml_final_register_called_without_value")(prim, prim$1);
}

function finalise_release(prim) {
  return Caml_external_polyfill.resolve("caml_final_release")(prim);
}

function Memprof_stop(prim) {
  return Caml_external_polyfill.resolve("caml_memprof_stop")(prim);
}

var Memprof = {
  null_tracker: null_tracker,
  start: start,
  stop: Memprof_stop
};

export {
  print_stat ,
  allocated_bytes ,
  finalise ,
  finalise_last ,
  finalise_release ,
  create_alarm ,
  delete_alarm ,
  Memprof ,
  
}
/* No side effect */
