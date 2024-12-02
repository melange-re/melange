Repro a bug that surfaced in https://github.com/melange-community/melange-json/pull/32/commits/c669c0790de9a3d80d8403d92fb60f11338362b2.
The `inner` lib represents `melange-json` lib, `outer` represents `melange-json.ppx` and the runtime.
The issue seems to happen due to a combination of two things:
- `outer` depends on `inner` but the main library `lib` only depends on `outer`
- Usage of `(implicit_transitive_deps false)`, using `true` makes the issue go away

  $ . ./setup.sh

  $ mkdir inner outer

  $ cat > inner/inner.ml <<\EOF
  > type error = Json_error of string | Unexpected_variant of string
  > exception DecodeError of error
  > EOF
  $ cat > inner/dune <<EOF
  > (library
  >  (name inner)
  >  (modes melange))
  > EOF

  $ cat > outer/outer.ml <<\EOF
  > type error = Inner.error =
  >   | Json_error of string
  >   | Unexpected_variant of string
  > 
  > exception Of_json_error = Inner.DecodeError
  > EOF

  $ cat > outer/dune <<EOF
  > (library
  >  (name outer)
  >  (libraries inner)
  >  (modules outer)
  >  (wrapped false)
  >  (modes melange))
  > EOF

  $ cat > dune-project <<\EOF
  > (lang dune 3.11)
  > (using melange 0.1)
  > (implicit_transitive_deps false)
  > EOF
  $ cat > dune <<\EOF
  > (library
  >  (name lib)
  >  (modules main)
  >  (wrapped false)
  >  (libraries outer)
  >  (modes melange))
  > (melange.emit
  >  (alias melange)
  >  (target out)
  >  (modules)
  >  (libraries lib))
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
  $ dune build @melange
  File ".lib.objs/melange/_unknown_", line 1, characters 0-0:
  melc: internal error, uncaught exception:
        Not_found
        
  [1]
