Test to showcase fatal error when parsing a `raw` attribute that includes a function callback

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target output)
  >  (alias mel)
  >  (emit_stdlib false)
  >  (preprocess (pps melange.ppx)))
  > EOF

Simple %raw expressions work

  $ cat > main.ml <<EOF
  > let unsafeDeleteKey = [%raw "2"]
  > EOF
  $ dune build @mel

Adding a callback breaks

  $ cat > main.ml <<EOF
  > let unsafeDeleteKey = [%raw fun _foo -> "2"]
  > EOF
  $ dune build @mel
  File "main.ml", line 1, characters 22-44:
  1 | let unsafeDeleteKey = [%raw fun _foo -> "2"]
                            ^^^^^^^^^^^^^^^^^^^^^^
  Error: `%mel.raw' can only be applied to a string
  [1]
