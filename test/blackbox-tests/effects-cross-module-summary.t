Cross-module effect summaries in `.cmj` should avoid unnecessary CPS lifting for
known-pure imports, while still lifting callers of known-effectful imports.

  $ . ./setup.sh

Pure imported function: conservative mode should keep direct style.

  $ cat > a_pure.ml <<EOF
  > let f x = x + 1
  > EOF
  $ cat > b_pure.ml <<EOF
  > let g x = A_pure.f x + 1
  > let () = Js.log (g 40)
  > EOF
  $ melc a_pure.ml -o a_pure.js
  $ melc --mel-stop-after-cmj -I . b_pure.ml -o b_pure.cmj
  $ melc -I . b_pure.cmj -o b_pure.js
  $ rg -F 'function g$cps(' b_pure.js
  [1]
  $ node b_pure.js
  42

Effectful imported function: conservative mode should lift the caller.

  $ cat > a_eff.ml <<EOF
  > type _ Effect.t += E : int Effect.t
  > let f () = Effect.perform E
  > EOF
  $ cat > b_eff.ml <<EOF
  > let g () = A_eff.f ()
  > EOF
  $ melc a_eff.ml -o a_eff.js
  $ melc --mel-stop-after-cmj -I . b_eff.ml -o b_eff.cmj
  $ melc -I . b_eff.cmj -o b_eff.js
  $ rg -F 'function g$cps(' b_eff.js
  [1]
  $ rg -F 'function g$idk(' b_eff.js
  function g$idk(__x) {
  $ rg -F 'return Curry._1(g$idk, A_eff.f());' b_eff.js
    return Curry._1(g$idk, A_eff.f());
