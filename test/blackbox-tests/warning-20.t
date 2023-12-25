Melange turns off warning 20 by default for applications
([ignored-extra-argument])

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune << EOF
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false)
  >  (preprocess (pps melange.ppx)))
  > EOF

  $ cat > foo.ml <<EOF
  > let addOne = [%mel.raw {|
  >   function (a) {
  >     return a + 1;
  >   }
  > |}]
  > let x = addOne 2
  > EOF

  $ dune build @melange

