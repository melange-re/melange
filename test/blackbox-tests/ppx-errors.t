Demonstrate PPX error messages

  $ . ./setup.sh

  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false)
  >  (preprocess (pps melange.ppx)))
  > EOF

  $ cat > x.ml <<EOF
  > module M = struct
  >   type t = { b : string }
  > end
  > let x = [%mel.obj { a = 1; M.b = 2 }]
  > EOF
  $ dune build @melange
  File "x.ml", line 4, characters 27-30:
  4 | let x = [%mel.obj { a = 1; M.b = 2 }]
                                 ^^^
  Error: `%mel.obj' literals only support simple labels
  [1]

  $ cat > x.ml <<EOF
  > let x = [%mel.obj [1;2;3]]
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 8-26:
  1 | let x = [%mel.obj [1;2;3]]
              ^^^^^^^^^^^^^^^^^^
  Error: %mel.obj requires a record literal
  [1]

  $ cat > x.ml <<EOF
  > class type x = object
  >   method height : int [@@mel.get { null = not }]
  > end [@u]
  > EOF
  $ dune build @melange
  File "x.ml", line 2, characters 42-45:
  2 |   method height : int [@@mel.get { null = not }]
                                                ^^^
  Error: expected this expression to be a boolean literal (`true` or `false`)
  [1]

  $ cat > x.ml <<EOF
  > type t
  > external mk : int -> (_ [@mel.as {json| undeclared_var |json}]) ->  t = "mk"
  > EOF
  $ dune build @melange
  File "x.ml", line 2, characters 33-61:
  2 | external mk : int -> (_ [@mel.as {json| undeclared_var |json}]) ->  t = "mk"
                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `[@mel.as {json| ... |json}]' only supports JavaScript literals
  [1]

  $ cat > x.ml <<EOF
  > type t
  > external mk : t = "" ""
  > EOF
  $ dune build @melange
  File "x.ml", line 2, characters 0-23:
  2 | external mk : t = "" ""
      ^^^^^^^^^^^^^^^^^^^^^^^
  Error: Melange requires a single string in `external` payloads
  [1]

  $ cat > x.ml <<EOF
  > type t =
  >   < chdir : string -> unit [@mel.meth] [@mel.get] >
  >   Js.t
  > EOF
  $ dune build @melange
  File "x.ml", line 2, characters 2-51:
  2 |   < chdir : string -> unit [@mel.meth] [@mel.get] >
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `@mel.get' / `@mel.set' cannot be used with `@mel.meth'
  [1]

