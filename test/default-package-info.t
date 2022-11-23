Test that `-o output` always produces a JS file

  $ export MELANGELIB="$INSIDE_DUNE/lib/melange"
  $ cat > x.ml <<EOF
  > let () = Js.log "Hello"
  > EOF

  $ melc x.ml -o ./x.js
  $ ls
  x.cmi
  x.cmj
  x.cmt
  x.js
  x.ml

  $ node ./x.js
  Hello
