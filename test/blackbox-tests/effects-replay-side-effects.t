Regression check: side effects placed before `perform` run once with the
default selective-CPS lowering.

  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >  (target melange)
  >  (alias melange)
  >  (libraries melange))
  > EOF

  $ cat > x.ml <<EOF
  > type _ Effect.t += Tick : unit Effect.t
  > 
  > let counter = ref 0
  > 
  > let body () =
  >   counter := !counter + 1;
  >   Effect.perform Tick;
  >   !counter
  > 
  > let effc : type a.
  >     a Effect.t -> ((a, int) Effect.Deep.continuation -> int) option =
  >  fun eff ->
  >   match eff with
  >   | Tick -> Some (fun k -> Effect.Deep.continue k ())
  >   | _ -> None
  > 
  > let result = Effect.Deep.try_with body () { effc }
  > let () = Js.log2 result !counter
  > EOF

  $ dune build @melange
  $ node ./_build/default/melange/x.js
  1 1
