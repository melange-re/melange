Repro a bug that surfaced in https://github.com/melange-community/melange-json/pull/32/commits/c669c0790de9a3d80d8403d92fb60f11338362b2.
The `inner` lib represents `melange-json` lib, `outer` represents `melange-json.ppx` and the runtime.
The issue seems to happen due to a combination of two things:
- `outer` depends on `inner` but this is not reflected on the `ppx_runtime_libraries` 
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
  > exception Of_string_error of string
  > 
  > type error = Inner.error =
  >   | Json_error of string
  >   | Unexpected_variant of string
  > 
  > exception Of_json_error = Inner.DecodeError
  > EOF

  $ cat > outer/dummy_ppx.ml <<EOF
  > let () =
  >   Ppxlib.Driver.register_transformation
  >     "dummy"
  >     ~impl:(fun s -> s)
  > EOF

  $ cat > outer/dune <<EOF
  > (library
  >  (name outer)
  >  (libraries inner)
  >  (modules outer)
  >  (wrapped false)
  >  (modes melange))
  > (library
  >  (name dummy_ppx)
  >  (kind ppx_rewriter)
  >  (modules dummy_ppx)
  >  (libraries ppxlib)
  >  (ppx_runtime_libraries outer))
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
  >  (flags :standard -w -37-69)
  >  (wrapped false)
  >  (preprocess (pps dummy_ppx))
  >  (modes melange))
  > (melange.emit
  >  (alias melange)
  >  (target out)
  >  (modules)
  >  (libraries lib)
  >  (module_systems commonjs))
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
