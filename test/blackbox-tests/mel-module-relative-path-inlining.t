Regression test for relative `[@mel.module]` paths hidden behind exported
wrappers, including one in a nested module.

  $ . ./setup.sh

  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >  (target dist)
  >  (alias melange)
  >  (module_systems commonjs)
  >  (emit_stdlib false)
  >  (libraries app)
  >  (runtime_deps vendor/shared.js))
  > EOF

  $ mkdir -p app/deep bindings vendor

  $ cat > vendor/shared.js <<EOF
  > exports.value = function (x) {
  >   return x + 1;
  > };
  > EOF

  $ cat > bindings/dune <<EOF
  > (library
  >  (modes melange)
  >  (preprocess (pps melange.ppx))
  >  (wrapped false)
  >  (name bindings))
  > EOF

Relative path is valid from the binding module output, but not from the nested
output dir

  $ cat > bindings/bindings.ml <<EOF
  > external value : int -> int = "value"
  > [@@mel.module "../vendor/shared.js"]
  > 
  > let run x = value x
  > module Nested = struct
  >   let run x = value x
  > end
  > EOF

  $ cat > app/deep/dune <<EOF
  > (library
  >  (modes melange)
  >  (wrapped false)
  >  (name app)
  >  (libraries bindings))
  > EOF

  $ cat > app/deep/main.ml <<EOF
  > let () = Js.log (Bindings.run 41)
  > let () = Js.log (Bindings.Nested.run 41)
  > EOF

  $ dune build @melange

  $ node _build/default/dist/app/deep/main.js
  42
  42
