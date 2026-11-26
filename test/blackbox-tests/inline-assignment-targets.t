Cross-module inlining must rename assignments to local mutable variables.
Both calls should return 14, and the constant calls should return [12, 4].

  $ . ./setup.sh
  $ cat > lib.ml <<'ML'
  > let[@inline always] bump x =
  >   let r = ref x in
  >   incr r;
  >   if x > 3 then r := !r * 2;
  >   !r
  > let[@inline never] control x =
  >   let r = ref x in
  >   incr r;
  >   if x > 3 then r := !r * 2;
  >   !r
  > ML
  $ cat > run.ml <<'ML'
  > let twice x y = Lib.bump x + Lib.bump y
  > let constants = Lib.bump 5, Lib.bump 3
  > let control x y = Lib.control x + Lib.control y
  > ML
  $ melc --mel-cross-module-opt -o lib.js lib.ml
  $ melc --mel-cross-module-opt -I . -o run.js run.ml 2>&1 | sed -nE '/Failure/s/[0-9]+/N/gp'
        Failure("File \"jscomp/core/lam_dce.ml\", line N, characters N-Nr/N not found")
  $ if test -f run.js; then cat run.js; node --check run.js; node -e 'const m = require("./run.js"); console.log(m.twice(3,4), m.control(3,4), m.constants)'; fi
