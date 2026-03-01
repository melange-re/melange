`reperform` should propagate from an inner handler to an outer handler.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += Ping : int Effect.t
  > 
  > let inner : int Effect.Deep.effect_handler = { effc = (fun _ -> None) }
  > 
  > let outer_effc : type a.
  >     a Effect.t -> ((a, int) Effect.Deep.continuation -> int) option =
  >  fun eff ->
  >   match eff with
  >   | Ping -> Some (fun k -> Effect.Deep.continue k 41)
  >   | _ -> None
  > 
  > let outer : int Effect.Deep.effect_handler = { effc = outer_effc }
  > 
  > let v =
  >   Effect.Deep.try_with
  >     (fun () ->
  >       Effect.Deep.try_with (fun () -> 1 + Effect.perform Ping) () inner)
  >     () outer
  > 
  > let () = Js.log v
  > EOF
  $ mkdir -p node_modules
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange.js" node_modules/melange.js
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange" node_modules/melange
  $ melc x.ml -o x.js
  $ node x.js
  42
