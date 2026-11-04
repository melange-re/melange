Ignoring a partial splice does not mutate; applying it must mutate once.
ReScript #6991.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > [@@@warning "-5"]
  > let ignored a i = ignore (Js.Array.spliceInPlace ~start:i ~remove:1 a)
  > let complete a i = ignore (Js.Array.spliceInPlace ~start:i ~remove:1 ~add:[||] a)
  > let delayed a i = Js.Array.spliceInPlace ~start:i ~remove:1 a
  > let with_add a i xs = Js.Array.spliceInPlace ~start:i ~remove:1 ~add:xs a
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js');
  > const a = [1,2,3]; m.ignored(a,1); assert.deepEqual(a, [1,2,3]);
  > m.complete(a,1); assert.deepEqual(a, [1,3]);
  > const b = [1,2,3], f = m.delayed(b,1); assert.deepEqual(b, [1,2,3]);
  > assert.deepEqual(f([]), [2]); assert.deepEqual(b, [1,3]);
  > assert.deepEqual(m.with_add(b,0,[7,8]), [1]); assert.deepEqual(b, [7,8,3]);
  > EOF
