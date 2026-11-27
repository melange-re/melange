Functor result arities must preserve effects and exceptions on partial
application, and handle argument functions with different arities. Disable
cross-module inlining so the calls use the exported metadata.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.13)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false)
  >  (compile_flags :standard --mel-no-cross-module-opt)
  >  (libraries melange.js)
  >  (module_systems (commonjs js) (esm mjs)))
  > EOF
  $ cat > provider.ml <<'EOF'
  > exception Stop
  > module Make (X : sig val f : int -> int -> int end) = struct
  >   let effects = ref 0
  >   let staged x =
  >     incr effects;
  >     if x < 0 then raise Stop;
  >     fun y -> x + y
  >   let forwarded = X.f
  > end
  > EOF
  $ cat > input.ml <<'EOF'
  > let calls = ref 0
  > module Curried = Provider.Make (struct
  >   let f x = incr calls; fun y -> x + y
  > end)
  > module Binary = Provider.Make (struct
  >   let f x y = x - y
  > end)
  > let pending = Curried.staged 40
  > let () =
  >   assert (!(Curried.effects) = 1);
  >   assert (pending 2 = 42);
  >   assert (try let _pending = Curried.staged (-1) in false with Provider.Stop -> true);
  >   assert (Curried.forwarded 40 2 = 42);
  >   assert (!calls = 1);
  >   assert (Binary.forwarded 40 2 = 38)
  > EOF
  $ dune build @melange
  $ node _build/default/out/input.js
  $ node _build/default/out/input.mjs
