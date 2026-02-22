Known selective-CPS breakdown: `perform` inside a returned closure can still
replay, because that closure body is not CPS-lowered.

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
  7 2

Even with selective CPS + conservative analysis, this shape still replays.

  $ MELANGE_EFFECT_CPS_EXPERIMENT=1 MELANGE_EFFECT_ANALYSIS_MODE=conservative melc x.ml -o x.cons.js
  $ node x.cons.js
  7 2
