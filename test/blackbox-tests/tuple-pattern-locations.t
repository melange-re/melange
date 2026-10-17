Tuple pattern flattening keeps generated binding locations well-formed.

  $ . ./setup.sh

  $ cat > locations.ml <<'EOF'
  > let first, second = 1, 2
  > let sum pair =
  >   let first, second = pair in
  >   first + second
  > let attributed_first, attributed_second = (3, 4) [@@warning "-32"]
  > EOF

  $ ocamlc -ppx 'melppx -locations-check' -c locations.ml
