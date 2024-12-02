Repro a bug that surfaced in https://github.com/melange-community/melange-json/pull/32/commits/c669c0790de9a3d80d8403d92fb60f11338362b2.
The `inner` lib represents `melange-json` lib, `outer` represents `melange-json.ppx` and the runtime.
The issue seems to happen due to a combination of two things:
- `outer` type definition depends on `inner` implementation
- but the main file `main` only includes `-I outer`. adding `-I inner` fixes the problem

  $ . ./setup.sh

  $ mkdir inner outer

  $ cat > inner/inner.ml <<\EOF
  > type error = Json_error of string | Unexpected_variant of string
  > exception DecodeError of error
  > EOF

  $ cat > outer/outer.ml <<\EOF
  > type error = Inner.error =
  >   | Json_error of string
  >   | Unexpected_variant of string
  > 
  > exception Of_json_error = Inner.DecodeError
  > EOF

  $ cat > main.ml <<\EOF
  > let u_of_json =
  >   (fun x ->
  >     match x with
  >     | e -> e
  >     | exception Outer.Of_json_error
  >         (Outer.Unexpected_variant _) ->
  >          raise
  >            (Outer.Of_json_error
  >               (Outer.Unexpected_variant
  >                  "unexpected variant")))
  > EOF
  $ melc -o inner/inner.cmj -c inner/inner.ml
  $ melc -I inner -o outer/outer.cmj -c outer/outer.ml
  $ melc -I outer -o main.cmj -c main.ml
  melc: internal error, uncaught exception:
        Not_found
        
  [125]
