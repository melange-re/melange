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
  >   ignore ((fun a b -> not (a && b)) false (tick ()));
  >   ignore ((fun a b -> ignore (a && b)) false (tick ()));
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
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ echo '(melange.emit (target out) (libraries melange) (compile_flags :standard --mel-cross-module-opt))' > dune
  $ dune build @melange
  $ ocamlc -o input.exe helper.ml input.ml
  $ ./input.exe
  8
  raised
  1
  10
  $ node _build/default/out/input.js
  8
  raised
  1
  10
