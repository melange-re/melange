Set up a few directories we'll need

  $ export MELANGELIB="$INSIDE_DUNE/lib/melange"
  $ dune build ./libB/.b.objs/melange/b.cmj

Setting `(wrapped false)` in `(library (name a))` will produce unmangled JS
files

  $ ls _build/default/libA/.a.objs/melange
  a.cmi
  a.cmj
  a.cmt
  other.cmi
  other.cmj
  other.cmt

  $ ls _build/default/libB/.b.objs/melange
  b.cmi
  b.cmj
  b.cmt

  $ dune build @melange-dist --display=short
          melc .dist.mobjs/melange/melange.{cmi,cmj,cmt}
          melc dist/libA/a.js
          melc dist/libA/other.js
          melc dist/libB/b.js
          melc dist/.dist.mobjs/melange.js

The resulting directory produces JS files with the same structure as the source
tree. Because `(wrapped false)` was present, JS file names are not mangled

  $ tree --noreport ./_build/default/dist
  ./_build/default/dist
  |-- libA
  |   |-- a.js
  |   `-- other.js
  `-- libB
      `-- b.js
