Test cases for Stdlib hashes

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
  > let x = Js.log2 (Bool.hash false) (Bool.hash true)
  > let y = Js.log2 (Float.hash 1.) (Float.hash (-. 1.))
  > EOF

  $ dune build @melange

  $ node _build/default/js-out/x.js
  -2017569654 -190020389
  -190020389 -1236017131
