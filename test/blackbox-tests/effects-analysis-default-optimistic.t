Default effect analysis mode should be optimistic.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += E : int Effect.t
  > 
  > let[@inline never] run f = f ()
  > let effectful () = Effect.perform E
  > let main () = run effectful
  > EOF

With optimistic defaults, unknown higher-order callback paths are not lifted.

  $ melc x.ml -o x.js
  $ rg -F 'function run$cps(' x.js
  [1]
