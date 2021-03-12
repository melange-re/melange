'use strict';

var Char = require("./char.js");
var List = require("./list.js");
var Bytes = require("./bytes.js");
var Stream = require("./stream.js");
var Hashtbl = require("./hashtbl.js");
var Caml_bytes = require("./caml_bytes.js");
var Caml_format = require("./caml_format.js");
var Caml_option = require("./caml_option.js");
var Caml_js_exceptions = require("./caml_js_exceptions.js");
var Stdlib__no_aliases = require("./stdlib__no_aliases.js");

var initial_buffer = Caml_bytes.caml_create_bytes(32);

var buffer = {
  contents: initial_buffer
};

var bufpos = {
  contents: 0
};

function reset_buffer(param) {
  buffer[0] = initial_buffer;
  bufpos[0] = 0;
  
}

function store(c) {
  if (bufpos[0] >= buffer[0].length) {
    var newbuffer = Caml_bytes.caml_create_bytes((bufpos[0] << 1));
    Bytes.blit(buffer[0], 0, newbuffer, 0, bufpos[0]);
    buffer[0] = newbuffer;
  }
  Caml_bytes.set(buffer[0], bufpos[0], c);
  bufpos.contents = bufpos.contents + 1 | 0;
  
}

function get_string(param) {
  var s = Bytes.sub_string(buffer[0], 0, bufpos[0]);
  buffer[0] = initial_buffer;
  return s;
}

