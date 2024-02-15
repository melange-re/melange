Demonstrate OCaml 5 primitives that are currently unsupported in Melange

  $ . ./setup.sh

%perform is an Effects primitive in OCaml 5

  $ cat > x.ml <<EOF
  > type 'a t
  > external perform : 'a t -> 'a = "%perform"
  > let () = perform (Obj.magic ())
  > EOF

  $ melc x.ml
  File "x.ml", line 3, characters 9-31:
  3 | let () = perform (Obj.magic ())
               ^^^^^^^^^^^^^^^^^^^^^^
  Error: OCaml 5 multicore primitives (Effect, Condition, Semaphore) are not currently supported in Melange
  [2]
