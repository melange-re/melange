Demonstrate PPX error messages

  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > external join : string -> string = "join!me"
  > EOF
  $ melc -ppx 'melppx -alert -fragile' x.ml
  File "x.ml", line 1, characters 0-44:
  1 | external join : string -> string = "join!me"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: "join!me" isn't a valid JavaScript identifier
  [2]

  $ cat > x.ml <<EOF
  > external join : string -> string = "" [@@mel.module ""]
  > EOF
  $ melc -ppx 'melppx -alert -fragile' -alert -unprocessed x.ml
  File "x.ml", line 1, characters 0-55:
  1 | external join : string -> string = "" [@@mel.module ""]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `@mel.module' name cannot be empty
  [2]

  $ cat > x.ml <<EOF
  > [@@@mel.config { x with y = 1 }]
  > EOF
  $ melc -ppx 'melppx -alert -fragile' x.ml
  File "x.ml", line 1, characters 17-18:
  1 | [@@@mel.config { x with y = 1 }]
                       ^
  Error: Unsupported attribute payload. Expected a configuration record literal (`with' is not supported)
  [2]

  $ cat > x.ml <<EOF
  > [@@@mel.config { no_export = Not_bool }]
  > EOF
  $ melc -ppx 'melppx -alert -fragile' x.ml
  File "x.ml", line 1, characters 29-37:
  1 | [@@@mel.config { no_export = Not_bool }]
                                   ^^^^^^^^
  Error: Expected a boolean literal (`true' or `false')
  [2]

  $ cat > x.ml <<EOF
  > let x = function
  >   | {j|x|j} -> ()
  > EOF
  $ melc -ppx 'melppx -alert -fragile' x.ml
  File "x.ml", line 2, characters 4-11:
  2 |   | {j|x|j} -> ()
          ^^^^^^^
  Error: Unicode strings cannot currently be used in pattern matching
  [2]

  $ cat > x.ml <<EOF
  > let x = 42n
  > EOF
  $ melc -ppx 'melppx -alert -fragile' x.ml
  File "x.ml", line 1, characters 8-11:
  1 | let x = 42n
              ^^^
  Error: `nativeint' is not currently supported in Melange. The `n' suffix cannot be used.
  [2]

  $ cat > x.ml <<EOF
  > external cast: 'a -> 'b -> 'c = "%identity"
  > EOF
  $ melc -ppx 'melppx -alert -fragile' x.ml
  File "x.ml", line 1, characters 0-43:
  1 | external cast: 'a -> 'b -> 'c = "%identity"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: The `%identity' primitive type must take a single argument ('a -> 'b)
  [2]

  $ cat > x.ml <<EOF
  > [@@@mel.config { flags = [| 1; 2 |] }]
  > EOF
  $ melc -ppx 'melppx -alert -fragile' x.ml
  File "x.ml", line 1, characters 28-29:
  1 | [@@@mel.config { flags = [| 1; 2 |] }]
                                  ^
  Error: Flags must be a literal array of strings
  [2]

  $ cat > x.ml <<EOF
  > [@@@mel.config { flags = [ ] }]
  > EOF
  $ melc -ppx 'melppx -alert -fragile' x.ml
  File "x.ml", line 1, characters 25-28:
  1 | [@@@mel.config { flags = [ ] }]
                               ^^^
  Error: Flags must be a literal array of strings
  [2]
