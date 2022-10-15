'use strict';

var $$Set = require("melange/lib/js/set.js");
var List = require("melange/lib/js/list.js");
var Curry = require("melange/lib/js/curry.js");
var Stdlib = require("melange/lib/js/stdlib.js");
var $$String = require("melange/lib/js/string.js");
var Caml_obj = require("melange/lib/js/caml_obj.js");
var Caml_exceptions = require("melange/lib/js/caml_exceptions.js");
var Caml_js_exceptions = require("melange/lib/js/caml_js_exceptions.js");

var graph = {
  hd: [
    "a",
    "b"
  ],
  tl: {
    hd: [
      "a",
      "c"
    ],
    tl: {
      hd: [
        "a",
        "d"
      ],
      tl: {
        hd: [
          "b",
          "e"
        ],
        tl: {
          hd: [
            "c",
            "f"
          ],
          tl: {
            hd: [
              "d",
              "e"
            ],
            tl: {
              hd: [
                "e",
                "f"
              ],
              tl: {
                hd: [
                  "e",
                  "g"
                ],
                tl: /* [] */0
              }
            }
          }
        }
      }
    }
  }
};

function nexts(x, g) {
  return List.fold_left((function (acc, param) {
                if (param[0] === x) {
                  return {
                          hd: param[1],
                          tl: acc
                        };
                } else {
                  return acc;
                }
              }), /* [] */0, g);
}

function dfs1(_nodes, graph, _visited) {
  while(true) {
    var visited = _visited;
    var nodes = _nodes;
    if (!nodes) {
      return List.rev(visited);
    }
    var xs = nodes.tl;
    var x = nodes.hd;
    if (List.mem(x, visited)) {
      _nodes = xs;
      continue ;
    }
    console.log(x);
    _visited = {
      hd: x,
      tl: visited
    };
    _nodes = Stdlib.$at(nexts(x, graph), xs);
    continue ;
  };
}

if (!Caml_obj.caml_equal(dfs1({
            hd: "a",
            tl: /* [] */0
          }, graph, /* [] */0), {
        hd: "a",
        tl: {
          hd: "d",
          tl: {
            hd: "e",
            tl: {
              hd: "g",
              tl: {
                hd: "f",
                tl: {
                  hd: "c",
                  tl: {
                    hd: "b",
                    tl: /* [] */0
                  }
                }
              }
            }
          }
        }
      })) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "topsort_test.ml",
          29,
          2
        ],
        Error: new Error()
      };
}

Stdlib.print_newline(undefined);

if (!Caml_obj.caml_equal(dfs1({
            hd: "b",
            tl: /* [] */0
          }, {
            hd: [
              "f",
              "d"
            ],
            tl: graph
          }, /* [] */0), {
        hd: "b",
        tl: {
          hd: "e",
          tl: {
            hd: "g",
            tl: {
              hd: "f",
              tl: {
                hd: "d",
                tl: /* [] */0
              }
            }
          }
        }
      })) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "topsort_test.ml",
          32,
          2
        ],
        Error: new Error()
      };
}

function dfs2(nodes, graph, visited) {
  var aux = function (_nodes, graph, _visited) {
    while(true) {
      var visited = _visited;
      var nodes = _nodes;
      if (!nodes) {
        return visited;
      }
      var xs = nodes.tl;
      var x = nodes.hd;
      if (List.mem(x, visited)) {
        _nodes = xs;
        continue ;
      }
      _visited = aux(nexts(x, graph), graph, {
            hd: x,
            tl: visited
          });
      _nodes = xs;
      continue ;
    };
  };
  return List.rev(aux(nodes, graph, visited));
}

if (!Caml_obj.caml_equal(dfs2({
            hd: "a",
            tl: /* [] */0
          }, graph, /* [] */0), {
        hd: "a",
        tl: {
          hd: "d",
          tl: {
            hd: "e",
            tl: {
              hd: "g",
              tl: {
                hd: "f",
                tl: {
                  hd: "c",
                  tl: {
                    hd: "b",
                    tl: /* [] */0
                  }
                }
              }
            }
          }
        }
      })) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "topsort_test.ml",
          47,
          2
        ],
        Error: new Error()
      };
}

if (!Caml_obj.caml_equal(dfs2({
            hd: "b",
            tl: /* [] */0
          }, {
            hd: [
              "f",
              "d"
            ],
            tl: graph
          }, /* [] */0), {
        hd: "b",
        tl: {
          hd: "e",
          tl: {
            hd: "g",
            tl: {
              hd: "f",
              tl: {
                hd: "d",
                tl: /* [] */0
              }
            }
          }
        }
      })) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "topsort_test.ml",
          48,
          2
        ],
        Error: new Error()
      };
}

function dfs3(nodes, graph) {
  var visited = {
    contents: /* [] */0
  };
  var aux = function (node, graph) {
    if (!List.mem(node, visited.contents)) {
      visited.contents = {
        hd: node,
        tl: visited.contents
      };
      return List.iter((function (x) {
                    aux(x, graph);
                  }), nexts(node, graph));
    }
    
  };
  List.iter((function (node) {
          aux(node, graph);
        }), nodes);
  return List.rev(visited.contents);
}

