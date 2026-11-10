Digest.substring and Digest.subbytes must hash len bytes starting at ofs (#2192).

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.13)
  > (using melange 0.1)
  > EOF
  $ echo '(melange.emit (target out))' > dune
  $ cat > input.ml <<'EOF'
  > let () =
  >   print_endline (Digest.to_hex (Digest.substring "abcdefgh" 2 3));
  >   print_endline (Digest.to_hex (Digest.subbytes (Bytes.of_string "abcdefgh") 2 3));
  >   print_endline (Digest.to_hex (Digest.substring "abcdefgh" 4 2))
  > EOF

Native OCaml hashes "cde", "cde", and "ef".

  $ ocaml input.ml
  a256e6b336afdc38c564789c399b516c
  a256e6b336afdc38c564789c399b516c
  feb78cc258bdc76867354f01c22dbe43

Melange currently treats len as an end offset, hashing "c", "c", and "".

  $ dune build @melange
  $ node _build/default/out/input.js
  4a8a08f09d37b73795649038408b5f33
  4a8a08f09d37b73795649038408b5f33
  d41d8cd98f00b204e9800998ecf8427e
