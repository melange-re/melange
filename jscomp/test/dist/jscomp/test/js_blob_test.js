// Generated by Melange
'use strict';

const Mt = require("./mt.js");

function make_with_options(param) {
  const blob = new Blob(["hello"].values(), {
      type: "application/json"
    });
  return {
    TAG: /* Eq */ 0,
    _0: blob.type,
    _1: "application/json"
  };
}

function decodeUint8Array(b) {
  const decoder = new TextDecoder("utf-8");
  return decoder.decode(b);
}

function blob_bytes(param) {
  const file = new File(["hello"].values(), "foo.txt", undefined);
  return file.bytes().then(function (b) {
    return Promise.resolve({
      TAG: /* Eq */ 0,
      _0: decodeUint8Array(b),
      _1: "hello"
    });
  });
}

Mt.from_pair_suites("Js_blob_test", {
  hd: [
    "make with options",
    make_with_options
  ],
  tl: /* [] */ 0
});

Mt.from_promise_suites("Js_blob_test", {
  hd: [
    "blob bytes",
    blob_bytes(undefined)
  ],
  tl: /* [] */ 0
});

module.exports = {
  make_with_options,
  blob_bytes,
}
/*  Not a pure module */
