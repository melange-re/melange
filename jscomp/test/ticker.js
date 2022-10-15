'use strict';

var $$Map = require("melange/jscomp/stdlib-412/stdlib_modules/map.js");
var Caml = require("melange/lib/js/caml.js");
var List = require("melange/jscomp/stdlib-412/stdlib_modules/list.js");
var Curry = require("melange/lib/js/curry.js");
var Printf = require("melange/jscomp/stdlib-412/stdlib_modules/printf.js");
var Stdlib = require("melange/jscomp/stdlib-412/stdlib.js");
var $$String = require("melange/jscomp/stdlib-412/stdlib_modules/string.js");
var Caml_obj = require("melange/lib/js/caml_obj.js");
var Caml_format = require("melange/lib/js/caml_format.js");
var Caml_option = require("melange/lib/js/caml_option.js");
var Caml_js_exceptions = require("melange/lib/js/caml_js_exceptions.js");

function split(delim, s) {
  var len = s.length;
  if (len !== 0) {
    var _l = /* [] */0;
    var _i = len;
    while(true) {
      var i = _i;
      var l = _l;
      if (i === 0) {
        return l;
      }
      var i$p;
      try {
        i$p = $$String.rindex_from(s, i - 1 | 0, delim);
      }
      catch (raw_exn){
        var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
        if (exn.RE_EXN_ID === Stdlib.Not_found) {
          return {
                  hd: $$String.sub(s, 0, i),
                  tl: l
                };
        }
        throw exn;
      }
      var l_0 = $$String.sub(s, i$p + 1 | 0, (i - i$p | 0) - 1 | 0);
      var l$1 = {
        hd: l_0,
        tl: l
      };
      var l$2 = i$p === 0 ? ({
            hd: "",
            tl: l$1
          }) : l$1;
      _i = i$p;
      _l = l$2;
      continue ;
    };
  } else {
    return /* [] */0;
  }
}

function string_of_float_option(x) {
  if (x !== undefined) {
    return Stdlib.string_of_float(x);
  } else {
    return "nan";
  }
}

var Util = {
  split: split,
  string_of_float_option: string_of_float_option
};

function string_of_rank(i) {
  if (typeof i === "number") {
    if (i) {
      return "Visited";
    } else {
      return "Uninitialized";
    }
  } else {
    return Curry._1(Printf.sprintf(/* Format */{
                    _0: {
                      TAG: /* String_literal */11,
                      _0: "Ranked(",
                      _1: {
                        TAG: /* Int */4,
                        _0: /* Int_i */3,
                        _1: /* No_padding */0,
                        _2: /* No_precision */0,
                        _3: {
                          TAG: /* Char_literal */12,
                          _0: /* ')' */41,
                          _1: /* End_of_format */0
                        }
                      }
                    },
                    _1: "Ranked(%i)"
                  }), i._0);
  }
}

function find_ticker_by_name(all_tickers, ticker) {
  return List.find((function (param) {
                return param.ticker_name === ticker;
              }), all_tickers);
}

function print_all_composite(all_tickers) {
  List.iter((function (param) {
          if (param.type_) {
            console.log(param.ticker_name);
            return ;
          }
          
        }), all_tickers);
}

var compare = Caml_obj.caml_compare;

var Ticker_map = $$Map.Make({
      compare: compare
    });

function compute_update_sequences(all_tickers) {
  List.fold_left((function (counter, ticker) {
          var loop = function (counter, ticker) {
            var rank = ticker.rank;
            if (typeof rank !== "number") {
              return counter;
            }
            if (rank) {
              return counter;
            }
            ticker.rank = /* Visited */1;
            var match = ticker.type_;
            if (match) {
              var match$1 = match._0;
              var counter$1 = loop(counter, match$1.lhs);
              var counter$2 = loop(counter$1, match$1.rhs);
              var counter$3 = counter$2 + 1 | 0;
              ticker.rank = /* Ranked */{
                _0: counter$3
              };
              return counter$3;
            }
            var counter$4 = counter + 1 | 0;
            ticker.rank = /* Ranked */{
              _0: counter$4
            };
            return counter$4;
          };
          return loop(counter, ticker);
        }), 0, all_tickers);
  var map = List.fold_left((function (map, ticker) {
          if (!ticker.type_) {
            return Curry._3(Ticker_map.add, ticker.ticker_name, {
                        hd: ticker,
                        tl: /* [] */0
                      }, map);
          }
          var loop = function (_up, _map, _ticker) {
            while(true) {
              var ticker = _ticker;
              var map = _map;
              var up = _up;
              var type_ = ticker.type_;
              var ticker_name = ticker.ticker_name;
              if (type_) {
                var match = type_._0;
                var map$1 = loop({
                      hd: ticker,
                      tl: up
                    }, map, match.lhs);
                _ticker = match.rhs;
                _map = map$1;
                _up = {
                  hd: ticker,
                  tl: up
                };
                continue ;
              }
              var l = Curry._2(Ticker_map.find, ticker_name, map);
              return Curry._3(Ticker_map.add, ticker_name, Stdlib.$at(up, l), map);
            };
          };
          return loop(/* [] */0, map, ticker);
        }), Ticker_map.empty, List.rev(all_tickers));
  return Curry._3(Ticker_map.fold, (function (k, l, map) {
                var l$1 = List.sort_uniq((function (lhs, rhs) {
                        var x = lhs.rank;
                        if (typeof x === "number") {
                          return Stdlib.failwith("All nodes should be ranked");
                        }
                        var y = rhs.rank;
                        if (typeof y === "number") {
                          return Stdlib.failwith("All nodes should be ranked");
                        } else {
                          return Caml.caml_int_compare(x._0, y._0);
                        }
                      }), l);
                return Curry._3(Ticker_map.add, k, l$1, map);
              }), map, map);
}

