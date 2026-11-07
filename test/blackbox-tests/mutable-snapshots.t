Immutable values must retain the mutable state observed at construction.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > type point = { x : int; label : string }
  > type pair = Pair of int * string
  > let tuple () = let r = ref 1 in let p = (!r, "x") in r := 2; fst p
  > let record () = let r = ref 1 in let p = {x = !r; label = "x"} in r := 2; p.x
  > let variant () = let r = ref 1 in let p = Pair (!r, "x") in r := 2; let Pair (n, _) = p in n
  > let closures () =
  >   let i = ref 0 in
  >   let out = Array.make 3 (fun () -> -1) in
  >   while !i < 3 do
  >     let p = (!i, "x") in
  >     out.(!i) <- (fun () -> fst p);
  >     incr i
  >   done;
  >   Array.iter (fun f -> Printf.printf "%d " (f ())) out;
  >   print_newline ()
  > let tail () = let r = ref 0 in let bump before = incr r; (before, !r) in bump !r
  > let () = Printf.printf "%d %d %d\n" (tuple ()) (record ()) (variant ()); closures (); let a,b=tail() in Printf.printf "%d %d\n" a b
  > EOF
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ echo '(melange.emit (target out) (libraries melange))' > dune
  $ dune build @melange
  $ ocamlc -o input.exe input.ml
  $ ./input.exe
  1 1 1
  0 1 2 
  0 1
  $ node _build/default/out/input.js
  2 2 2
  3 3 3 
  0 1
