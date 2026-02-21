Selective CPS propagation across regular functions: if `f` tail-calls an
effectful `g`, `f` is lifted and its tail call is rewritten to `g$cps(..., k)`.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += E : int Effect.t
  > let g x = x + Effect.perform E
  > let f x = g x
  > EOF

  $ MELANGE_EFFECT_CPS_EXPERIMENT=1 MELANGE_EFFECT_CPS_DEBUG=1 melc x.ml -o x.cps.js
  [effect-cps] lifted g -> g$cps
  [effect-cps] tail-call rewrite g -> g$cps in f
  [effect-cps] lifted f -> f$cps

`f` keeps its public arity (1) but internally calls `g$cps` with hidden
continuation plumbing.

  $ rg 'function f\(x\)|return g\$cps\(x, __k\)' x.cps.js
  function f(x) {
    return g$cps(x, __k);
