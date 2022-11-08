Test showing unused record fields error with bs.deriving abstract

  $ cat > main.ml <<EOF
  > type config =
  >   { leading : bool
  >   ; trailing : bool
  >   }
  > [@@bs.deriving abstract]
  > type t
  > external foo: config -> t = "foo"
  > EOF

  $ melc -nopervasives -w @69 main.ml -o main.cmj
  File "main.ml", lines 2-3, characters 4-3:
  2 | ....leading : bool
  3 |   ;................
  Error (warning 69 [unused-field]): unused record field leading.
  File "main.ml", line 3, characters 4-19:
  3 |   ; trailing : bool
          ^^^^^^^^^^^^^^^
  Error (warning 69 [unused-field]): unused record field trailing.
  [2]

When not using bs.deriving abstract it works fine

  $ cat > main.ml <<EOF
  > type config =
  >   { leading : bool
  >   ; trailing : bool
  >   }
  > type t
  > external foo: config -> t = "foo"
  > EOF

  $ melc -nopervasives -w @69 main.ml -o main.cmj
