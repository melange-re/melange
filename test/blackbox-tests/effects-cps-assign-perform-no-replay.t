Selective CPS assignment-rhs `perform` rewrite avoids replay when the effect
appears on the right-hand side of an assignment.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += Tick : int Effect.t
  > 
  > let counter = ref 0
  > 
  > let body () =
  >   counter := !counter + 1;
  >   let r = ref 0 in
  >   r := Effect.perform Tick;
  >   !r + !counter
  > 
  > let effc : type a.
  >     a Effect.t -> ((a, int) Effect.Deep.continuation -> int) option =
  >  fun eff ->
  >   match eff with
  >   | Tick -> Some (fun k -> Effect.Deep.continue k 5)
  >   | _ -> None
  > 
  > let result = Effect.Deep.try_with body () { effc }
  > let () = Js.log2 result !counter
  > EOF
  $ mkdir -p node_modules
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange.js" node_modules/melange.js
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange" node_modules/melange

With default selective CPS, pre-perform side effects run once.

  $ melc x.ml -o x.default.js
  $ node x.default.js
  6 1

Recompiling with the same pipeline, assignment-rhs evaluation is lowered through
`caml_perform_tail` and the pre-perform increment runs once.

  $ melc x.ml -o x.cps.js
  $ rg "caml_perform_tail\\(" x.cps.js
    return Caml_effect.caml_perform_tail({
  $ node x.cps.js
  6 1
