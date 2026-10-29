ReScript #9114: conservative expression equality must not imply unequal literals.
Melange retains these comparisons; check numeric equality and observable reads.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.13)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx))
  >  (module_systems (commonjs js) (es6 mjs)))
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
  > external int_json : int -> Js.Json.t = "%identity"
  > let mixed x = x == int_json 1 && x == Js.Json.number 1.
  > let mixed_reverse x = x == Js.Json.number 1. && x == int_json 1
  > let mixed_neq x = x != int_json 1 && x == Js.Json.number 1.
  > let mixed_distinct x = x == int_json 1 && x == Js.Json.number 1.5
  > type source
  > external read : source -> float = "value" [@@mel.get]
  > let read_and x = read x = 2.5 && read x = 2.5
  > let read_or x = read x = 2.5 || read x = 2.5
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > (async () => {
  >   for (const ext of ['js', 'mjs']) {
  >     const m = await import('./_build/default/out/input.' + ext);
  >     const cases = {
  >       same: x => x === 2.5 && x === 2.5,
  >       different: x => x === 2.5 && x === 3.5,
  >       neq_eq: x => x !== 2.5 && x === 2.5,
  >       eq_neq: x => x === 2.5 && x !== 2.5,
  >       neq_other: x => x !== 2.5 && x === 3.5,
  >       either: x => x === 2.5 || x === 2.5,
  >       zero: x => x === 0 && x === -0,
  >       nan: x => x === NaN && x === NaN,
  >       mixed: x => x === 1 && x === 1.0,
  >       mixed_reverse: x => x === 1.0 && x === 1,
  >       mixed_neq: x => x !== 1 && x === 1.0,
  >       mixed_distinct: x => x === 1 && x === 1.5,
  >     };
  >     for (const [name, oracle] of Object.entries(cases))
  >       for (const x of [NaN, Infinity, -Infinity, -0, 0, 1, 1.5, 2.5, 3.5])
  >         assert.equal(m[name](x), oracle(x), name + ': ' + x);
  >     for (const op of ['and', 'or'])
  >       for (const first of [2.5, 3.5, NaN]) {
  >         let reads = 0;
  >         const source = {get value() { return ++reads === 1 ? first : 3.5; }};
  >         assert.equal(m['read_' + op](source), op === 'or' && first === 2.5);
  >         const continues = op === 'and' ? first === 2.5 : first !== 2.5;
  >         assert.equal(reads, continues ? 2 : 1);
  >         reads = 0;
  >         const failure = {};
  >         const throwing = {get value() { if (++reads === 2) throw failure; return first; }};
  >         if (continues) assert.throws(() => m['read_' + op](throwing), e => e === failure);
  >         else assert.equal(m['read_' + op](throwing), op === 'or');
  >         assert.equal(reads, continues ? 2 : 1);
  >       }
  >     console.log(ext, 'literal conjunctions, IEEE values, and reads: ok');
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js literal conjunctions, IEEE values, and reads: ok
  mjs literal conjunctions, IEEE values, and reads: ok
