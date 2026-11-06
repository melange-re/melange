  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > let _ = string_of_int (Js.Date.fromFloat 33.)
  > EOF
  $ melc x.ml
  File "x.ml", line 1, characters 22-45:
  1 | let _ = string_of_int (Js.Date.fromFloat 33.)
                            ^^^^^^^^^^^^^^^^^^^^^^^
  Error: This expression has type Js.Date.t
         but an expression was expected of type int
  [2]
