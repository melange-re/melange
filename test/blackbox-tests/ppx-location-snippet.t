Test that the location snippet appears in a ppx-processed compilation error

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune << EOF
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false)
  >  (preprocess (pps melange.ppx)))
  > EOF

  $ cat > foo.ml <<EOF
  > let x: nope = addOne 2
  > EOF

  $ export DUNE_SANDBOX=symlink
  $ dune build @melange
  File "dune", lines 1-4, characters 0-81:
  1 | (melange.emit
  2 |  (target out)
  3 |  (emit_stdlib false)
  4 |  (preprocess (pps melange.ppx)))
  melc: internal error, uncaught exception:
        Unix.Unix_error(Unix.ENOENT, "open", "foo.ml")
        
  [1]

  $ export DUNE_SANDBOX=none
  $ dune build @melange
  File "foo.ml", line 1, characters 7-11:
  1 | let x: nope = addOne 2
             ^^^^
  Error: Unbound type constructor nope
  [1]
