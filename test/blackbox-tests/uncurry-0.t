
  $ . ./setup.sh

Test some error cases

  $ cat > x.ml <<EOF
  > external valToFn : 'a -> (int -> 'a[@u0]) = "foo"
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 1, characters 26-29:
  1 | external valToFn : 'a -> (int -> 'a[@u0]) = "foo"
                                ^^^
  Error: `[@u0]' can only be used with the `unit' type
  [2]

  $ cat > x.ml <<EOF
  > external valToFn : 'a -> (unit -> int -> 'a[@u0]) = "foo"
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 1, characters 34-43:
  1 | external valToFn : 'a -> (unit -> int -> 'a[@u0]) = "foo"
                                        ^^^^^^^^^
  Error: `[@u0]' cannot be used with multiple arguments
  [2]
