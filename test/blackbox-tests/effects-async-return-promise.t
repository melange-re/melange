Returning a Promise from the effect arm makes the handled call asynchronous and
separate from continuation resumption.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += Ping : int Effect.t
  > 
  > type saved = Saved : (int, int) Effect.Shallow.continuation -> saved
  > let saved : saved option ref = ref None
  > let run_out = ref (-1)
  > let resumed_out = ref (-1)
  > 
  > let effc_none : type a.
  >     a Effect.t -> ((a, int) Effect.Shallow.continuation -> int Js.Promise.t) option =
  >  fun _ -> None
  > 
  > let async_resume () =
  >   match !saved with
  >   | Some (Saved k) ->
  >       ignore
  >         (Js.Promise.then_
  >            (fun v ->
  >              resumed_out := v;
  >              Js.Promise.resolve ())
  >            (Effect.Shallow.continue_with k 41
  >               { retc = Js.Promise.resolve; exnc = raise; effc = effc_none }))
  >   | None -> ()
  > 
  > let effc_promise : type a.
  >     a Effect.t -> ((a, int) Effect.Shallow.continuation -> int Js.Promise.t) option =
  >  fun eff ->
  >   match eff with
  >   | Ping ->
  >       Some
  >         (fun k ->
  >           saved := Some (Saved k);
  >           ignore (Js.Global.setTimeout ~f:async_resume 0);
  >           Js.Promise.resolve 7)
  >   | _ -> None
  > 
  > let run () : int Js.Promise.t =
  >   let k0 = Effect.Shallow.fiber (fun () -> 1 + Effect.perform Ping) in
  >   Effect.Shallow.continue_with k0 ()
  >     {
  >       retc = Js.Promise.resolve;
  >       exnc = raise;
  >       effc = effc_promise;
  >     }
  > 
  > let () =
  >   ignore
  >     (Js.Promise.then_
  >        (fun v ->
  >          run_out := v;
  >          Js.Promise.resolve ())
  >        (run ()))
  > 
  > let () = Js.log3 "before_timeout" !run_out !resumed_out
  > let () =
  >   ignore
  >     (Js.Global.setTimeout
  >        ~f:(fun () -> Js.log3 "after_timeout" !run_out !resumed_out)
  >        20)
  > EOF
  $ mkdir -p node_modules
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange.js" node_modules/melange.js
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange" node_modules/melange

  $ melc x.ml -o x.js
  $ node x.js
  before_timeout -1 -1
  after_timeout 7 42

Generated code shows both Promise and async boundary calls.

  $ rg "Shallow\\.continue_with|Promise\\.resolve|setTimeout\\(" x.js
      Stdlib__Effect.Shallow.continue_with(match._0, 41, {
          return Promise.resolve(prim);
        return Promise.resolve();
        setTimeout(async_resume, 0);
        return Promise.resolve(7);
    return Curry._1(run$idk, Stdlib__Effect.Shallow.continue_with(k0, undefined, {
        return Promise.resolve(prim);
    return Promise.resolve();
  setTimeout((function (param) {
