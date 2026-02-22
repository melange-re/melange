Selective CPS function-argument `perform` rewrite avoids replay when
the effect appears as an argument to a regular call.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += Tick : int Effect.t
  > 
  > let counter = ref 0
  > 
  > let[@inline never] use x = x + !counter
  > 
  > let body () =
  >   counter := !counter + 1;
  >   use (Effect.perform Tick)
  > 
  > let effc : type a.
  >     a Effect.t -> ((a, int) Effect.Deep.continuation -> int) option =
  >  fun eff ->
  >   match eff with
  >   | Tick -> Some (fun k -> Effect.Deep.continue k 5)
  >   | _ -> None
  > 
  > let result = Effect.Deep.try_with body () { effc }
  > let () = Js.log2 result !counter
  > EOF
  $ mkdir -p node_modules
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange.js" node_modules/melange.js
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange" node_modules/melange

Without selective CPS, continuation replay reruns pre-perform side effects.

  $ melc x.ml -o x.default.js
  $ node x.default.js
  7 2

With selective CPS enabled, this call-argument shape is lowered through
`caml_perform_tail` and the pre-perform increment runs once.

  $ MELANGE_EFFECT_CPS_EXPERIMENT=1 melc x.ml -o x.cps.js
  $ rg "caml_perform_tail\\(" x.cps.js
    return Caml_effect.caml_perform_tail({
  $ node x.cps.js
  6 1
