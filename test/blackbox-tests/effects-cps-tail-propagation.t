Selective CPS propagation across regular functions: if `f` tail-calls an
effectful `g`, `f` is lifted and its tail call is rewritten to `g$cps(..., k)`.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += E : int Effect.t
  > let g x = x + Effect.perform E
  > let f x = g x
  > EOF

  $ MELANGE_EFFECT_CPS_DEBUG=1 melc x.ml -o x.cps.js
  [effect-cps] prim-arg-perform rewrite in g
  [effect-cps] lifted g -> g$cps
  [effect-cps] tail-call rewrite g -> g$cps in f
  [effect-cps] lifted f -> f$cps

`f` keeps its public arity (1) but internally calls `g$cps` with a hidden
identity continuation helper.

  $ rg 'function f\(x\)|return g\$cps\(x, [a-zA-Z0-9_$]+\);' x.cps.js
  function f(x) {
    return g$cps(x, f$idk);
