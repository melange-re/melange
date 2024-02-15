Demonstrate a bug with uncurrying

  $ . ./setup.sh

  $ cat > main.ml <<EOF
  > let foo = ((fun _arr  -> 2) [@u])
  > let bar () =
  >   let _a = 2 in
  >   let _b = 2 in
  >   (foo [||] [@u])
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >  (target melange)
  >  (alias mel)
  >  (modules main)
  >  (preprocess (pps melange.ppx))
  >  (emit_stdlib false)
  >  (module_systems commonjs))
  > EOF

  $ dune build @mel

If one line is removed, then it works (wat)

  $ cat > main.ml <<EOF
  > let foo = ((fun _arr  -> 2) [@u])
  > let bar () =
  >   let _a = 2 in
  >   (* let _b = 2 in *)
  >   (foo [||] [@u])
  > EOF

  $ dune build @mel
