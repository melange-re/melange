ReScript #7138: push negations through boolean comparisons without dropping effects.
Relational leaves must retain their NaN behavior.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > let conjunction x y = not (x = 1 && y = 2)
  > let disjunction x y = not (x = 1 || y = 2)
  > let nested x y z = not ((x = 1 && y = 2) || z = 3)
  > let types x = not (Js.typeof x = "string" || Js.typeof x = "number")
  > external next : int -> int = "negationNext"
  > let effects () = not (next 1 = 1 && next 2 = 2)
  > let mixed x y = not (x < 0. && y = 2)
  > let mixed_or x y = not (x < 0. || y = 2)
  > let equality x y = not (x = 0. && y = 2)
  > let nullish x = not (Js.Nullable.isNullable x && Js.typeof x = "object")
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require("node:assert/strict");
  > let hits = [], first = 1;
  > globalThis.negationNext = n => { hits.push(n); return n === 1 ? first : n; };
  > const m = require("./_build/default/out/input.js");
  > for (const x of [0, 1, 2])
  >   for (const y of [0, 1, 2]) {
  >     assert.equal(m.conjunction(x, y), !(x === 1 && y === 2));
  >     assert.equal(m.disjunction(x, y), !(x === 1 || y === 2));
  >     for (const z of [0, 3]) assert.equal(m.nested(x, y, z), !((x === 1 && y === 2) || z === 3));
  >   }
  > for (const x of [undefined, null, 1, "a", true, {}, []])
  >   assert.equal(m.types(x), !(typeof x === "string" || typeof x === "number"));
  > for (const x of [NaN, -1, 0, -0, 1, Infinity, -Infinity])
  >   for (const y of [1, 2]) {
  >     assert.equal(m.mixed(x, y), !(x < 0 && y === 2));
  >     assert.equal(m.mixed_or(x, y), !(x < 0 || y === 2));
  >     assert.equal(m.equality(x, y), !(x === 0 && y === 2));
  >   }
  > for (const x of [undefined, null, {}, 1])
  >   assert.equal(m.nullish(x), !((x == null) && typeof x === "object"));
  > for (first of [0, 1]) {
  >   hits = [];
  >   assert.equal(m.effects(), first !== 1);
  >   assert.deepEqual(hits, first === 1 ? [1, 2] : [1]);
  > }
  > const thrown = {};
  > globalThis.negationNext = () => { throw thrown; };
  > assert.throws(() => m.effects(), e => e === thrown);
  > console.log("js", "outer negations:", ["conjunction", "disjunction", "nested", "types"]
  >   .map(name => /return !\(/.test(m[name].toString())).join(", "));
  > EOF
  js outer negations: true, true, true, true

