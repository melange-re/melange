Inlining a functor must preserve the bindings of mutable locals, even when
the branch that assigns to the reference is never taken.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.13)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false)
  >  (compile_flags :standard --mel-cross-module-opt)
  >  (libraries melange.js)
  >  (module_systems (commonjs js) (esm mjs)))
  > EOF
  $ cat > provider.ml <<'EOF'
  > module Make (X : sig val flag : bool end) = struct
  >   let value =
  >     let r = ref 0 in
  >     if X.flag then r := 42;
  >     !r
  > end
  > EOF
  $ cat > input.ml <<'EOF'
  > module M = Provider.Make (struct let flag = false end)
  > let () = assert (M.value = 0)
  > EOF
  $ dune build @melange
  $ node _build/default/out/input.js
  $ node _build/default/out/input.mjs
