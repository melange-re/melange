Minimal shallow-handler example and CPS-style arity expansion in generated JS.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += E : int Effect.t
  > 
  > let run () =
  >   let k = Effect.Shallow.fiber (fun () -> Effect.perform E) in
  >   Effect.Shallow.continue_with k ()
  >     {
  >       retc = Fun.id;
  >       exnc = raise;
  >       effc =
  >         (fun (type a) (eff : a Effect.t) ->
  >           match eff with
  >           | E -> Some (fun _k -> 7)
  >           | _ -> None);
  >     }
  > 
  > let _ = run ()
  > EOF

  $ melc x.ml -o x.js

The user module is tiny and direct.

  $ rg "Shallow\\.fiber|caml_perform|Shallow\\.continue_with" x.js
    const k = Stdlib__Effect.Shallow.fiber(function (param) {
      return Caml_effect.caml_perform_tail({
    return Curry._1(run$idk, Stdlib__Effect.Shallow.continue_with(k, undefined, {

But generated `melange/effect.js` uses CPS-style internal helpers with one extra
argument (`last_fiber`) on top of effect + continuation.

  $ effect_js="$(find "$INSIDE_DUNE" -path '*/node_modules/melange/effect.js' | head -n 1)"
  $ rg "const effc = function \\(eff, k, last_fiber\\)|caml_reperform\\(eff, k, last_fiber\\)" "$effect_js" | head -n 2
    const effc = function (eff, k, last_fiber) {
        return Caml_effect.caml_reperform(eff, k, last_fiber);
