Set up a few directories we'll need

  $ export MELANGELIB="$INSIDE_DUNE/lib/melange"
  $ dune build ./libB/.b.objs/melange/b.cmj

  $ ls _build/default/libA/.a.objs/melange
  a.cmi
  a.cmj
  a.cmt
  a__.cmi
  a__.cmj
  a__.cmt
  a__Other.cmi
  a__Other.cmj
  a__Other.cmt

  $ ls _build/default/libB/.b.objs/melange
  b.cmi
  b.cmj
  b.cmt

  $ dune build ./dist/libB/b.js --display=short
          melc dist/libA/a.js
          melc dist/libA/a__.js
          melc dist/libA/a__Other.js
          melc dist/libB/b.js
