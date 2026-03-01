Selective CPS now lowers effectful returned closures, so this shape no longer
replays side effects.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += Tick : int Effect.t
  > 
  > let counter = ref 0
  > 
  > let[@inline never] run f =
  >   counter := !counter + 1;
  >   f ()
  > 
  > let mk () = fun () -> Effect.perform Tick
  > 
  > let body () =
  >   let f = mk () in
  >   run f + !counter
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

  $ melc x.ml -o x.default.js
  $ node x.default.js
  6 1

With conservative analysis mode, this shape avoids replay.

  $ MELANGE_EFFECT_ANALYSIS_MODE=conservative melc x.ml -o x.cons.js
  $ node x.cons.js
  6 1
