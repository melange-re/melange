Test that `-o output` always produces a JS file

  $ cat > x.ml <<EOF
  > let () = Js.log "Hello"
  > EOF

  $ melc --where
  $ melc x.ml -o ./x.js
  $ ls
  x.cmi
  x.cmj
  x.cmt
  x.js
  x.ml

  $ node ./x.js
  Hello
