
  $ . ./setup.sh

  $ cat > dune-project <<EOF
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target output)
  >  (modules x)
  >  (emit_stdlib false)
  >  (libraries vlib impl_melange))
  > EOF

  $ mkdir impl_melange vlib

  $ cat > vlib/dune <<EOF
  > (library
  >  (name vlib)
  >  (wrapped false)
  >  (modes :standard melange)
  >  (virtual_modules virt))
  > EOF
  $ cat > vlib/virt.mli <<EOF
  > val t : string
  > EOF
  $ cat > vlib/vlib_impl.ml <<EOF
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
  > let () = print_endline Vlib_impl.hello
  > EOF

  $ /Users/anmonteiro/projects/dune/_build/install/default/bin/dune build @melange --display=short
      ocamldep vlib/.vlib.objs/virt.intf.d
      ocamldep impl_melange/.impl_melange.objs/virt.impl.d
      ocamldep vlib/.vlib.objs/vlib_impl.impl.d
          melc vlib/.vlib.objs/melange/virt.{cmi,cmti}
          melc vlib/.vlib.objs/melange/vlib_impl.{cmi,cmj,cmt} (exit 2)
  File "vlib/vlib_impl.ml", line 1:
  Error: Virt not found, it means either the module does not exist or it is a namespace
  [1]

  $ output=_build/default/output/x.js
  $ node "$output"
