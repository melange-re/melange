ReScript #9114: conservative expression equality must not imply unequal literals.
Melange retains these comparisons; check numeric equality and observable reads.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.13)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > let same x = x = 2.5 && x = 2.5
  > let different x = x = 2.5 && x = 3.5
  > let neq_eq x = x <> 2.5 && x = 2.5
  > let eq_neq x = x = 2.5 && x <> 2.5
  > let neq_other x = x <> 2.5 && x = 3.5
  > let either x = x = 2.5 || x = 2.5
  > let zero x = x = 0. && x = -0.
  > let nan x = x = Float.nan && x = Float.nan
  > let not_same x = not (x = 2.5 && x = 2.5)
  > let not_neq_eq x = not (x <> 2.5 && x = 2.5)
  > let not_either x = not (x = 2.5 || x = 2.5)
  > let classify x = if x = 2.5 && x = 2.5 then 1 else 0
  > external int_json : int -> Js.Json.t = "%identity"
  > let mixed x = x == int_json 1 && x == Js.Json.number 1.
  > let mixed_reverse x = x == Js.Json.number 1. && x == int_json 1
  > let mixed_neq x = x != int_json 1 && x == Js.Json.number 1.
  > let mixed_distinct x = x == int_json 1 && x == Js.Json.number 1.5
  > let not_mixed x = not (x == int_json 1 && x == Js.Json.number 1.)
  > let not_mixed_neq x = not (x != int_json 1 && x == Js.Json.number 1.)
  > type source
  > external read : source -> float = "value" [@@mel.get]
  > let read_and x = read x = 2.5 && read x = 2.5
  > let read_or x = read x = 2.5 || read x = 2.5
  > let not_read_and x = not (read x = 2.5 && read x = 2.5)
  > let not_read_or x = not (read x = 2.5 || read x = 2.5)
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js');
  > const cases = {
  >   same: x => x === 2.5 && x === 2.5,
  >   different: x => x === 2.5 && x === 3.5,
  >   neq_eq: x => x !== 2.5 && x === 2.5,
  >   eq_neq: x => x === 2.5 && x !== 2.5,
  >   neq_other: x => x !== 2.5 && x === 3.5,
  >   either: x => x === 2.5 || x === 2.5,
  >   zero: x => x === 0 && x === -0,
  >   nan: x => x === NaN && x === NaN,
  >   not_same: x => !(x === 2.5 && x === 2.5),
  >   not_neq_eq: x => !(x !== 2.5 && x === 2.5),
  >   not_either: x => !(x === 2.5 || x === 2.5),
  >   classify: x => x === 2.5 && x === 2.5 ? 1 : 0,
  >   mixed: x => x === 1 && x === 1.0,
  >   mixed_reverse: x => x === 1.0 && x === 1,
  >   mixed_neq: x => x !== 1 && x === 1.0,
  >   mixed_distinct: x => x === 1 && x === 1.5,
  >   not_mixed: x => !(x === 1 && x === 1.0),
  >   not_mixed_neq: x => !(x !== 1 && x === 1.0),
  > };
  > for (const [name, oracle] of Object.entries(cases))
  >   for (const x of [NaN, Infinity, -Infinity, -0, 0, 1, 1.5, 2.5, 3.5])
  >     assert.equal(m[name](x), oracle(x), name + ': ' + x);
  > for (const op of ['and', 'or'])
  >   for (const first of [2.5, 3.5, NaN]) {
  >     const continues = op === 'and' ? first === 2.5 : first !== 2.5;
  >     for (const negated of [false, true]) {
  >       const run = m[(negated ? 'not_read_' : 'read_') + op];
  >       let reads = 0;
  >       const source = {get value() { return ++reads === 1 ? first : 3.5; }};
  >       assert.equal(run(source), (op === 'or' && first === 2.5) !== negated);
  >       assert.equal(reads, continues ? 2 : 1);
  >       reads = 0;
  >       const failure = {};
  >       const throwing = {get value() { if (++reads === 2) throw failure; return first; }};
  >       if (continues) assert.throws(() => run(throwing), e => e === failure);
  >       else assert.equal(run(throwing), (op === 'or') !== negated);
  >       assert.equal(reads, continues ? 2 : 1);
  >     }
  >   }
  > EOF
