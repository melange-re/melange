ReScript #7034: array helpers and JavaScript concat are not interchangeable with spread.
Protect sparse arrays, custom iterators, allocation, and argument effects.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > let append a b = Array.append a b
  > let concat a b = Array.concat [a; b]
  > let copy a = Array.copy a
  > let js_concat a b = Js.Array.concat ~other:b a
  > external next : int -> int array = "auditArray"
  > let effectful () = let a = next 1 in let b = next 2 in Array.append a b
  > EOF
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require("node:assert/strict");
  > const m = require("./_build/default/out/input.js");
  > const left = [, 1], right = [2];
  > let iteratorReads = 0;
  > left[Symbol.iterator] = function* () { iteratorReads++; yield 99; };
  > for (const combine of [m.append, m.concat, m.js_concat]) {
  >   const result = combine(left, right);
  >   assert.equal(result.length, 3);
  >   assert.equal(result[0], undefined);
  >   assert.deepEqual(result.slice(1), [1, 2]);
  >   assert.equal(Object.hasOwn(result, 0), combine === m.concat);
  >   assert.notStrictEqual(result, left); assert.notStrictEqual(result, right);
  >   result[1] = 10; assert.equal(left[1], 1);
  > }
  > const copied = m.copy(left);
  > assert.deepEqual(copied, [undefined, 1]);
  > assert.notStrictEqual(copied, left);
  > assert.equal(iteratorReads, 0);
  > assert.deepEqual([...left, ...right], [99, 2]);
  > assert.equal(iteratorReads, 1);
  > const events = [];
  > globalThis.auditArray = x => { events.push(x); return [x]; };
  > assert.deepEqual(m.effectful(), [1, 2]);
  > assert.deepEqual(events, [1, 2]);
  > const failure = new Error("first array");
  > events.length = 0;
  > globalThis.auditArray = x => { events.push(x); throw failure; };
  > assert.throws(m.effectful, e => e === failure);
  > assert.deepEqual(events, [1]);
  > EOF
