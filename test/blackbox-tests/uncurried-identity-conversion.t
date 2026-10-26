ReScript #6470: uncurried function conversion and invalid identity signatures.
The literal declaration receives a normal arity diagnostic; the aliased return
and explicit wrappers are supported.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx))
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ cat > input.ml <<'EOF'
  > type ('a, 'b) curried = 'a -> 'b
  > external to_curried_alias : ('a -> 'b [@u]) -> ('a, 'b) curried = "%identity"
  > let unary = (fun x -> x + 1) [@u]
  > let converted x = to_curried_alias unary x
  > let wrap f x = (f x [@u])
  > let wrap_binary f x y = (f x y [@u])
  > let wrap_unit f () = (f () [@u])
  > external make : unit -> (int -> int [@u]) = "makeUncurried"
  > let capture () = let f = make () in wrap f
  > let nested f x = ((f x [@u]) x [@u])
  > let alias_value = to_curried_alias unary
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > let constructions = 0, calls = 0;
  > globalThis.makeUncurried = () => {
  >   constructions++;
  >   return x => { calls++; return x + 10; };
  > };
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const m = await import("./_build/default/out/input." + ext);
  >     assert.equal(m.converted(7), 8);
  >     assert.equal(m.alias_value(7), 8);
  >     assert.equal(m.wrap(x => x + 2, 7), 9);
  >     assert.equal(m.wrap_binary((x, y) => x * 10 + y, 7, 3), 73);
  >     assert.equal(m.wrap_unit(() => 42), 42);
  >     assert.equal(m.nested(x => y => x + y, 7), 14);
  >     constructions = calls = 0;
  >     const f = m.capture();
  >     assert.equal(constructions, 1);
  >     assert.equal(calls, 0);
  >     assert.equal(f(1), 11);
  >     assert.equal(f(2), 12);
  >     assert.equal(calls, 2);
  >     assert.equal(constructions, 1);
  >     console.log(ext, "uncurried conversions: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js uncurried conversions: ok
  mjs uncurried conversions: ok

  $ cat > invalid.ml <<'EOF'
  > external to_curried : ('a -> 'b [@u]) -> ('a -> 'b) = "%identity"
  > EOF
  $ melc -ppx melppx -c invalid.ml
  File "invalid.ml", line 1, characters 0-65:
  1 | external to_curried : ('a -> 'b [@u]) -> ('a -> 'b) = "%identity"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: The `%identity' primitive type must take a single argument ('a -> 'b)
  [2]
