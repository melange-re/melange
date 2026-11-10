output_substring takes an offset and a length (melange-re/melange#2193).

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.20)
  > (using melange 1.0)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out))
  > EOF
  $ cat > input.ml <<'EOF'
  > let () =
  >   List.iter (fun (ofs, len) ->
  >     print_string "[";
  >     output_substring stdout "abcdefgh" ofs len;
  >     print_endline "]")
  >     [0, 3; 2, 3; 4, 2; 2, 6]
  > EOF

  $ ocaml input.ml
  [abc]
  [cde]
  [ef]
  [cdefgh]

Melange must output the same substring as native OCaml.

  $ dune build --disable-promotion @melange
  $ node _build/default/out/input.js
  [abc]
  [cde]
  [ef]
  [cdefgh]
