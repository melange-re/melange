Demonstrate a bug with uncurrying

  $ . ./setup.sh

  $ cat > main.ml <<EOF
  > let foo = ((fun _arr  -> 2) [@bs])
  > let bar () =
  >   let _a = 2 in
  >   let _b = 2 in
  >   (foo [||] [@bs])
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.7)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >  (target melange)
  >  (alias mel)
  >  (modules main)
  >  (module_systems commonjs))
  > EOF

  $ dune build @mel
  File "main.ml", line 5, characters 14-16:
  5 |   (foo [||] [@bs])
                    ^^
  Error (warning 101 [unused-bs-attributes]): Unused attribute: bs
  This means such annotation is not annotated properly. 
  for example, some annotations is only meaningful in externals 
  
  [1]

If one line is removed, then it works (wat)

  $ cat > main.ml <<EOF
  > let foo = ((fun _arr  -> 2) [@bs])
  > let bar () =
  >   let _a = 2 in
  >   (* let _b = 2 in *)
  >   (foo [||] [@bs])
  > EOF

  $ dune build @mel
