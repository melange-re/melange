Regression check: an anonymous computation passed directly to
`Effect.Deep.try_with` should still be selectively CPS-lowered, so pre-`perform`
side effects are not replayed when the continuation is resumed later.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += Tick : int Effect.t
  > 
  > let counter = ref 0
  > let saved : (int, int) Effect.Deep.continuation option ref = ref None
  > 
  > let effc : type a.
  >     a Effect.t -> ((a, int) Effect.Deep.continuation -> int) option =
  >  fun eff ->
  >   match eff with
  >   | Tick -> Some (fun k -> saved := Some k; 0)
  >   | _ -> None
  > 
  > let first =
  >   Effect.Deep.try_with
  >     (fun () ->
  >       counter := !counter + 1;
  >       ignore (Effect.perform Tick);
  >       !counter)
  >     ()
  >     { effc }
  > 
  > let second =
  >   match !saved with
  >   | None -> -1
  >   | Some k -> Effect.Deep.continue k 41
  > 
  > let () = Js.log3 first second !counter
  > EOF
  $ mkdir -p node_modules
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange.js" node_modules/melange.js
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange" node_modules/melange

  $ melc x.ml -o x.js
  $ node x.js
  0 1 1

Generated code uses `caml_perform_tail` for this shape.

  $ rg "caml_perform\\(|caml_perform_tail\\(" x.js
    return Caml_effect.caml_perform_tail({

Conservative effect analysis mode currently behaves the same for this shape.

  $ MELANGE_EFFECT_ANALYSIS_MODE=conservative melc x.ml -o x.cons.js
  $ node x.cons.js
  0 1 1
