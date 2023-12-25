Set up a few directories we'll need

  $ . ./setup.sh
  $ cat > b.re << EOF
  > let t = "foo";
  > EOF

  $ cat > b.rei << EOF
  > let t : string;
  > EOF

Preprocess files

  $ refmt --print=binary b.rei > b.rei.mli
  $ refmt --print=binary b.re > b.re.ml

Compile cmi

  $ melc -intf b.rei.mli -o b.cmi

Change permissions to avoid writes

  $ chmod -w b.cmi

Melc should not write cmi file

  $ melc -bs-stop-after-cmj -intf-suffix .ml -I . -impl b.re.ml -o b.cmj

