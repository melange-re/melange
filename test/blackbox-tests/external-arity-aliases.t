External aliases preserve arity and remain function values until applied.
ReScript #6881; Melange's explicit [@u] calls already handle aliased types.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (runtime_deps arity-fixture.cjs)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx))
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ cat > arity-fixture.cjs <<'EOF'
  > function combine(a, b) {
  >   if (arguments.length !== 2) throw new Error("incorrect imported arity");
  >   globalThis.arityCalls++;
  >   return a * 10 + b;
  > }
  > module.exports = combine;
  > module.exports.combine = combine;
  > module.exports.default = combine;
  > EOF
  $ cat > input.ml <<'EOF'
  > type binary = (int -> int -> int [@u])
  > type ('a, 'b) fn = ('a -> 'b [@u])
  > type curried = int -> int -> int
  > external alias : binary = "combine"
  > external direct : (int -> int -> int [@u]) = "combine"
  > external unary_alias : (int, int) fn = "unary"
  > external unary_direct : (int -> int [@u]) = "unary"
  > external curried_alias : curried = "combine"
  > external curried_direct : int -> int -> int = "combine"
  > external scoped : binary = "combine" [@@mel.scope "arityScope"]
  > external imported : binary = "combine" [@@mel.module "./arity-fixture.cjs"]
  > external imported_direct : (int -> int -> int [@u]) = "combine"
  >   [@@mel.module "./arity-fixture.cjs"]
  > external imported_default : binary = "default" [@@mel.module "./arity-fixture.cjs"]
  > external imported_default_direct : (int -> int -> int [@u]) = "default"
  >   [@@mel.module "./arity-fixture.cjs"]
  > external optional : ?x:int -> y:int -> unit -> int = "optionalArity"
  > let alias_value = alias
  > let direct_value = direct
  > let imported_value = imported
  > let default_value = imported_default
  > let call_alias x y = (alias x y [@u])
  > let call_direct x y = (direct x y [@u])
  > let call_unary_alias x = (unary_alias x [@u])
  > let call_unary_direct x = (unary_direct x [@u])
  > let call_curried_alias x y = curried_alias x y
  > let call_curried_direct x y = curried_direct x y
  > let call_scoped x y = (scoped x y [@u])
  > let call_imported x y = (imported x y [@u])
  > let call_imported_direct x y = (imported_direct x y [@u])
  > let call_default x y = (imported_default x y [@u])
  > let call_default_direct x y = (imported_default_direct x y [@u])
  > let call_missing () = optional ~y:3 ()
  > let call_present () = optional ~x:7 ~y:3 ()
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > globalThis.arityCalls = 0;
  > globalThis.combine = function(a, b) {
  >   assert.equal(arguments.length, 2);
  >   globalThis.arityCalls++;
  >   return a * 10 + b;
  > };
  > globalThis.unary = function(a) {
  >   assert.equal(arguments.length, 1);
  >   globalThis.arityCalls++;
  >   return a + 1;
  > };
  > globalThis.arityScope = {combine: globalThis.combine};
  > globalThis.optionalArity = function(x, y) {
  >   assert.equal(arguments.length, 2);
  >   return (x === undefined ? 0 : x) * 10 + y;
  > };
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const before = globalThis.arityCalls;
  >     const m = await import("./_build/default/out/input." + ext);
  >     const fixture = require("./_build/default/out/arity-fixture.cjs");
  >     assert.equal(globalThis.arityCalls, before);
  >     assert.equal(m.alias_value, globalThis.combine);
  >     assert.equal(m.direct_value, globalThis.combine);
  >     assert.equal(m.imported_value, fixture.combine);
  >     assert.equal(m.default_value, fixture.default);
  >     const binary = ["call_alias", "call_direct", "call_curried_alias", "call_curried_direct",
  >       "call_scoped", "call_imported", "call_imported_direct", "call_default", "call_default_direct"];
  >     for (const name of binary) assert.equal(m[name](2, 3), 23);
  >     assert.equal(m.call_unary_alias(4), 5);
  >     assert.equal(m.call_unary_direct(4), 5);
  >     assert.equal(globalThis.arityCalls - before, binary.length + 2);
  >     assert.equal(m.call_missing(), 3);
  >     assert.equal(m.call_present(), 73);
  >     console.log(ext, "external arity and function values: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js external arity and function values: ok
  mjs external arity and function values: ok