if (!Caml_obj.caml_equal(dfs3({
            hd: "a",
            tl: /* [] */0
          }, graph), {
        hd: "a",
        tl: {
          hd: "d",
          tl: {
            hd: "e",
            tl: {
              hd: "g",
              tl: {
                hd: "f",
                tl: {
                  hd: "c",
                  tl: {
                    hd: "b",
                    tl: /* [] */0
                  }
                }
              }
            }
          }
        }
      })) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "topsort_test.ml",
          65,
          2
        ],
        Error: new Error()
      };
}

if (!Caml_obj.caml_equal(dfs3({
            hd: "b",
            tl: /* [] */0
          }, {
            hd: [
              "f",
              "d"
            ],
            tl: graph
          }), {
        hd: "b",
        tl: {
          hd: "e",
          tl: {
            hd: "g",
            tl: {
              hd: "f",
              tl: {
                hd: "d",
                tl: /* [] */0
              }
            }
          }
        }
      })) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "topsort_test.ml",
          66,
          2
        ],
        Error: new Error()
      };
}

var grwork = {
  hd: [
    "wake",
    "shower"
  ],
  tl: {
    hd: [
      "shower",
      "dress"
    ],
    tl: {
      hd: [
        "dress",
        "go"
      ],
      tl: {
        hd: [
          "wake",
          "eat"
        ],
        tl: {
          hd: [
            "eat",
            "washup"
          ],
          tl: {
            hd: [
              "washup",
              "go"
            ],
            tl: /* [] */0
          }
        }
      }
    }
  }
};

function unsafe_topsort(graph) {
  var visited = {
    contents: /* [] */0
  };
  var sort_node = function (node) {
    if (List.mem(node, visited.contents)) {
      return ;
    }
    var nodes = nexts(node, graph);
    List.iter(sort_node, nodes);
    visited.contents = {
      hd: node,
      tl: visited.contents
    };
  };
  List.iter((function (param) {
          sort_node(param[0]);
        }), graph);
  return visited.contents;
}

if (!Caml_obj.caml_equal(unsafe_topsort(grwork), {
        hd: "wake",
        tl: {
          hd: "shower",
          tl: {
            hd: "dress",
            tl: {
              hd: "eat",
              tl: {
                hd: "washup",
                tl: {
                  hd: "go",
                  tl: /* [] */0
                }
              }
            }
          }
        }
      })) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "topsort_test.ml",
          110,
          2
        ],
        Error: new Error()
      };
}

var String_set = $$Set.Make({
      compare: $$String.compare
    });

var Cycle = /* @__PURE__ */Caml_exceptions.create("Topsort_test.Cycle");

function pathsort(graph) {
  var visited = {
    contents: /* [] */0
  };
  var empty_path_0 = String_set.empty;
  var empty_path = [
    empty_path_0,
    /* [] */0
  ];
  var $plus$great = function (node, param) {
    var stack = param[1];
    var set = param[0];
    if (Curry._2(String_set.mem, node, set)) {
      throw {
            RE_EXN_ID: Cycle,
            _1: {
              hd: node,
              tl: stack
            },
            Error: new Error()
          };
    }
    return [
            Curry._2(String_set.add, node, set),
            {
              hd: node,
              tl: stack
            }
          ];
  };
  var sort_nodes = function (path, nodes) {
    List.iter((function (node) {
            sort_node(path, node);
          }), nodes);
  };
  var sort_node = function (path, node) {
    if (!List.mem(node, visited.contents)) {
      sort_nodes($plus$great(node, path), nexts(node, graph));
      visited.contents = {
        hd: node,
        tl: visited.contents
      };
      return ;
    }
    
  };
  List.iter((function (param) {
          sort_node(empty_path, param[0]);
        }), graph);
  return visited.contents;
}

if (!Caml_obj.caml_equal(pathsort(grwork), {
        hd: "wake",
        tl: {
          hd: "shower",
          tl: {
            hd: "dress",
            tl: {
              hd: "eat",
              tl: {
                hd: "washup",
                tl: {
                  hd: "go",
                  tl: /* [] */0
                }
              }
            }
          }
        }
      })) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "topsort_test.ml",
          150,
          4
        ],
        Error: new Error()
      };
}

try {
  pathsort({
        hd: [
          "go",
          "eat"
        ],
        tl: grwork
      });
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "topsort_test.ml",
          156,
          8
        ],
        Error: new Error()
      };
}
catch (raw_exn){
  var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
  var exit = 0;
  if (exn.RE_EXN_ID === Cycle) {
    var match = exn._1;
    if (match && match.hd === "go") {
      var match$1 = match.tl;
      if (match$1 && match$1.hd === "washup") {
        var match$2 = match$1.tl;
        if (match$2 && match$2.hd === "eat") {
          var match$3 = match$2.tl;
          if (!(match$3 && match$3.hd === "go" && !match$3.tl)) {
            exit = 1;
          }
          
        } else {
          exit = 1;
        }
      } else {
        exit = 1;
      }
    } else {
      exit = 1;
    }
  } else {
    exit = 1;
  }
  if (exit === 1) {
    throw {
          RE_EXN_ID: "Assert_failure",
          _1: [
            "topsort_test.ml",
            159,
            11
          ],
          Error: new Error()
        };
  }
  
}

exports.graph = graph;
exports.nexts = nexts;
exports.dfs1 = dfs1;
exports.dfs2 = dfs2;
exports.dfs3 = dfs3;
exports.grwork = grwork;
exports.unsafe_topsort = unsafe_topsort;
exports.String_set = String_set;
exports.Cycle = Cycle;
exports.pathsort = pathsort;
/*  Not a pure module */
