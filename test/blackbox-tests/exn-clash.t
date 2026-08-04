
  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > exception Error of string
  > module Error = struct 
  >   let x = 1
  > end
  > EOF

  $ melc -ppx melppx ./x.ml
  File "./x.ml", line 1:
  Error: Error are exported as twice
  [2]

