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
  >  (preprocess (pps melange.ppx -alert -fragile)))
  > EOF

  $ cat > x.ml <<EOF
  > external join : string -> string = "join!me"
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 0-44:
  1 | external join : string -> string = "join!me"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: "join!me" isn't a valid JavaScript identifier
  [1]

  $ cat > x.ml <<EOF
  > external join : string -> string = "" [@@mel.module ""]
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 0-55:
  1 | external join : string -> string = "" [@@mel.module ""]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `@mel.module' name cannot be empty
  [1]

  $ cat > x.ml <<EOF
  > [@@@mel.config { x with y = 1 }]
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 17-18:
  1 | [@@@mel.config { x with y = 1 }]
                       ^
  Error: Unsupported attribute payload. Expected a configuration record literal (`with' is not supported)
  [1]

  $ cat > x.ml <<EOF
  > [@@@mel.config { no_export = Not_bool }]
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 29-37:
  1 | [@@@mel.config { no_export = Not_bool }]
                                   ^^^^^^^^
  Error: Expected a boolean literal (`true' or `false')
  [1]

  $ cat > x.ml <<EOF
  > let x = function
  >   | {j|x|j} -> ()
  > EOF
  $ dune build @melange
  File "x.ml", line 2, characters 4-11:
  2 |   | {j|x|j} -> ()
          ^^^^^^^
  Error: Unicode strings cannot currently be used in pattern matching
  [1]

  $ cat > x.ml <<EOF
  > external cast: 'a -> 'b -> 'c = "%identity"
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 0-43:
  1 | external cast: 'a -> 'b -> 'c = "%identity"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: The `%identity' primitive type must take a single argument ('a -> 'b)
  [1]

  $ cat > x.ml <<EOF
  > [@@@mel.config { flags = [| 1; 2 |] }]
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 28-29:
  1 | [@@@mel.config { flags = [| 1; 2 |] }]
                                  ^
  Error: Flags must be a literal array of strings
  [1]

  $ cat > x.ml <<EOF
  > [@@@mel.config { flags = [ ] }]
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 25-28:
  1 | [@@@mel.config { flags = [ ] }]
                               ^^^
  Error: Flags must be a literal array of strings
  [1]
