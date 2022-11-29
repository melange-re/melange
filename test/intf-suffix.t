Set up a few directories we'll need

  $ cat > b.ml << EOF
  > let t = "foo"
  > EOF

  $ cat > b.mli << EOF
  > val t : string
  > EOF

Compile cmi

  $ melc -intf b.mli -o b.cmi

Change permissions to avoid writes

  $ chmod -w b.cmi

Melc should not write cmi file

  $ melc -bs-stop-after-cmj -intf-suffix .ml -I . -impl b.ml -o b.cmj

