
  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > exception Error of string
  > module Error = struct
  >   let x = 1
  > end
  > EOF

  $ melc -ppx melppx ./x.ml
  File "./x.ml", lines 2-4, characters 0-3:
  2 | module Error = struct
  3 |   let x = 1
  4 | end
  Error: JavaScript export name "$$Error" is shared by extension constructor `Error` and module `Error`
  [2]

