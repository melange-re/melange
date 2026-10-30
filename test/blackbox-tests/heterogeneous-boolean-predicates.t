ReScript #9113: comparing a foreign value with booleans does not make it boolean.
Exercise all strict equality/inequality conjunctions and disjunctions, including
their negations, and repeated getter reads at the FFI boundary.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.13)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > cases.cjs <<'EOF'
  > module.exports = [];
  > for (const op of ['&&', '||'])
  >   for (const a of [true, false]) for (const b of [true, false])
  >     for (const left of ['==', '!=']) for (const right of ['==', '!='])
  >       module.exports.push({op, a, b, left, right});
  > EOF
  $ node <<'EOF'
  > const fs = require('node:fs');
  > const lines = [
  >   'type value',
  >   'external boolean : bool -> value = "%identity"',
  >   'type source',
  >   'external read : source -> value = "value" [@@mel.get]',
  > ];
  > require('./cases.cjs').forEach(({op, a, b, left, right}, i) => {
  >   for (const [prefix, value] of [['direct', 'x'], ['getter', '(read x)']]) {
  >     const expr = `${value} ${left} boolean ${a} ${op} ${value} ${right} boolean ${b}`;
  >     lines.push(`let ${prefix}${i} x = ${expr}`);
  >     lines.push(`let neg_${prefix}${i} x = not (${expr})`);
  >   }
  > });
  > fs.writeFileSync('input.ml', lines.join('\n') + '\n');
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const cases = require('./cases.cjs');
  > const values = [true, false, 0, 1, NaN, '', 'true', null, undefined, {}, [], Symbol('x'), 1n, () => {}];
  > const compare = (x, op, y) => op === '==' ? x === y : x !== y;
  > const m = require('./_build/default/out/input.js');
  > cases.forEach(({op, a, b, left, right}, i) => {
  >   for (const x of values) {
  >     const first = compare(x, left, a);
  >     const continues = op === '&&' ? first : !first;
  >     const expected = continues ? compare(x, right, b) : first;
  >     assert.equal(m['direct' + i](x), expected);
  >     assert.equal(m['neg_direct' + i](x), !expected);
  >     for (const negated of [false, true]) {
  >       const run = m[(negated ? 'neg_' : '') + 'getter' + i];
  >       for (const y of values) {
  >         const result = continues ? compare(y, right, b) : first;
  >         let reads = 0;
  >         const source = {get value() { return ++reads === 1 ? x : y; }};
  >         assert.equal(run(source), result !== negated);
  >         assert.equal(reads, continues ? 2 : 1);
  >       }
  >       let reads = 0;
  >       const failure = {};
  >       const throwing = {get value() { if (++reads === 2) throw failure; return x; }};
  >       if (continues) assert.throws(() => run(throwing), e => e === failure);
  >       else assert.equal(run(throwing), first !== negated);
  >       assert.equal(reads, continues ? 2 : 1);
  >     }
  >   }
  > });
  > EOF
