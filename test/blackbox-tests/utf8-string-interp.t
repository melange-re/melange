Test edge cases on unicode string interpolation

  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > let x = {j| Hello, \$()|j}
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 1, characters 8-25:
  1 | let x = {j| Hello, $()|j}
              ^^^^^^^^^^^^^^^^^
  Warning 108 [melange-uninterpreted-delimiters]: Uninterpreted delimiters j
  
  File "x.ml", line 1, characters 19-22:
  1 | let x = {j| Hello, $()|j}
                         ^^^
  Error: `' is not a valid syntax of interpolated identifer
  [2]

  $ cat > x.ml <<EOF
  > let x = {j| Hello, \$(   )|j}
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 1, characters 8-28:
  1 | let x = {j| Hello, $(   )|j}
              ^^^^^^^^^^^^^^^^^^^^
  Warning 108 [melange-uninterpreted-delimiters]: Uninterpreted delimiters j
  
  File "x.ml", line 1, characters 19-25:
  1 | let x = {j| Hello, $(   )|j}
                         ^^^^^^
  Error: `   ' is not a valid syntax of interpolated identifer
  [2]

`{j| .. |j}` interpolation is strict about string arguments

  $ cat > x.ml <<EOF
  > let x =
  >   let y = 3 in
  >   {j| Hello, \$(y)|j}
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 3, characters 15-16:
  3 |   {j| Hello, $(y)|j}
                     ^
  Error: This expression has type int but an expression was expected of type
           string
  [2]