function process_quote(ticker_map, new_ticker, new_value) {
  var update_sequence = Curry._2(Ticker_map.find, new_ticker, ticker_map);
  List.iter((function (ticker) {
          var match = ticker.type_;
          if (!match) {
            if (ticker.ticker_name === new_ticker) {
              ticker.value = new_value;
              return ;
            } else {
              return Stdlib.failwith("Only single Market ticker should be udpated upon a new quote");
            }
          }
          var match$1 = match._0;
          var match$2 = match$1.lhs.value;
          var match$3 = match$1.rhs.value;
          var value = match$2 !== undefined && match$3 !== undefined ? (
              match$1.op ? match$2 - match$3 : match$2 + match$3
            ) : undefined;
          ticker.value = value;
        }), update_sequence);
}

function process_input_line(ticker_map, all_tickers, line) {
  var make_binary_op = function (ticker_name, lhs, rhs, op) {
    var lhs$1 = find_ticker_by_name(all_tickers, lhs);
    var rhs$1 = find_ticker_by_name(all_tickers, rhs);
    return {
            value: undefined,
            rank: /* Uninitialized */0,
            ticker_name: ticker_name,
            type_: /* Binary_op */{
              _0: {
                op: op,
                rhs: rhs$1,
                lhs: lhs$1
              }
            }
          };
  };
  var tokens = split(/* '|' */124, line);
  if (!tokens) {
    return Stdlib.failwith("Invalid input line");
  }
  switch (tokens.hd) {
    case "Q" :
        var match = tokens.tl;
        if (!match) {
          return Stdlib.failwith("Invalid input line");
        }
        var match$1 = match.tl;
        if (!match$1) {
          return Stdlib.failwith("Invalid input line");
        }
        if (match$1.tl) {
          return Stdlib.failwith("Invalid input line");
        }
        var ticker_map$1 = ticker_map !== undefined ? Caml_option.valFromOption(ticker_map) : compute_update_sequences(all_tickers);
        var value = Caml_format.caml_float_of_string(match$1.hd);
        process_quote(ticker_map$1, match.hd, value);
        return [
                all_tickers,
                Caml_option.some(ticker_map$1)
              ];
    case "R" :
        var match$2 = tokens.tl;
        if (!match$2) {
          return Stdlib.failwith("Invalid input line");
        }
        var match$3 = match$2.tl;
        if (!match$3) {
          return Stdlib.failwith("Invalid input line");
        }
        var ticker_name = match$2.hd;
        switch (match$3.hd) {
          case "+" :
              var match$4 = match$3.tl;
              if (!match$4) {
                return Stdlib.failwith("Invalid input line");
              }
              var match$5 = match$4.tl;
              if (match$5 && !match$5.tl) {
                return [
                        {
                          hd: make_binary_op(ticker_name, match$4.hd, match$5.hd, /* PLUS */0),
                          tl: all_tickers
                        },
                        ticker_map
                      ];
              } else {
                return Stdlib.failwith("Invalid input line");
              }
          case "-" :
              var match$6 = match$3.tl;
              if (!match$6) {
                return Stdlib.failwith("Invalid input line");
              }
              var match$7 = match$6.tl;
              if (match$7 && !match$7.tl) {
                return [
                        {
                          hd: make_binary_op(ticker_name, match$6.hd, match$7.hd, /* MINUS */1),
                          tl: all_tickers
                        },
                        ticker_map
                      ];
              } else {
                return Stdlib.failwith("Invalid input line");
              }
          case "S" :
              if (match$3.tl) {
                return Stdlib.failwith("Invalid input line");
              } else {
                return [
                        {
                          hd: {
                            value: undefined,
                            rank: /* Uninitialized */0,
                            ticker_name: ticker_name,
                            type_: /* Market */0
                          },
                          tl: all_tickers
                        },
                        ticker_map
                      ];
              }
          default:
            return Stdlib.failwith("Invalid input line");
        }
    default:
      return Stdlib.failwith("Invalid input line");
  }
}

function loop(_lines, _param) {
  while(true) {
    var param = _param;
    var lines = _lines;
    var all_tickers = param[0];
    if (!lines) {
      return print_all_composite(all_tickers);
    }
    _param = process_input_line(param[1], all_tickers, lines.hd);
    _lines = lines.tl;
    continue ;
  };
}

var lines = {
  hd: "R|MSFT|S",
  tl: {
    hd: "R|IBM|S",
    tl: {
      hd: "R|FB|S",
      tl: {
        hd: "R|CP1|+|MSFT|IBM",
        tl: {
          hd: "R|CP2|-|FB|IBM",
          tl: {
            hd: "R|CP12|+|CP1|CP2",
            tl: {
              hd: "Q|MSFT|120.",
              tl: {
                hd: "Q|IBM|130.",
                tl: {
                  hd: "Q|FB|80.",
                  tl: /* [] */0
                }
              }
            }
          }
        }
      }
    }
  }
};

exports.Util = Util;
exports.string_of_rank = string_of_rank;
exports.find_ticker_by_name = find_ticker_by_name;
exports.print_all_composite = print_all_composite;
exports.Ticker_map = Ticker_map;
exports.compute_update_sequences = compute_update_sequences;
exports.process_quote = process_quote;
exports.process_input_line = process_input_line;
exports.lines = lines;
exports.loop = loop;
/* Ticker_map Not a pure module */
