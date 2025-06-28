Set up a few directories we'll need

  $ . ../setup.sh
  $ dune build ./libB/.b.objs/melange/b.cmj

Setting `(wrapped false)` in `(library (name a))` will produce unmangled JS
files

  $ ls _build/default/libA/.a.objs/melange
  a.cmi
  a.cmj
  a.cmt
  a.impl.all-deps
  a.impl.d
  other.cmi
  other.cmj
  other.cmt
  other.impl.all-deps
  other.impl.d

  $ ls _build/default/libB/.b.objs/melange
  b.cmi
  b.cmj
  b.cmt

  $ dune build @melange-dist

The resulting directory produces JS files with the same structure as the source
tree. Because `(wrapped false)` was present, JS file names are not mangled

  $ tree --noreport ./_build/default/dist/libA
  ./_build/default/dist/libA
  |-- a.js
  `-- other.js

  $ tree --noreport ./_build/default/dist/libB
  ./_build/default/dist/libB
  `-- b.js
