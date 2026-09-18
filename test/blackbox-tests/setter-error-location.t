Invalid partial setter applications point to the source expression.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > let f a = ( #= ) a
  > EOF
  $ melc -ppx melppx -alert -unprocessed -c input.ml
  File "input.ml", line 1, characters 10-18:
  1 | let f a = ( #= ) a
                ^^^^^^^^
  Error: invalid #= syntax
  [2]