function make_lexer(keywords) {
  var kwd_table = Hashtbl.create(undefined, 17);
  List.iter((function (s) {
          return Hashtbl.add(kwd_table, s, {
                      TAG: /* Kwd */0,
                      _0: s
                    });
        }), keywords);
  var ident_or_keyword = function (id) {
    try {
      return Hashtbl.find(kwd_table, id);
    }
    catch (raw_exn){
      var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
      if (exn.RE_EXN_ID === Stdlib__no_aliases.Not_found) {
        return {
                TAG: /* Ident */1,
                _0: id
              };
      }
      throw exn;
    }
  };
  var keyword_or_error = function (c) {
    var s = Caml_bytes.bytes_to_string(Bytes.make(1, c));
    try {
      return Hashtbl.find(kwd_table, s);
    }
    catch (raw_exn){
      var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
      if (exn.RE_EXN_ID === Stdlib__no_aliases.Not_found) {
        throw {
              RE_EXN_ID: Stream.$$Error,
              _1: "Illegal character " + s,
              Error: new Error()
            };
      }
      throw exn;
    }
  };
  var next_token = function (strm__) {
    while(true) {
      var c = Stream.peek(strm__);
      if (c === undefined) {
        return ;
      }
      var c$1 = Caml_option.valFromOption(c);
      var exit = 0;
      if (c$1 < 124) {
        if (c$1 > 122 || c$1 < 65) {
          if (c$1 >= 123) {
            exit = 1;
          } else {
            switch (c$1) {
              case 9 :
              case 10 :
              case 12 :
              case 13 :
              case 26 :
              case 32 :
                  Stream.junk(strm__);
                  continue ;
              case 34 :
                  Stream.junk(strm__);
                  reset_buffer(undefined);
                  return {
                          TAG: /* String */4,
                          _0: string(strm__)
                        };
              case 39 :
                  Stream.junk(strm__);
                  var c$2;
                  try {
                    c$2 = $$char(strm__);
                  }
                  catch (raw_exn){
                    var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
                    if (exn.RE_EXN_ID === Stream.Failure) {
                      throw {
                            RE_EXN_ID: Stream.$$Error,
                            _1: "",
                            Error: new Error()
                          };
                    }
                    throw exn;
                  }
                  var match = Stream.peek(strm__);
                  if (match !== undefined) {
                    if (Caml_option.valFromOption(match) !== 39) {
                      throw {
                            RE_EXN_ID: Stream.$$Error,
                            _1: "",
                            Error: new Error()
                          };
                    }
                    Stream.junk(strm__);
                    return {
                            TAG: /* Char */5,
                            _0: c$2
                          };
                  }
                  throw {
                        RE_EXN_ID: Stream.$$Error,
                        _1: "",
                        Error: new Error()
                      };
              case 40 :
                  Stream.junk(strm__);
                  var match$1 = Stream.peek(strm__);
                  if (match$1 !== undefined && Caml_option.valFromOption(match$1) === 42) {
                    Stream.junk(strm__);
                    comment(strm__);
                    return next_token(strm__);
                  } else {
                    return keyword_or_error(/* '(' */40);
                  }
              case 45 :
                  Stream.junk(strm__);
                  var c$3 = Stream.peek(strm__);
                  if (c$3 !== undefined) {
                    var c$4 = Caml_option.valFromOption(c$3);
                    if (c$4 > 57 || c$4 < 48) {
                      reset_buffer(undefined);
                      store(/* '-' */45);
                      return ident2(strm__);
                    } else {
                      Stream.junk(strm__);
                      reset_buffer(undefined);
                      store(/* '-' */45);
                      store(c$4);
                      return number(strm__);
                    }
                  }
                  reset_buffer(undefined);
                  store(/* '-' */45);
                  return ident2(strm__);
              case 48 :
              case 49 :
              case 50 :
              case 51 :
              case 52 :
              case 53 :
              case 54 :
              case 55 :
              case 56 :
              case 57 :
                  exit = 4;
                  break;
              case 0 :
              case 1 :
              case 2 :
              case 3 :
              case 4 :
              case 5 :
              case 6 :
              case 7 :
              case 8 :
              case 11 :
              case 14 :
              case 15 :
              case 16 :
              case 17 :
              case 18 :
              case 19 :
              case 20 :
              case 21 :
              case 22 :
              case 23 :
              case 24 :
              case 25 :
              case 27 :
              case 28 :
              case 29 :
              case 30 :
              case 31 :
              case 41 :
              case 44 :
              case 46 :
              case 59 :
                  exit = 1;
                  break;
              case 33 :
              case 35 :
              case 36 :
              case 37 :
              case 38 :
              case 42 :
              case 43 :
              case 47 :
              case 58 :
              case 60 :
              case 61 :
              case 62 :
              case 63 :
              case 64 :
                  exit = 3;
                  break;
              
            }
          }
        } else {
          switch (c$1) {
            case 92 :
            case 94 :
                exit = 3;
                break;
            case 95 :
                exit = 2;
                break;
            case 91 :
            case 93 :
            case 96 :
                exit = 1;
                break;
            default:
              exit = 2;
          }
        }
      } else {
        exit = c$1 >= 127 ? (
            c$1 >= 192 ? 2 : 1
          ) : (
            c$1 !== 125 ? 3 : 1
          );
      }
      switch (exit) {
        case 1 :
            Stream.junk(strm__);
            return keyword_or_error(c$1);
        case 2 :
            Stream.junk(strm__);
            reset_buffer(undefined);
            store(c$1);
            while(true) {
              var c$5 = Stream.peek(strm__);
              if (c$5 === undefined) {
                return ident_or_keyword(get_string(undefined));
              }
              var c$6 = Caml_option.valFromOption(c$5);
              if (c$6 >= 91) {
                if (c$6 > 122 || c$6 < 95) {
                  if (c$6 < 192) {
                    return ident_or_keyword(get_string(undefined));
                  }
                  
                } else if (c$6 === 96) {
                  return ident_or_keyword(get_string(undefined));
                }
                
              } else if (c$6 >= 48) {
                if (!(c$6 > 64 || c$6 < 58)) {
                  return ident_or_keyword(get_string(undefined));
                }
                
              } else if (c$6 !== 39) {
                return ident_or_keyword(get_string(undefined));
              }
              Stream.junk(strm__);
              store(c$6);
              continue ;
            };
        case 3 :
            Stream.junk(strm__);
            reset_buffer(undefined);
            store(c$1);
            return ident2(strm__);
        case 4 :
            Stream.junk(strm__);
            reset_buffer(undefined);
            store(c$1);
            return number(strm__);
        
      }
    };
  };
  var ident2 = function (strm__) {
    while(true) {
      var c = Stream.peek(strm__);
      if (c === undefined) {
        return ident_or_keyword(get_string(undefined));
      }
      var c$1 = Caml_option.valFromOption(c);
      if (c$1 >= 94) {
        if (c$1 > 125 || c$1 < 95) {
          if (c$1 >= 127) {
            return ident_or_keyword(get_string(undefined));
          }
          
        } else if (c$1 !== 124) {
          return ident_or_keyword(get_string(undefined));
        }
        
      } else if (c$1 >= 65) {
        if (c$1 !== 92) {
          return ident_or_keyword(get_string(undefined));
        }
        
      } else {
        if (c$1 < 33) {
          return ident_or_keyword(get_string(undefined));
        }
        switch (c$1) {
          case 34 :
          case 39 :
          case 40 :
          case 41 :
          case 44 :
          case 46 :
          case 48 :
          case 49 :
          case 50 :
          case 51 :
          case 52 :
          case 53 :
          case 54 :
          case 55 :
          case 56 :
          case 57 :
          case 59 :
              return ident_or_keyword(get_string(undefined));
          case 33 :
          case 35 :
          case 36 :
          case 37 :
          case 38 :
          case 42 :
          case 43 :
          case 45 :
          case 47 :
          case 58 :
          case 60 :
          case 61 :
          case 62 :
          case 63 :
          case 64 :
              break;
          
        }
      }
      Stream.junk(strm__);
      store(c$1);
      continue ;
    };
  };
  var number = function (strm__) {
    while(true) {
      var c = Stream.peek(strm__);
      if (c !== undefined) {
        var c$1 = Caml_option.valFromOption(c);
        if (c$1 >= 58) {
          if (!(c$1 !== 69 && c$1 !== 101)) {
            Stream.junk(strm__);
            store(/* 'E' */69);
            return exponent_part(strm__);
          }
          
        } else if (c$1 !== 46) {
          if (c$1 >= 48) {
            Stream.junk(strm__);
            store(c$1);
            continue ;
          }
          
        } else {
          Stream.junk(strm__);
          store(/* '.' */46);
          while(true) {
            var c$2 = Stream.peek(strm__);
            if (c$2 !== undefined) {
              var c$3 = Caml_option.valFromOption(c$2);
              if (c$3 > 101 || c$3 < 69) {
                if (!(c$3 > 57 || c$3 < 48)) {
                  Stream.junk(strm__);
                  store(c$3);
                  continue ;
                }
                
              } else if (c$3 > 100 || c$3 < 70) {
                Stream.junk(strm__);
                store(/* 'E' */69);
                return exponent_part(strm__);
              }
              
            }
            return {
                    TAG: /* Float */3,
                    _0: Caml_format.caml_float_of_string(get_string(undefined))
                  };
          };
        }
      }
      return {
              TAG: /* Int */2,
              _0: Caml_format.caml_int_of_string(get_string(undefined))
            };
    };
  };
  var exponent_part = function (strm__) {
    var c = Stream.peek(strm__);
    if (c === undefined) {
      return end_exponent_part(strm__);
    }
    var c$1 = Caml_option.valFromOption(c);
    if (c$1 !== 43 && c$1 !== 45) {
      return end_exponent_part(strm__);
    } else {
      Stream.junk(strm__);
      store(c$1);
      return end_exponent_part(strm__);
    }
  };
  var end_exponent_part = function (strm__) {
    while(true) {
      var c = Stream.peek(strm__);
      if (c === undefined) {
        return {
                TAG: /* Float */3,
                _0: Caml_format.caml_float_of_string(get_string(undefined))
              };
      }
      var c$1 = Caml_option.valFromOption(c);
      if (c$1 > 57 || c$1 < 48) {
        return {
                TAG: /* Float */3,
                _0: Caml_format.caml_float_of_string(get_string(undefined))
              };
      }
      Stream.junk(strm__);
      store(c$1);
      continue ;
    };
  };
  var string = function (strm__) {
    while(true) {
      var c = Stream.peek(strm__);
      if (c !== undefined) {
        var c$1 = Caml_option.valFromOption(c);
        if (c$1 !== 34) {
          if (c$1 !== 92) {
            Stream.junk(strm__);
            store(c$1);
            continue ;
          }
          Stream.junk(strm__);
          var c$2;
          try {
            c$2 = $$escape(strm__);
          }
          catch (raw_exn){
            var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
            if (exn.RE_EXN_ID === Stream.Failure) {
              throw {
                    RE_EXN_ID: Stream.$$Error,
                    _1: "",
                    Error: new Error()
                  };
            }
            throw exn;
          }
          store(c$2);
          continue ;
        }
        Stream.junk(strm__);
        return get_string(undefined);
      }
      throw {
            RE_EXN_ID: Stream.Failure,
            Error: new Error()
          };
    };
  };
  var $$char = function (strm__) {
    var c = Stream.peek(strm__);
    if (c !== undefined) {
      var c$1 = Caml_option.valFromOption(c);
      if (c$1 !== 92) {
        Stream.junk(strm__);
        return c$1;
      }
      Stream.junk(strm__);
      try {
        return $$escape(strm__);
      }
      catch (raw_exn){
        var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
        if (exn.RE_EXN_ID === Stream.Failure) {
          throw {
                RE_EXN_ID: Stream.$$Error,
                _1: "",
                Error: new Error()
              };
        }
        throw exn;
      }
    } else {
      throw {
            RE_EXN_ID: Stream.Failure,
            Error: new Error()
          };
    }
  };
  var $$escape = function (strm__) {
    var c1 = Stream.peek(strm__);
    if (c1 !== undefined) {
      var c1$1 = Caml_option.valFromOption(c1);
      if (c1$1 >= 58) {
        switch (c1$1) {
          case 110 :
              Stream.junk(strm__);
              return /* '\n' */10;
          case 114 :
              Stream.junk(strm__);
              return /* '\r' */13;
          case 111 :
          case 112 :
          case 113 :
          case 115 :
              Stream.junk(strm__);
              return c1$1;
          case 116 :
              Stream.junk(strm__);
              return /* '\t' */9;
          default:
            Stream.junk(strm__);
            return c1$1;
        }
      } else {
        if (c1$1 >= 48) {
          Stream.junk(strm__);
          var c2 = Stream.peek(strm__);
          if (c2 !== undefined) {
            var c2$1 = Caml_option.valFromOption(c2);
            if (c2$1 > 57 || c2$1 < 48) {
              throw {
                    RE_EXN_ID: Stream.$$Error,
                    _1: "",
                    Error: new Error()
                  };
            }
            Stream.junk(strm__);
            var c3 = Stream.peek(strm__);
            if (c3 !== undefined) {
              var c3$1 = Caml_option.valFromOption(c3);
              if (c3$1 > 57 || c3$1 < 48) {
                throw {
                      RE_EXN_ID: Stream.$$Error,
                      _1: "",
                      Error: new Error()
                    };
              }
              Stream.junk(strm__);
              return Char.chr((Math.imul(c1$1 - 48 | 0, 100) + Math.imul(c2$1 - 48 | 0, 10) | 0) + (c3$1 - 48 | 0) | 0);
            }
            throw {
                  RE_EXN_ID: Stream.$$Error,
                  _1: "",
                  Error: new Error()
                };
          }
          throw {
                RE_EXN_ID: Stream.$$Error,
                _1: "",
                Error: new Error()
              };
        }
        Stream.junk(strm__);
        return c1$1;
      }
    } else {
      throw {
            RE_EXN_ID: Stream.Failure,
            Error: new Error()
          };
    }
  };
  var comment = function (strm__) {
    while(true) {
      var match = Stream.peek(strm__);
      if (match !== undefined) {
        switch (Caml_option.valFromOption(match)) {
          case 40 :
              Stream.junk(strm__);
              var match$1 = Stream.peek(strm__);
              if (match$1 !== undefined) {
                if (Caml_option.valFromOption(match$1) !== 42) {
                  Stream.junk(strm__);
                  return comment(strm__);
                } else {
                  Stream.junk(strm__);
                  comment(strm__);
                  return comment(strm__);
                }
              }
              throw {
                    RE_EXN_ID: Stream.Failure,
                    Error: new Error()
                  };
          case 41 :
              Stream.junk(strm__);
              continue ;
          case 42 :
              Stream.junk(strm__);
              while(true) {
                var match$2 = Stream.peek(strm__);
                if (match$2 !== undefined) {
                  var match$3 = Caml_option.valFromOption(match$2);
                  if (match$3 !== 41) {
                    if (match$3 !== 42) {
                      Stream.junk(strm__);
                      return comment(strm__);
                    }
                    Stream.junk(strm__);
                    continue ;
                  }
                  Stream.junk(strm__);
                  return ;
                }
                throw {
                      RE_EXN_ID: Stream.Failure,
                      Error: new Error()
                    };
              };
          default:
            Stream.junk(strm__);
            continue ;
        }
      } else {
        throw {
              RE_EXN_ID: Stream.Failure,
              Error: new Error()
            };
      }
    };
  };
  return function (input) {
    return Stream.from(function (_count) {
                return next_token(input);
              });
  };
}

exports.make_lexer = make_lexer;
/* Hashtbl Not a pure module */
