Shallow suspension prototype: capture a continuation, return immediately, then
resume it later.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += Ping : int Effect.t
  > 
  > type saved = Saved : (int, int) Effect.Shallow.continuation -> saved
  > let saved : saved option ref = ref None
  > 
  > let effc_suspend : type a.
  >     a Effect.t -> ((a, int) Effect.Shallow.continuation -> int) option =
  >  fun eff ->
  >   match eff with
  >   | Ping ->
  >       Some
  >         (fun k ->
  >           saved := Some (Saved k);
  >           7)
  >   | _ -> None
  > 
  > let effc_none : type a.
  >     a Effect.t -> ((a, int) Effect.Shallow.continuation -> int) option =
  >  fun _ -> None
  > 
  > let suspend () =
  >   let k0 = Effect.Shallow.fiber (fun () -> 1 + Effect.perform Ping) in
  >   Effect.Shallow.continue_with k0 ()
  >     {
  >       retc = Fun.id;
  >       exnc = raise;
  >       effc = effc_suspend;
  >     }
  > 
  > let resume () =
  >   match !saved with
  >   | Some (Saved k) ->
  >       Effect.Shallow.continue_with k 41
  >         { retc = Fun.id; exnc = raise; effc = effc_none }
  >   | None -> -1
  > 
  > let () = Js.log2 (suspend ()) (resume ())
  > EOF
  $ mkdir -p node_modules
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange.js" node_modules/melange.js
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange" node_modules/melange

  $ melc x.ml -o x.js
  $ node x.js
  7 42

Generated user code shows suspension entrypoints (`fiber` + `continue_with`).

  $ rg "Shallow\\.fiber|Shallow\\.continue_with" x.js
    const k0 = Stdlib__Effect.Shallow.fiber(function (param) {
    return Curry._1(suspend$idk, Stdlib__Effect.Shallow.continue_with(k0, undefined, {
      return Stdlib__Effect.Shallow.continue_with(match._0, 41, {

Runtime suspension/resumption plumbing is explicit in `effect.js`.

  $ effect_js="$(find "$INSIDE_DUNE" -path '*/node_modules/melange/effect.js' | head -n 1)"
  $ rg "caml_continuation_use_and_update_handler_noexc" "$effect_js"
    const stack = Caml_effect.caml_continuation_use_and_update_handler_noexc(k, handler.retc, handler.exnc, effc);
  $ rg "caml_resume\\(stack, resume_fun, v, last_fiber\\)" "$effect_js"
    return Caml_effect.caml_resume(stack, resume_fun, v, last_fiber);
