A match can return functions with different runtime arities. The shared fallback
is binary, while the other branch performs an effect after its first argument
and returns a unary function.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.13)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false)
  >  (libraries melange.js)
  >  (module_systems (commonjs js) (esm mjs)))
  > EOF
  $ cat > input.ml <<'EOF'
  > let effects = ref 0
  > let run choice x y =
  >   let f = match choice with
  >     | Some true -> fun x -> incr effects; fun y -> x + y
  >     | Some false | None -> fun x y -> x - y
  >   in
  >   f x y
  > let effect_count () = !effects
  > EOF
  $ dune build @melange
  $ node --input-type=module <<'EOF'
  > for (const ext of ['js', 'mjs']) {
  >   const t = await import('./_build/default/out/input.' + ext);
  >   console.log(ext, t.run(true, 40, 2), t.run(false, 40, 2), t.run(undefined, 40, 2), t.effect_count());
  > }
  > EOF
  js 42 38 38 1
  mjs 42 38 38 1
