Exercise both JavaScript optimization schedules. The eager mode is the old
pipeline and acts as an A/B oracle for generated JavaScript.

  $ . ./setup.sh

  $ mkdir sources eager delayed
  $ cat > sources/pure.ml <<'EOF'
  > let used = 42
  > let unused = 99
  > EOF
  $ cat > sources/impure.ml <<'EOF'
  > let () = Js.log "impure dependency loaded"
  > let used = 7
  > EOF
  $ cat > sources/main.ml <<'EOF'
  > module Alias = Pure
  > let from_alias = Alias.used
  > let from_impure = Impure.used
  > let unused_local = Pure.unused
  > EOF
  $ cat > sources/one_shot.ml <<'EOF'
  > let identity x = x
  > let answer = identity 42
  > EOF

Compile identical inputs in eager and delayed mode. Each `.cmj` is emitted by
a separate compiler process, with the opposite scheduling flag supplied at
emission time to verify that the schedule recorded in the artifact wins.

  $ for mode in eager delayed; do
  >   cp sources/*.ml "$mode"/
  >   if test "$mode" = eager; then
  >     compile_flag=--mel-eager-js-optimizations
  >     emit_flag=--mel-delay-js-optimizations
  >   else
  >     compile_flag=--mel-delay-js-optimizations
  >     emit_flag=--mel-eager-js-optimizations
  >   fi
  >   (
  >     cd "$mode"
  >     melc $MEL_STDLIB_FLAGS "$compile_flag" --mel-cross-module-opt \
  >       --mel-package-output commonjs:.:.cjs \
  >       --mel-package-output es6:.:.mjs \
  >       --mel-stop-after-cmj pure.ml
  >     melc $MEL_STDLIB_FLAGS "$compile_flag" --mel-cross-module-opt \
  >       --mel-package-output commonjs:.:.cjs \
  >       --mel-package-output es6:.:.mjs \
  >       --mel-stop-after-cmj impure.ml
  >     melc $MEL_STDLIB_FLAGS "$compile_flag" --mel-cross-module-opt -I . \
  >       --mel-package-output commonjs:.:.cjs \
  >       --mel-package-output es6:.:.mjs \
  >       --preamble '"from cmj";' \
  >       --mel-stop-after-cmj main.ml
  >     cp main.cmj main.first.cmj
  >     melc $MEL_STDLIB_FLAGS "$compile_flag" --mel-cross-module-opt -I . \
  >       --mel-package-output commonjs:.:.cjs \
  >       --mel-package-output es6:.:.mjs \
  >       --preamble '"from cmj";' \
  >       --mel-stop-after-cmj main.ml
  >     cmp main.first.cmj main.cmj
  >     melc $MEL_STDLIB_FLAGS "$emit_flag" --mel-cross-module-opt -I . \
  >       --mel-package-output commonjs:.:.cjs \
  >       --mel-package-output es6:.:.mjs main.cmj -o main.js
  >     melc $MEL_STDLIB_FLAGS "$compile_flag" \
  >       --mel-package-output commonjs:.:.js one_shot.ml -o one_shot.js
  >   )
  > done

  $ cmp eager/main.cjs delayed/main.cjs && echo 'CommonJS: identical'
  CommonJS: identical
  $ cmp eager/main.mjs delayed/main.mjs && echo 'ES modules: identical'
  ES modules: identical
  $ cmp eager/one_shot.js delayed/one_shot.js && echo 'one-shot: identical'
  one-shot: identical
  $ grep -q 'require("./impure.cjs")' delayed/main.cjs && echo 'impure dependency retained'
  impure dependency retained
  $ grep -q '"from cmj";' delayed/main.cjs && echo 'CMJ preamble retained'
  CMJ preamble retained

Delayed CMJs carry pre-optimization JS IR, but the format should remain within
a generous size bound and deterministic for identical input.

  $ eager_bytes=$(wc -c < eager/main.cmj)
  $ delayed_bytes=$(wc -c < delayed/main.cmj)
  $ test "$delayed_bytes" -lt "$((eager_bytes * 4))" && echo 'CMJ growth: bounded'
  CMJ growth: bounded

Fatal warnings must still stop before writing a CMJ.

  $ cat > warning.ml <<'EOF'
  > let f x =
  >   let unused = 1 in
  >   x
  > EOF
  $ if melc $MEL_STDLIB_FLAGS --mel-delay-js-optimizations \
  >      --mel-stop-after-cmj -w +26 -warn-error +26 warning.ml \
  >      >/dev/null 2>&1; then
  >   echo 'unexpected success'
  > else
  >   echo 'fatal warning rejected'
  > fi
  fatal warning rejected
  $ test ! -e warning.cmj && echo 'no CMJ written'
  no CMJ written

Dune must preserve the same output across separate CMJ and JavaScript rules,
including multiple module systems and cross-module optimization.

  $ for mode in eager delayed; do
  >   mkdir "dune-$mode"
  >   cp sources/pure.ml sources/impure.ml sources/main.ml "dune-$mode"/
  >   cat > "dune-$mode/dune-project" <<EOF
  > (lang dune 3.24)
  > (using melange 1.0)
  > EOF
  >   if test "$mode" = eager; then
  >     compile_flag=--mel-eager-js-optimizations
  >   else
  >     compile_flag=--mel-delay-js-optimizations
  >   fi
  >   cat > "dune-$mode/dune" <<EOF
  > (melange.emit
  >  (target output)
  >  (emit_stdlib false)
  >  (module_systems (commonjs cjs) (esm mjs))
  >  (compile_flags :standard $compile_flag --mel-cross-module-opt))
  > EOF
  >   (cd "dune-$mode" && dune build @melange)
  > done
  $ cmp dune-eager/_build/default/output/main.cjs dune-delayed/_build/default/output/main.cjs
  $ cmp dune-eager/_build/default/output/main.mjs dune-delayed/_build/default/output/main.mjs
  $ echo 'Dune outputs: identical'
  Dune outputs: identical
