Show optimistic effect analysis is smaller/faster but can miss higher-order
effect paths.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += E : int Effect.t
  > 
  > let run f = f ()
  > let effectful () = Effect.perform E
  > let main () = run effectful
  > EOF

Conservative mode treats unknown calls as effectful, so both `run` and `main`
are classified as effectful.

  $ MELANGE_EFFECT_ANALYSIS_MODE=conservative MELANGE_EFFECT_ANALYSIS_DEBUG=run,main,effectful melc x.ml -o x.js
  [effect-analysis] mode=conservative run=effectful
  [effect-analysis] mode=conservative main=effectful
  [effect-analysis] mode=conservative effectful=effectful

Optimistic mode is smaller (fewer bindings considered effectful), but it misses
this higher-order path: `run` is marked pure even though it may call an
effectful callback.

  $ MELANGE_EFFECT_ANALYSIS_MODE=optimistic MELANGE_EFFECT_ANALYSIS_DEBUG=run,main,effectful melc x.ml -o x.js
  [effect-analysis] mode=optimistic run=pure
  [effect-analysis] mode=optimistic main=effectful
  [effect-analysis] mode=optimistic effectful=effectful
