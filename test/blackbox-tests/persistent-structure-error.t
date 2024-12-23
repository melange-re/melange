Repro a bug that surfaced in https://github.com/melange-community/melange-json/pull/32/commits/c669c0790de9a3d80d8403d92fb60f11338362b2.
The `inner` lib represents `melange-json` lib, `outer` represents `melange-json.ppx` and the runtime.
The issue seems to happen due to a combination of two things:
- `outer` type definition depends on `inner` implementation
- but the main file `main` only includes `-I outer`. adding `-I inner` fixes the problem

  $ . ./setup.sh

  $ mkdir inner outer

  $ cat > inner/inner.ml <<\EOF
  > type error = A
  > EOF

  $ cat > outer/outer.ml <<\EOF
  > type error = Inner.error = | A
  > exception Exn of Inner.error
  > EOF

  $ cat > main.ml <<\EOF
  > let f x =
  >   match x with
  >   | e -> e
  >   | exception Outer.Exn Outer.A -> ()
  > EOF
  $ melc --bs-package-output inner -o inner/inner.cmj -c inner/inner.ml
  $ melc -I inner --bs-package-output outer -o outer/outer.cmj -c outer/outer.ml --bs-stop-after-cmj
  $ melc -I outer --bs-package-output . -o main.cmj -c main.ml --bs-stop-after-cmj
