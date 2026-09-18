Malformed binary setter applications report a located diagnostic.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > let f a b = ( #= ) a b
  > EOF
  $ melc -ppx melppx -alert -unprocessed -c input.ml
  File "input.ml", line 1, characters 12-22:
  1 | let f a b = ( #= ) a b
                  ^^^^^^^^^^
  Error: invalid #= syntax
  [2]
