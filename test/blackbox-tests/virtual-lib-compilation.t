
  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target output)
  >  (alias mel)
  >  (modules x)
  >  (emit_stdlib false)
  >  (libraries vlib impl_melange))
  > EOF

  $ mkdir impl_melange vlib
  $ cat > vlib/dune <<EOF
  > (library
  >  (name vlib)
  >  (wrapped false)
  >  (modes melange)
  >  (virtual_modules virt))
  > EOF

  $ cat > vlib/virt.mli <<EOF
  > val t : string
  > EOF
  $ cat > vlib/vlib.ml <<EOF
  > let hello = "Hello from " ^ Virt.t
  > EOF

  $ cat > impl_melange/dune <<EOF
  > (library
  >  (name impl_melange)
  >  (modes melange)
  >  (implements vlib))
  > EOF

  $ cat > impl_melange/virt.ml << EOF
  > let t = "melange"
  > EOF

  $ cat > x.ml <<EOF
  > let () = print_endline Vlib.hello
  > EOF

  $ dune build @mel

  $ output=_build/default/output/x.js
  $ node "$output"
  Hello from melange
