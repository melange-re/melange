Test that `-o output` always produces a JS file

  $ source ./setup.sh
  $ cat > x.ml <<EOF
  > let () = Js.log "Hello"
  > EOF

  $ melc $MEL_STDLIB_FLAGS x.ml -o ./x.js
  $ ls
  setup.sh
  x.cmi
  x.cmj
  x.cmt
  x.js
  x.ml

  $ node ./x.js
  Hello
