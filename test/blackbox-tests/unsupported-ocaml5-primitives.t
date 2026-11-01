Demonstrate OCaml 5 primitives that are currently unsupported in Melange

  $ . ./setup.sh

%perform is an Effects primitive in OCaml 5

  $ cat > x.ml <<EOF
  > type 'a t
  > external perform : 'a t -> 'a = "%perform"
  > let () = perform (Obj.magic ())
  > EOF

  $ melc x.ml
  File "x.ml", line 2, characters 0-42:
  2 | external perform : 'a t -> 'a = "%perform"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: Unknown builtin primitive "%perform"
  [2]
