Tuple pipelines evaluate their left-hand side outside local opens and only once.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > module Functions = struct
  >   let value = 99
  >   let make () = value
  >   let first value = value
  >   let second value = value
  > end
  > let value = 1
  > let evaluations = ref 0
  > let make () =
  >   incr evaluations;
  >   value
  > let simple = value |. Functions.(first, second)
  > let complex = make () |. Functions.(first, second)
  > let evaluation_count = !evaluations
  > EOF

  $ melc -ppx melppx input.ml -o input.js
  $ node <<'EOF'
  > const { simple, complex, evaluation_count } = require("./input.js");
  > console.log(JSON.stringify({ simple, complex, evaluation_count }));
  > EOF
  {"simple":[1,1],"complex":[1,1],"evaluation_count":1}
