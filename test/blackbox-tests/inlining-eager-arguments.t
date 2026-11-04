Inlining must evaluate call arguments before the body, including unused arguments
and arguments used by short-circuit operators. Their relative order is unspecified.

  $ . ./setup.sh
  $ echo 'let both a b = a && b' > helper.ml
  $ cat > input.ml <<'EOF'
  > let both a b = a && b
  > let either a b = a || b
  > let flipped a b = b && a
  > let apply f a b = f a b
  > let () =
  >   let calls = ref 0 in
  >   let tick () = incr calls; true in
  >   ignore (both false (tick ()));
  >   ignore (either true (tick ()));
  >   ignore (flipped (tick ()) false);
  >   ignore ((fun a b -> a && b) false (tick ()));
  >   ignore (apply both false (tick ()));
  >   ignore (Helper.both false (tick ()));
  >   print_int !calls; print_newline ();
  >   (try ignore (both false (raise Exit)); print_endline "skipped"
  >    with Exit -> print_endline "raised");
  >   let r = ref 0 in
  >   let bump () = r := 10; 1 in
  >   let add x = bump () + x in
  >   print_int (add !r); print_newline ();
  >   let first x _ = x in
  >   ignore (first (tick ()) (tick ()));
  >   print_int !calls; print_newline ()
  > EOF
  $ ocamlc -o input.exe helper.ml input.ml
  $ ./input.exe
  6
  raised
  1
  8
  $ melc --mel-cross-module-opt helper.ml > helper.js
  $ melc --mel-cross-module-opt -I . input.ml > input.js
  $ node input.js
  0
  skipped
  11
  2
