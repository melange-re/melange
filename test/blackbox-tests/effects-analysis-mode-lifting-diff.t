Selective CPS lifting differs by analysis mode for higher-order helper calls.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += E : int Effect.t
  > 
  > let[@inline never] run f = f ()
  > let effectful () = Effect.perform E
  > let main () = run effectful
  > EOF

Conservative mode treats the unknown callback call in `run` as effectful, so
`run` is lifted.

  $ MELANGE_EFFECT_ANALYSIS_MODE=conservative melc x.ml -o x.cons.js
  $ rg -F 'function run$cps(' x.cons.js
  function run$cps(f, __k) {

Optimistic mode can miss that higher-order path, so `run` is not lifted.

  $ MELANGE_EFFECT_ANALYSIS_MODE=optimistic melc x.ml -o x.opt.js
  $ rg -F 'function run$cps(' x.opt.js
  [1]
