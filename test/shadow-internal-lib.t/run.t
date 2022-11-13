Libraries can provide modules that shadow ones provided by Melange

In this test case:

- The `node` library is a wrapped library (no modules inside are named `Node`)
- This shadows the `Node` module provided by the Melange runtime / stdlib

  $ export MELANGELIB="$INSIDE_DUNE/lib/melange"
  $ dune build @melange-dist --display=short
      ocamldep node/.node.objs/leaf.ml.d
          melc node/.node.objs/melange/node.{cmi,cmj,cmt}
      ocamldep node/.node.objs/other.ml.d
          melc dist/node/node.js
          melc node/.node.objs/melange/node__Other.{cmi,cmj,cmt}
          melc dist/node/other.js
          melc node/.node.objs/melange/node__Leaf.{cmi,cmj,cmt}
          melc dist/node/leaf.js
          melc .dist.mobjs/melange/melange__Entry_module.{cmi,cmj,cmt}
          melc dist/entry_module.js

  $ ls _build/default/node/.node.objs/melange
  node.cmi
  node.cmj
  node.cmt
  node__Leaf.cmi
  node__Leaf.cmj
  node__Leaf.cmt
  node__Other.cmi
  node__Other.cmj
  node__Other.cmt

Generated JS files are unmangled

  $ tree _build/default/dist
  _build/default/dist
  |-- entry_module.js
  `-- node
      |-- leaf.js
      |-- node.js
      `-- other.js
  
  1 directory, 4 files
