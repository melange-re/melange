Libraries can provide modules that shadow ones provided by Melange

In this case, we create a library that shadows the `Node` module.

  $ export MELANGELIB="$INSIDE_DUNE/lib/melange"
  $ dune build @melange-dist --display=short
      ocamldep node/.node.objs/node.impl.d
          melc node/.node.objs/melange/node__.{cmi,cmj,cmt}
      ocamldep node/.node.objs/node__Other.impl.d
          melc dist/node/node__.js
          melc node/.node.objs/melange/node__Other.{cmi,cmj,cmt}
          melc dist/node/other.js
          melc node/.node.objs/melange/node.{cmi,cmj,cmt}
          melc .dist.mobjs/melange/melange__Entry_module.{cmi,cmj,cmt}
          melc dist/node/node.js
          melc dist/entry_module.js

  $ ls _build/default/node/.node.objs/melange
  node.cmi
  node.cmj
  node.cmt
  node__.cmi
  node__.cmj
  node__.cmt
  node__Other.cmi
  node__Other.cmj
  node__Other.cmt

Generated JS files are unmangled

  $ tree --noreport _build/default/dist
  _build/default/dist
  |-- entry_module.js
  `-- node
      |-- node.js
      |-- node__.js
      `-- other.js

  $ node _build/default/dist/entry_module.js
  hello from shadowed Node module
