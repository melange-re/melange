`Effect.Deep.get_callstack` should return a valid raw backtrace value, and
`discontinue_with_backtrace` should raise the provided exception.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += Tick : int Effect.t
  > 
  > let saved : (int, int) Effect.Deep.continuation option ref = ref None
  > 
  > let effc : type a.
  >     a Effect.t -> ((a, int) Effect.Deep.continuation -> int) option =
  >  fun eff ->
  >   match eff with
  >   | Tick ->
  >       Some
  >         (fun k ->
  >           saved := Some k;
  >           0)
  >   | _ -> None
  > 
  > let _ = Effect.Deep.try_with (fun () -> Effect.perform Tick) () { effc }
  > 
  > let continuation_length, status =
  >   match !saved with
  >   | None -> (-1, "missing")
  >   | Some k ->
  >       let bt = Effect.Deep.get_callstack k 10 in
  >       let continuation_length = Printexc.raw_backtrace_length bt in
  >       let status =
  >         try
  >           ignore (Effect.Deep.discontinue_with_backtrace k Exit bt);
  >           "no-exn"
  >         with
  >         | Exit -> "exit"
  >         | _ -> "other"
  >       in
  >       (continuation_length, status)
  > 
  > let runtime_length = Printexc.raw_backtrace_length (Printexc.get_callstack 10)
  > let () = Js.log3 continuation_length runtime_length status
  > EOF
  $ mkdir -p node_modules
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange.js" node_modules/melange.js
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange" node_modules/melange

  $ melc x.ml -o x.js
  $ node x.js
  0 0 exit
