Function cases in JS object methods report a located diagnostic.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > let object_ = object [@u]
  >   method identity = function
  >   | value -> value
  > end
  > EOF
  $ melc -ppx melppx -alert -unprocessed -c input.ml
  File "input.ml", lines 2-3, characters 20-18:
  2 | ....................function
  3 |   | value -> value
  Error: Function cases are not supported in JS object methods
  [2]
