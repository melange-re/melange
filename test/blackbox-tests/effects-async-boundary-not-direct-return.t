Crossing an async JS boundary is not direct-return-preserving: the suspended
continuation can be resumed later, but the original call already returned.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += Ping : int Effect.t
  > 
  > type saved = Saved : (int, int) Effect.Shallow.continuation -> saved
  > let saved : saved option ref = ref None
  > let resumed = ref (-1)
  > 
  > let effc_none : type a.
  >     a Effect.t -> ((a, int) Effect.Shallow.continuation -> int) option =
  >  fun _ -> None
  > 
  > let async_resume () =
  >   match !saved with
  >   | Some (Saved k) ->
  >       resumed :=
  >         Effect.Shallow.continue_with k 41
  >           { retc = Fun.id; exnc = raise; effc = effc_none }
  >   | None -> ()
  > 
  > let effc_async : type a.
  >     a Effect.t -> ((a, int) Effect.Shallow.continuation -> int) option =
  >  fun eff ->
  >   match eff with
  >   | Ping ->
  >       Some
  >         (fun k ->
  >           saved := Some (Saved k);
  >           ignore (Js.Global.setTimeout ~f:async_resume 0);
  >           7)
  >   | _ -> None
  > 
  > let run () =
  >   let k0 = Effect.Shallow.fiber (fun () -> 1 + Effect.perform Ping) in
  >   Effect.Shallow.continue_with k0 ()
  >     {
  >       retc = Fun.id;
  >       exnc = raise;
  >       effc = effc_async;
  >     }
  > 
  > let immediate = run ()
  > let () = Js.log2 "immediate" immediate
  > let () = Js.log2 "before_timeout" !resumed
  > let () =
  >   ignore
  >     (Js.Global.setTimeout
  >        ~f:(fun () -> Js.log2 "after_timeout" !resumed)
  >        20)
  > EOF
  $ mkdir -p node_modules
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange.js" node_modules/melange.js
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange" node_modules/melange

  $ melc x.ml -o x.js
  $ node x.js
  immediate 7
  before_timeout -1
  after_timeout 42

Generated code makes the async boundary explicit (`setTimeout`), while
continuation resumption still happens through `continue_with`.

  $ rg "setTimeout|Shallow\\.continue_with" x.js
      resumed.contents = Stdlib__Effect.Shallow.continue_with(match._0, 41, {
        setTimeout(async_resume, 0);
    return Curry._1(run$idk, Stdlib__Effect.Shallow.continue_with(k0, undefined, {
  setTimeout((function (param) {
