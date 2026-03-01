Regression test: this shape used to fall back to replay-style `caml_perform`,
which could duplicate side effects before an effectful callback.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += E : unit Effect.t
  > 
  > let counter = ref 0
  > 
  > let[@inline never] run f =
  >   counter := !counter + 1;
  >   f ()
  > 
  > let effectful () = Effect.perform E
  > 
  > let main () =
  >   run effectful;
  >   !counter
  > 
  > let effc : type a.
  >     a Effect.t -> ((a, int) Effect.Deep.continuation -> int) option =
  >  fun eff ->
  >   match eff with
  >   | E -> Some (fun k -> Effect.Deep.continue k ())
  >   | _ -> None
  > 
  > let result = Effect.Deep.try_with main () { effc }
  > let () = Js.log2 result !counter
  > EOF
  $ mkdir -p node_modules
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange.js" node_modules/melange.js
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange" node_modules/melange

Default pipeline now uses tail-perform lowering and preserves one-shot behavior.

  $ melc x.ml -o x.default.js
  $ rg -F "caml_perform({" x.default.js
  [1]
  $ rg -F "caml_perform_tail({" x.default.js
    Caml_effect.caml_perform_tail({
  $ node x.default.js
  1 1

Conservative analysis mode keeps the same result.

  $ MELANGE_EFFECT_ANALYSIS_MODE=conservative melc x.ml -o x.cps.js
  $ rg -F "caml_perform_tail({" x.cps.js
    Caml_effect.caml_perform_tail({
  $ node x.cps.js
  1 1
