Selective CPS nested-argument rewrite avoids replay when `perform` is nested
inside an argument expression (e.g. `use (1 + perform)`).

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
  >   use (1 + Effect.perform Tick)
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

With default selective CPS, pre-perform side effects run once.

  $ melc x.ml -o x.default.js
  $ node x.default.js
  7 1

Recompiling with the same pipeline, nested argument evaluation is lowered through
`caml_perform_tail` and the pre-perform increment runs once.

  $ melc x.ml -o x.cps.js
  $ rg "caml_perform_tail\\(" x.cps.js
    return Caml_effect.caml_perform_tail({
  $ node x.cps.js
  7 1
