An example that uses a module with the same name as an stdlib one

  $ cat > stack.ml <<EOF
  > let f () =
  >   Js.log "foo"
  > EOF
  $ cat > x.ml <<EOF
  > let () = Stack.f ()
  > EOF
  $ cat > dune-project <<EOF
  > (lang dune 3.7)
  > (using melange 0.1)
  > EOF

Building when library is wrapped works

  $ cat > dune <<EOF
  > (library
  >  (name foo)
  >  (modes melange)
  >  (libraries melange)
  >  (modules x stack))
  > (melange.emit
  >  (target melange)
  >  (alias mel)
  >  (modules )
  >  (libraries foo))
  > EOF

  $ dune build @mel

Building when library is unwrapped breaks

  $ cat > dune <<EOF
  > (library
  >  (name foo)
  >  (modes melange)
  >  (libraries melange)
  >  (wrapped false)
  >  (modules x stack))
  > (melange.emit
  >  (target melange)
  >  (alias mel)
  >  (modules )
  >  (libraries foo))
  > EOF
  $ dune build @mel
  File "x.ml", line 1, characters 9-16:
  1 | let () = Stack.f ()
               ^^^^^^^
  Error: Unbound value Stack.f
  [1]
