Export otherwise invalid OCaml identifiers to JavaScript

  $ cat > x.ml <<EOF
  > let [@mel.as POST] post= 1
  > let [@mel.as "GET"] get = 2
  > let [@mel.as "put"] other = 2
  > EOF

  $ melc -ppx melppx x.ml
