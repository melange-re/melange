Reusing a one-shot continuation should raise
`Effect.Continuation_already_resumed` (Deep and Shallow).

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += Tick : int Effect.t
  > 
  > let deep_saved : (int, int) Effect.Deep.continuation option ref = ref None
  > let shallow_saved : (int, int) Effect.Shallow.continuation option ref = ref None
  > 
  > let deep_effc : type a.
  >     a Effect.t -> ((a, int) Effect.Deep.continuation -> int) option =
  >  fun eff ->
  >   match eff with
  >   | Tick -> Some (fun k -> deep_saved := Some k; 0)
  >   | _ -> None
  > 
  > let _ =
  >   Effect.Deep.try_with (fun () -> Effect.perform Tick) ()
  >     {
  >       effc = deep_effc;
  >     }
  > 
  > let deep_status =
  >   match !deep_saved with
  >   | None -> "missing"
  >   | Some k ->
  >       ignore (Effect.Deep.continue k 1);
  >       (try
  >          ignore (Effect.Deep.continue k 2);
  >          "no-error"
  >        with
  >       | Effect.Continuation_already_resumed -> "already"
  >       | _ -> "other")
  > 
  > let shallow_effc : type a.
  >     a Effect.t -> ((a, int) Effect.Shallow.continuation -> int) option =
  >  fun eff ->
  >   match eff with
  >   | Tick -> Some (fun k -> shallow_saved := Some k; 0)
  >   | _ -> None
  > 
  > let _ =
  >   let k0 = Effect.Shallow.fiber (fun () -> Effect.perform Tick) in
  >   Effect.Shallow.continue_with k0 ()
  >     {
  >       retc = Fun.id;
  >       exnc = raise;
  >       effc = shallow_effc;
  >     }
  > 
  > let shallow_none : type a.
  >     a Effect.t -> ((a, int) Effect.Shallow.continuation -> int) option =
  >  fun _ -> None
  > 
  > let shallow_status =
  >   match !shallow_saved with
  >   | None -> "missing"
  >   | Some k ->
  >       ignore
  >         (Effect.Shallow.continue_with k 1
  >            { retc = Fun.id; exnc = raise; effc = shallow_none });
  >       (try
  >          ignore
  >            (Effect.Shallow.continue_with k 2
  >               { retc = Fun.id; exnc = raise; effc = shallow_none });
  >          "no-error"
  >        with
  >       | Effect.Continuation_already_resumed -> "already"
  >       | _ -> "other")
  > 
  > let () = Js.log2 deep_status shallow_status
  > EOF
  $ mkdir -p node_modules
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange.js" node_modules/melange.js
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange" node_modules/melange

  $ melc x.ml -o x.js
  $ node x.js
  already already
