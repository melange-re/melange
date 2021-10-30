'use strict';

var UI = require("@ui");
var Curry = require("../../lib/js/curry.js");
var BUI = require("@blp/ui");
var Runtime = require("@runtime");

var data = [
  {
    ticker: "GOOG",
    price: 700.0
  },
  {
    ticker: "AAPL",
    price: 500.0
  },
  {
    ticker: "MSFT",
    price: 300.0
  }
];

function ui_layout(compile, lookup, appContext) {
  var init = Curry._1(compile, "bid  - ask");
  var computeFunction = {
    contents: (function (env) {
        return Curry._1(init, (function (key) {
                      return Curry._2(lookup, env, key);
                    }));
      })
  };
  var hw1 = new BUI.HostedWindow();
  var hc = new BUI.HostedContent();
  var stackPanel = new UI.StackPanel();
  var inputCode = new UI.TextArea();
  var button = new UI.Button();
  var grid = new UI.Grid();
  hw1.appContext = appContext;
  hw1.title = "Test Application From OCaml";
  hw1.content = hc;
  hc.contentWidth = 700;
  hc.content = stackPanel;
  stackPanel.orientation = "vertical";
  stackPanel.minHeight = 10000;
  stackPanel.minWidth = 4000;
  stackPanel.addChild(grid);
  stackPanel.addChild(inputCode);
  stackPanel.addChild(button);
  var mk_titleRow = function (text) {
    return {
            label: {
              text: text
            }
          };
  };
  var u = {
    width: 200
  };
  grid.minHeight = 300;
  grid.titleRows = [
    {
      label: {
        text: "Ticker"
      }
    },
    {
      label: {
        text: "Bid"
      }
    },
    {
      label: {
        text: "Ask"
      }
    },
    {
      label: {
        text: "Result"
      }
    }
  ];
  grid.columns = [
    u,
    u,
    u,
    u
  ];
  inputCode.text = " bid - ask";
  inputCode.minHeight = 100;
  button.text = "update formula";
  button.minHeight = 20;
  button.on("click", (function (_event) {
          try {
            var hot_function = Curry._1(compile, inputCode.text);
            computeFunction.contents = (function (env) {
                return Curry._1(hot_function, (function (key) {
                              return Curry._2(lookup, env, key);
                            }));
              });
            return ;
          }
          catch (e){
            return ;
          }
        }));
  Runtime.setInterval((function () {
          grid.dataSource = Array.prototype.map.call(data, (function (param) {
                  var price = param.price;
                  var bid = price + 20 * Math.random();
                  var ask = price + 20 * Math.random();
                  var result = Curry._1(computeFunction.contents, {
                        bid: bid,
                        ask: ask
                      });
                  return [
                          mk_titleRow(param.ticker),
                          mk_titleRow(bid.toFixed(2)),
                          mk_titleRow(ask.toFixed(2)),
                          mk_titleRow(result.toFixed(2))
                        ];
                }));
        }), 100);
  return hw1;
}

exports.data = data;
exports.ui_layout = ui_layout;
/* @ui Not a pure module */
