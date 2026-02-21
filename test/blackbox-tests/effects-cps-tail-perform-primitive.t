Tail-perform rewriting under selective CPS: a tail `Effect.perform` becomes
`caml_perform_tail(..., __k)` in generated JS.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += Tick : int Effect.t
  > let body () =
  >   ignore (Sys.opaque_identity 1);
  >   Effect.perform Tick
  > EOF

Without CPS, the generated code uses plain `caml_perform`.

  $ melc x.ml -o x.default.js
  $ rg "caml_perform\\(" x.default.js
    return Caml_effect.caml_perform({
  $ rg "caml_perform_tail\\(" x.default.js
  [1]

With selective CPS enabled, tail-perform rewriting uses `caml_perform_tail`
and prints a debug trace.

  $ MELANGE_EFFECT_CPS_EXPERIMENT=1 MELANGE_EFFECT_CPS_DEBUG=1 melc x.ml -o x.cps.js
  [effect-cps] tail-perform rewrite in body
  [effect-cps] lifted body -> body$cps
  $ rg "caml_perform_tail\\(" x.cps.js
    return Caml_effect.caml_perform_tail({
