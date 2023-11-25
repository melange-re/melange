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

  $ cat > x.ml <<EOF
  > let { M.x } = (module Y)
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 6-9:
  1 | let { M.x } = (module Y)
            ^^^
  Error: Pattern matching on modules requires simple labels
  [1]

  $ cat > x.ml <<EOF
  > let () = [%mel.debugger payload]
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 9-32:
  1 | let () = [%mel.debugger payload]
               ^^^^^^^^^^^^^^^^^^^^^^^
  Error: `%mel.debugger' doesn't take payload
  [1]

  $ cat > x.ml <<EOF
  > let () = [%mel.re 42]
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 9-21:
  1 | let () = [%mel.re 42]
               ^^^^^^^^^^^^
  Error: `%mel.re' can only be applied to a string
  [1]

  $ cat > x.ml <<EOF
  > let () = [%mel.re "just a string"]
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 18-33:
  1 | let () = [%mel.re "just a string"]
                        ^^^^^^^^^^^^^^^
  Error: `%mel.re' expects a valid JavaScript regular expression literal (`/regex/opt-flags')
  [1]

  $ cat > x.ml <<EOF
  > let x = function [@mel.open]
  > | Not_found -> 0
  > | Invalid_argument _ -> 1
  > | ident -> 2
  > EOF
  $ dune build @melange
  File "x.ml", line 4, characters 2-7:
  4 | | ident -> 2
        ^^^^^
  Error: Unsupported pattern. `[@mel.open]' requires patterns to be (exception) constructors
  [1]

  $ cat > x.ml <<EOF
  > let x =
  >   (object
  >      method y = 3
  >   end [@u])
  > EOF
  $ dune build @melange
  File "x.ml", line 3, characters 5-17:
  3 |      method y = 3
           ^^^^^^^^^^^^
  Error: Unsupported JS Object syntax. Methods must take at least one argument
  [1]

  $ cat > x.ml <<EOF
  > class type x = object
  >   method height : int [@@mel.get "str"]
  > end[@u]
  > EOF
  $ dune build @melange
  File "x.ml", line 2, characters 25-32:
  2 |   method height : int [@@mel.get "str"]
                               ^^^^^^^
  Error: Unsupported attribute payload. Expected a configuration record literal
  [1]

  $ cat > x.ml <<EOF
  > class type x = object
  >   method height : int [@@mel.get { x with null = true }]
  > end[@u]
  > EOF
  $ dune build @melange
  File "x.ml", line 2, characters 25-32:
  2 |   method height : int [@@mel.get { x with null = true }]
                               ^^^^^^^
  Error: Unsupported attribute payload. Expected a configuration record literal
         (`with' not supported)
  [1]


  $ cat > x.ml <<EOF
  > class type x = object
  >   method height : int [@@mel.get { M.null = true }]
  > end[@u]
  > EOF
  $ dune build @melange
  File "x.ml", line 2, characters 25-32:
  2 |   method height : int [@@mel.get { M.null = true }]
                               ^^^^^^^
  Error: Unsupported attribute payload. Expected a configuration record literal
         (qualified labels aren't supported)
  [1]

  $ cat > x.ml <<EOF
  > type t
  > external x : t = "x" [@@mel.module (1,"2")]
  > EOF
  $ dune build @melange
  File "x.ml", line 2, characters 36-37:
  2 | external x : t = "x" [@@mel.module (1,"2")]
                                          ^
  Error: Expected a tuple of string literals
  [1]

  $ cat > x.ml <<EOF
  > type t
  > external x : t = "x" [@@mel.module 1]
  > EOF
  $ dune build @melange
  File "x.ml", line 2, characters 24-34:
  2 | external x : t = "x" [@@mel.module 1]
                              ^^^^^^^^^^
  Error: Expected a string or tuple of strings
  [1]

  $ cat > x.ml <<EOF
  > type t
  > external x : t = "x" [@@mel.module ("1","2","3")]
  > EOF
  $ dune build @melange
  File "x.ml", line 2, characters 24-34:
  2 | external x : t = "x" [@@mel.module ("1","2","3")]
                              ^^^^^^^^^^
  Error: `[@mel.module ..]' expects, at most, a tuple of two strings (module name, variable name)
  [1]

  $ cat > x.ml <<EOF
  > type t
  > external x : t = "x" [@@mel.scope]
  > EOF
  $ dune build @melange
  File "x.ml", line 2, characters 24-33:
  2 | external x : t = "x" [@@mel.scope]
                              ^^^^^^^^^
  Error: `[@mel.scope ..]' expects a tuple of strings in its payload
  [1]

