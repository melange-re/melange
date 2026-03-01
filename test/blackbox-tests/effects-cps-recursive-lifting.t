Selective CPS supports effectful `let rec` functions by generating a recursive
`$cps` companion and preserving the public arity wrapper.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += E : int Effect.t
  > 
  > let rec loop n =
  >   if n = 0 then Effect.perform E
  >   else loop (n - 1)
  > EOF

  $ MELANGE_EFFECT_CPS_DEBUG=1 melc x.ml -o x.cps.js
  [effect-cps] tail-call rewrite loop -> loop$cps in loop
  [effect-cps] tail-perform rewrite in loop
  [effect-cps] lifted recursive loop -> loop$cps

The recursive body is lowered through the CPS tail-perform path.

  $ rg "caml_perform_tail\\(" x.cps.js
        return Caml_effect.caml_perform_tail({
