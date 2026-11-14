Inline integers must report overflow at the literal, including in interfaces.

  $ . ./setup.sh
  $ for literal in 2147483648 -2147483649; do
  >   echo "let answer = $literal [@@mel.inline]" > input.ml
  >   melc -w -107 -alert -unprocessed -ppx melppx -c input.ml
  > done
  File "input.ml", line 1, characters 13-23:
  1 | let answer = 2147483648 [@@mel.inline]
                   ^^^^^^^^^^
  Error: Integer literal is out of range for type int
  File "input.ml", line 1, characters 13-24:
  1 | let answer = -2147483649 [@@mel.inline]
                   ^^^^^^^^^^^
  Error: Integer literal is out of range for type int
  [2]

  $ for literal in 2147483648 -2147483649; do
  >   echo "val answer : int [@@mel.inline $literal]" > input.mli
  >   melc -w -107 -alert -unprocessed -ppx melppx -c input.mli
  > done
  File "input.mli", line 1, characters 31-41:
  1 | val answer : int [@@mel.inline 2147483648]
                                     ^^^^^^^^^^
  Error: Integer literal is out of range for type int
  File "input.mli", line 1, characters 31-42:
  1 | val answer : int [@@mel.inline -2147483649]
                                     ^^^^^^^^^^^
  Error: Integer literal is out of range for type int
  [2]

The same conversion path supports int64 literals.

  $ echo 'let answer = 9223372036854775808L [@@mel.inline]' > input.ml
  $ melc -w -107 -alert -unprocessed -ppx melppx -c input.ml
  File "input.ml", line 1, characters 13-33:
  1 | let answer = 9223372036854775808L [@@mel.inline]
                   ^^^^^^^^^^^^^^^^^^^^
  Error: Integer literal is out of range for type int64
  [2]

  $ echo 'val answer : int64 [@@mel.inline -9223372036854775809L]' > input.mli
  $ melc -w -107 -alert -unprocessed -ppx melppx -c input.mli
  File "input.mli", line 1, characters 33-54:
  1 | val answer : int64 [@@mel.inline -9223372036854775809L]
                                       ^^^^^^^^^^^^^^^^^^^^^
  Error: Integer literal is out of range for type int64
  [2]

Boundary values and hexadecimal bit patterns retain their representations.

  $ cat > bounds.mli <<'EOF'
  > val low : int [@@mel.inline -2147483648]
  > val high : int [@@mel.inline 2147483647]
  > val bits : int [@@mel.inline 0xffffffff]
  > val low64 : int64 [@@mel.inline -9223372036854775808L]
  > val high64 : int64 [@@mel.inline 9223372036854775807L]
  > EOF
  $ cat > bounds.ml <<'EOF'
  > let low = -2147483648 [@@mel.inline]
  > let high = 2147483647 [@@mel.inline]
  > let bits = 0xffffffff [@@mel.inline]
  > let low64 = -9223372036854775808L [@@mel.inline]
  > let high64 = 9223372036854775807L [@@mel.inline]
  > EOF
  $ cat > use.ml <<'EOF'
  > let () = Printf.printf "%d %d %d\n%Ld %Ld\n"
  >   Bounds.low Bounds.high Bounds.bits Bounds.low64 Bounds.high64
  > EOF
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ echo '(melange.emit (target out) (modules bounds use) (libraries melange) (preprocess (pps melange.ppx)))' > dune
  $ dune build @melange
  $ node _build/default/out/use.js
  -2147483648 2147483647 -1
  -9223372036854775808 9223372036854775807
