Libraries can provide modules that shadow ones provided by Melange

In this test case:

- The `node` library is a wrapped library (no modules inside are named `Node`)
- This shadows the `Node` module provided by the Melange runtime / stdlib

  $ . ../setup.sh
  $ dune build @melange-dist

  $ ls _build/default/node/.node.objs/melange
  node.cmi
  node.cmj
  node.cmt
  node__Leaf.cmi
  node__Leaf.cmj
  node__Leaf.cmt
  node__Leaf.impl.all-deps
  node__Leaf.impl.d
  node__Other.cmi
  node__Other.cmj
  node__Other.cmt
  node__Other.impl.all-deps
  node__Other.impl.d

Generated JS files are unmangled

  $ tree --noreport _build/default/dist/node
  _build/default/dist/node
  |-- leaf.js
  |-- node.js
  `-- other.js
