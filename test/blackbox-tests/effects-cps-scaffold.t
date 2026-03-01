Selective-CPS scaffold: preserve public arity while
injecting hidden continuation plumbing.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += E : int Effect.t
  > 
  > let f aa bb = aa + Effect.perform E + bb
  > EOF

Default compilation already injects hidden continuation plumbing.

  $ melc x.ml -o x.default.js
  $ rg "__k = function" x.default.js
  [1]

Compiling with CPS debug enabled shows the same lifting, while `f` still has
arity 2.

  $ MELANGE_EFFECT_CPS_DEBUG=1 melc x.ml -o x.cps.js
  [effect-cps] lifted f -> f$cps
  $ rg "function f\\(aa, bb\\)|__k = function" x.cps.js
  function f(aa, bb) {
