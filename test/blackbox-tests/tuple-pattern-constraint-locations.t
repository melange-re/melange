Constrained tuple bindings are not flattened into bindings that each inherit
the whole constraint.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > module Values = struct
  >   let first = 1
  >   let second = 2
  > end
  > let (first, second) : int * int = Values.(first, second)
  > let pair_sum = first + second
  > EOF

  $ melc -ppx 'melppx -locations-check' input.ml -o input.js
  $ node <<'EOF'
  > const { pair_sum } = require("./input.js");
  > console.log(pair_sum);
  > EOF
  3
