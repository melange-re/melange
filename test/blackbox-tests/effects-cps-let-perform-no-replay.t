Selective CPS `let x = perform ... in ...` rewrite avoids replay in a common
non-tail shape.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += Tick : int Effect.t
  > 
  > let counter = ref 0
  > 
  > let body () =
  >   counter := !counter + 1;
  >   let v = Effect.perform Tick in
  >   v + !counter
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

Without selective CPS, replay semantics reruns side effects.

  $ melc x.ml -o x.default.js
  $ node x.default.js
  7 2

With selective CPS enabled, the `let-perform` continuation path avoids replay.

  $ MELANGE_EFFECT_CPS_EXPERIMENT=1 melc x.ml -o x.cps.js
  $ node x.cps.js
  6 1
