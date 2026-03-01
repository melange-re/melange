Tail-perform + selective CPS avoids replaying pre-perform side effects.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += Tick : int Effect.t
  > 
  > let counter = ref 0
  > 
  > let body () =
  >   counter := !counter + 1;
  >   Effect.perform Tick
  > 
  > let effc : type a.
  >     a Effect.t -> ((a, int) Effect.Deep.continuation -> int) option =
  >  fun eff ->
  >   match eff with
  >   | Tick -> Some (fun k -> Effect.Deep.continue k 42)
  >   | _ -> None
  > 
  > let result = Effect.Deep.try_with body () { effc }
  > let () = Js.log2 result !counter
  > EOF
  $ mkdir -p node_modules
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange.js" node_modules/melange.js
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange" node_modules/melange

With default selective CPS, the side effect runs once.

  $ melc x.ml -o x.default.js
  $ node x.default.js
  42 1

Recompiling with the same pipeline yields the same one-shot result.

  $ melc x.ml -o x.cps.js
  $ node x.cps.js
  42 1
