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
  File "foo.ml", line 1, characters 7-11:
  1 | let x: nope = addOne 2
             ^^^^
  Error: Unbound type constructor nope
  [1]

  $ export DUNE_SANDBOX=none
  $ dune build @melange
  File "foo.ml", line 1, characters 7-11:
  1 | let x: nope = addOne 2
             ^^^^
  Error: Unbound type constructor nope
  [1]

Generated arity wrappers retain the source type's location

  $ cat > arity.ml <<EOF
  > module Js = struct
  >   module Fn = struct
  >     type arity1
  >   end
  > end
  > external f : (int -> int) Js.Fn.arity1 = ""
  > EOF

  $ ocamlc -ppx 'melppx -alert -fragile' -c arity.ml
  File "arity.ml", line 6, characters 13-38:
  6 | external f : (int -> int) Js.Fn.arity1 = ""
                   ^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: The type constructor Js.Fn.arity1 expects 0 argument(s),
         but is here applied to 1 argument(s)
  [2]

Generated arity locations satisfy ppxlib's containment checks

  $ cat > arity-valid.ml <<EOF
  > let f : int -> int [@u] = fun [@u] x -> x
  > module Js = struct
  >   module Fn = struct
  >     type 'a arity1
  >   end
  > end
  > external wrapped : (int -> int) Js.Fn.arity1 = "wrapped"
  > EOF
  $ melc -ppx 'melppx -locations-check' -c arity-valid.ml > /dev/null
