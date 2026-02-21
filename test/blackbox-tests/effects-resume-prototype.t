Validate continuation resumption with Deep/Shallow handlers while preserving
function arity in generated JS.

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
  > type _ Effect.t += E : int Effect.t
  > 
  > let f a b = a + Effect.perform E + b
  > 
  > let deep_effc : type a.
  >     a Effect.t -> ((a, int) Effect.Deep.continuation -> int) option =
  >  fun eff ->
  >   match eff with
  >   | E -> Some (fun k -> Effect.Deep.continue k 39)
  >   | _ -> None
  > 
  > let deep =
  >   Effect.Deep.try_with
  >     (fun () -> f 1 2)
  >     ()
  >     {
  >       effc = deep_effc;
  >     }
  > 
  > let shallow_resume k =
  >   Effect.Shallow.continue_with k 39
  >     { retc = Fun.id; exnc = raise; effc = (fun _ -> None) }
  > 
  > let shallow_effc : type a.
  >     a Effect.t -> ((a, int) Effect.Shallow.continuation -> int) option =
  >  fun eff ->
  >   match eff with
  >   | E -> Some shallow_resume
  >   | _ -> None
  > 
  > let shallow =
  >   let k = Effect.Shallow.fiber (fun () -> f 1 2) in
  >   Effect.Shallow.continue_with k ()
  >     {
  >       retc = Fun.id;
  >       exnc = raise;
  >       effc = shallow_effc;
  >     }
  > 
  > let () = Js.log2 deep shallow
  > EOF

  $ dune build @melange
  $ node ./_build/default/melange/x.js
  42 42

Generated function arity stays as source arity (`f` remains binary).

  $ rg "function f\\(a, b\\)" ./_build/default/melange/x.js
  function f(a, b) {
