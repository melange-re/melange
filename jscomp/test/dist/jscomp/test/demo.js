// Generated by Melange
'use strict';

const BUI = require("@blp/ui");
const Runtime = require("@runtime");
const UI = require("@ui");
const Curry = require("melange.js/curry.js");

const data = [
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
  const init = Curry._1(compile, "bid  - ask");
  const computeFunction = {
    contents: (function (env) {
      return Curry._1(init, (function (key) {
        return Curry._2(lookup, env, key);
      }));
    })
  };
  const hw1 = new BUI.HostedWindow();
  const hc = new BUI.HostedContent();
  const stackPanel = new UI.StackPanel();
  const inputCode = new UI.TextArea();
  const button = new UI.Button();
  const grid = new UI.Grid();
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
  const mk_titleRow = function (text) {
    return {
      label: {
        text: text
      }
    };
  };
  const u = {
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
      const hot_function = Curry._1(compile, inputCode.text);
      computeFunction.contents = (function (env) {
        return Curry._1(hot_function, (function (key) {
          return Curry._2(lookup, env, key);
        }));
      });
      return;
    }
    catch (e){
      return;
    }
  }));
  Runtime.setInterval((function () {
    grid.dataSource = Array.prototype.map.call(data, (function (param) {
      const price = param.price;
      const bid = price + 20 * Math.random();
      const ask = price + 20 * Math.random();
      const result = Curry._1(computeFunction.contents, {
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

module.exports = {
  data,
  ui_layout,
}
/* @blp/ui Not a pure module */
