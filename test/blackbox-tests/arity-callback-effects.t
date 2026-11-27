Callback arity inference must preserve effects and exceptions on partial
application, and account for mixed arities, escaping and partially applied helpers.

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
  $ cat > helper.ml <<'EOF'
  > let apply invoke f = invoke f 1 40 2
  > EOF
  $ cat > input.ml <<'EOF'
  > let effects = ref 0
  > exception Stop
  > let staged x =
  >   incr effects;
  >   if x < 0 then raise Stop;
  >   fun y -> x + y
  > let binary x y = x - y
  > let () =
  >   let rec invoke f n x =
  >     if n = 0 then f x else invoke f (n - 1) x
  >   in
  >   let pending = invoke staged 1 40 in
  >   assert (!effects = 1);
  >   assert (pending 2 = 42);
  >   assert (try let _pending = invoke staged 1 (-1) in false with Stop -> true)
  > let () =
  >   let rec invoke f n x y =
  >     if n = 0 then f x y else invoke f (n - 1) x y
  >   in
  >   assert (invoke binary 1 40 2 = 38);
  >   assert (invoke staged 1 40 2 = 42)
  > let () =
  >   let rec invoke f n x y =
  >     if n = 0 then f x y else invoke f (n - 1) x y
  >   in
  >   assert (invoke binary 1 40 2 = 38);
  >   assert (Helper.apply invoke staged = 42)
  > let () =
  >   let rec invoke f n x y =
  >     if n = 0 then f x y else invoke f (n - 1) x y
  >   in
  >   let pending = invoke binary in
  >   assert (pending 1 40 2 = 38);
  >   assert (invoke staged 1 40 2 = 42)
  > EOF
  $ dune build @melange
  $ node _build/default/out/input.js
  $ node _build/default/out/input.mjs
