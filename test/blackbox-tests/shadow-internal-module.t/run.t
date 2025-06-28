Libraries can provide modules that shadow ones provided by Melange

In this case, we create a library that shadows the `Node` module.

  $ . ../setup.sh
  $ dune build @melange-dist

  $ ls _build/default/node/.node.objs/melange
  node.cmi
  node.cmj
  node.cmt
  node.impl.all-deps
  node.impl.d
  node__.cmi
  node__.cmj
  node__.cmt
  node__Other.cmi
  node__Other.cmj
  node__Other.cmt
  node__Other.impl.all-deps
  node__Other.impl.d

Generated JS files are unmangled

  $ tree --noreport _build/default/dist/node
  _build/default/dist/node
  |-- node.js
  |-- node__.js
  `-- other.js

  $ node _build/default/dist/entry_module.js
  hello from shadowed Node module
