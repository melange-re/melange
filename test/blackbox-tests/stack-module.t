Shadow Stdlib modules

  $ . ./setup.sh
  $ cat > stack.ml <<EOF
  > let f () =
  >   Js.log "foo"
  > EOF
  $ cat > x.ml <<EOF
  > let () = Stack.f ()
  > EOF
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

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
  >  (emit_stdlib false)
  >  (modules)
  >  (libraries foo))
  > EOF
  $ dune build @mel
