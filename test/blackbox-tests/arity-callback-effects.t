Callback arity inference must preserve effects and exceptions between curried
arguments. All call sites contribute to the arity, including escaping and
partially applied uses of the local helper.

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
  > let apply invoke f = invoke f 2 40 2
  > EOF
  $ cat > input.ml <<'EOF'
  > let effects = ref 0
  > exception Stop
  > let staged x =
  >   incr effects;
  >   if x < 0 then raise Stop;
  >   fun y -> incr effects; x + y
  > let binary x y = incr effects; x - y
  > let partial_effects () =
  >   effects := 0;
  >   let rec invoke f n =
  >     if n = 0 then
  >       let pending = f 40 in
  >       let before = !effects in
  >       let result = pending 2 in
  >       before, result, !effects
  >     else invoke f (n - 1)
  >   in
  >   invoke staged 2
  > let partial_exception () =
  >   effects := 0;
  >   let rec invoke f n =
  >     if n = 0 then
  >       try Some (f (-1)) with Stop -> None
  >     else invoke f (n - 1)
  >   in
  >   let caught = match invoke staged 2 with None -> true | Some _ -> false in
  >   caught, !effects
  > let mixed () =
  >   effects := 0;
  >   let rec invoke f n x y =
  >     if n = 0 then f x y else invoke f (n - 1) x y
  >   in
  >   let first = invoke binary 2 40 2 in
  >   let second = invoke staged 2 40 2 in
  >   first, second, !effects
  > let escaped () =
  >   effects := 0;
  >   let rec invoke f n x y =
  >     if n = 0 then f x y else invoke f (n - 1) x y
  >   in
  >   let first = invoke binary 2 40 2 in
  >   let second = Helper.apply invoke staged in
  >   first, second, !effects
  > let partial_helper () =
  >   effects := 0;
  >   let rec invoke f n x y =
  >     if n = 0 then f x y else invoke f (n - 1) x y
  >   in
  >   let pending = invoke binary in
  >   let first = pending 2 40 2 in
  >   let second = invoke staged 2 40 2 in
  >   first, second, !effects
  > EOF
  $ dune build @melange
  $ node --input-type=module <<'EOF'
  > for (const ext of ['js', 'mjs']) {
  >   const t = await import('./_build/default/out/input.' + ext);
  >   for (const name of ['partial_effects', 'partial_exception', 'mixed', 'escaped', 'partial_helper']) {
  >     console.log(ext, name, JSON.stringify(t[name]()));
  >   }
  > }
  > EOF
  js partial_effects [1,42,2]
  js partial_exception [true,1]
  js mixed [38,42,3]
  js escaped [38,42,3]
  js partial_helper [38,42,3]
  mjs partial_effects [1,42,2]
  mjs partial_exception [true,1]
  mjs mixed [38,42,3]
  mjs escaped [38,42,3]
  mjs partial_helper [38,42,3]
