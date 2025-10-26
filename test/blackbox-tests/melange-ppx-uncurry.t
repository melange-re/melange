Demonstrate a bug with uncurrying

  $ . ./setup.sh

  $ cat > main.ml <<EOF
  > let foo = ((fun _arr  -> 2) [@u])
  > let bar () =
  >   let _a = 2 in
  >   let _b = 2 in
  >   (foo [||] [@u])
  > EOF

  $ melc -ppx melppx main.ml > main.js

If one line is removed, then it works (wat)

  $ cat > main.ml <<EOF
  > let foo = ((fun _arr  -> 2) [@u])
  > let bar () =
  >   let _a = 2 in
  >   (* let _b = 2 in *)
  >   (foo [||] [@u])
  > EOF

  $ melc -ppx melppx main.ml > main.js
