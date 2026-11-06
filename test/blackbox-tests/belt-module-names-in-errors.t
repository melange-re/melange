  $ . ./setup.sh
  $ export MELANGELIB="$MELANGELIB:$INSIDE_DUNE/../install/default/lib/melange/belt/melange"

  $ cat > x.ml <<EOF
  > let _ : int = Belt.MutableStack.make ()
  > EOF

  $ melc x.ml
  File "x.ml", line 1, characters 14-39:
  1 | let _ : int = Belt.MutableStack.make ()
                    ^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: This expression has type 'a Belt.MutableStack.t
         but an expression was expected of type int
  [2]

  $ melc -short-paths -no-alias-deps x.ml
  File "x.ml", line 1, characters 14-39:
  1 | let _ : int = Belt.MutableStack.make ()
                    ^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: This expression has type 'a Belt.MutableStack.t
         but an expression was expected of type int
  [2]
