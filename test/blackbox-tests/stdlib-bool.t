Test cases for Stdlib.Bool

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target js-out))
  > EOF

  $ cat > x.ml <<EOF
  > let () = Js.log2 (Bool.to_int false) (Bool.to_int true)
  > let () = Js.log2 (Bool.not false) (Bool.not true)
  > let () =
  >   Js.log4
  >     (Bool.compare false true)
  >     (Bool.compare false false)
  >     (Bool.compare true true)
  >     (Bool.compare true false)
  > EOF

  $ dune build @melange

  $ node _build/default/js-out/x.js
  0 1
  true false
  -1 0 0 1

