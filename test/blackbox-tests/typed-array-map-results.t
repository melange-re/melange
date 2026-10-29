ReScript #9112: typed-array mapping preserves numeric elements and array kind.
The current bindings wrongly accept string-returning callbacks for map/mapi.
copyWithin already returns the receiver's type, with or without optional bounds.

  $ . ./setup.sh
  $ cat > kinds.cjs <<'EOF'
  > module.exports = [
  >   ['Int8Array', '1', 'x + 1', 'x + i'],
  >   ['Uint8Array', '1', 'x + 1', 'x + i'],
  >   ['Uint8ClampedArray', '1', 'x + 1', 'x + i'],
  >   ['Int16Array', '1', 'x + 1', 'x + i'],
  >   ['Uint16Array', '1', 'x + 1', 'x + i'],
  >   ['Int32Array', '1l', 'Int32.add x 1l', 'Int32.add x (Int32.of_int i)'],
  >   ['Uint32Array', '1', 'x + 1', 'x + i'],
  >   ['Float32Array', '1.', 'x +. 1.', 'x +. float_of_int i'],
  >   ['Float64Array', '1.', 'x +. 1.', 'x +. float_of_int i'],
  > ];
  > EOF
  $ cat > negative.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > const fs = require('node:fs');
  > const {spawnSync} = require('node:child_process');
  > fs.mkdirSync('negative');
  > let accepted = 0, rejected = 0;
  > for (const [kind, one] of require('./kinds.cjs')) {
  >   for (const method of ['map', 'mapi']) {
  >     const name = 'negative/' + kind.toLowerCase() + '_' + method;
  >     const source = `module A = Js.Typed_array.${kind}\nlet bad : A.t = A.${method} ~f:(fun ${method === 'map' ? '_' : '_ _'} -> "not a number") (A.make [|${one}|])\n`;
  >     fs.writeFileSync(name + '.ml', source);
  >     const r = spawnSync('melc', ['-ppx', 'melppx', '-o', name + '.js', name + '.ml'], {encoding:'utf8'});
  >     if (r.status === 0) {
  >       accepted++;
  >       const {bad} = require('./' + name + '.js');
  >       assert.ok(bad instanceof globalThis[kind]);
  >       assert.equal(bad[0], kind.startsWith('Float') ? NaN : 0);
  >     } else {
  >       assert.equal(r.status, 2, r.stderr);
  >       assert.match(r.stderr, /has type.*string/s);
  >       assert.match(r.stderr, /expected.*(?:int|float|elt)/s);
  >       rejected++;
  >     }
  >   }
  > }
  > console.log('string callbacks accepted:', accepted, 'rejected:', rejected);
  > EOF
  $ node negative.cjs
  string callbacks accepted: 18 rejected: 0

Check supported callbacks, indexed effects, identity, bounds, and numeric conversion.

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
  $ cat > generate.cjs <<'EOF'
  > const fs = require('node:fs');
  > const lines = ['external note : int -> unit = "auditIndex"'];
  > require('./kinds.cjs').forEach(([kind, one, add, addi], i) => {
  >   const a = 'Js.Typed_array.' + kind;
  >   lines.push(`let copy${i} (x : ${a}.t) : ${a}.t = ${a}.copyWithin ~to_:1 ~start:2 ~end_:4 x`);
  >   lines.push(`let copy_all${i} (x : ${a}.t) : ${a}.t = ${a}.copyWithin ~to_:1 x`);
  >   lines.push(`let map${i} (v : ${a}.t) : ${a}.t = ${a}.map ~f:(fun x -> ${add}) v`);
  >   lines.push(`let mapi${i} (v : ${a}.t) : ${a}.t = ${a}.mapi ~f:(fun x i -> note i; ${addi}) v`);
  > });
  > lines.push('let wrap x = Js.Typed_array.Int8Array.map ~f:(fun _ -> 130) x');
  > lines.push('let clamp x = Js.Typed_array.Uint8ClampedArray.map ~f:(fun _ -> 300) x');
  > lines.push('let fractional x = Js.Typed_array.Float64Array.map ~f:(fun x -> x +. 0.25) x');
  > fs.writeFileSync('input.ml', lines.join('\n') + '\n');
  > EOF
  $ node generate.cjs
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > (async () => {
  >   for (const ext of ['js', 'mjs']) {
  >     const m = await import('./_build/default/out/input.' + ext);
  >     require('./kinds.cjs').forEach(([kind], i) => {
  >       const Constructor = globalThis[kind];
  >       for (const [name, expected] of [['copy', [1,3,4,4]], ['copy_all', [1,1,2,3]]]) {
  >         const input = new Constructor([1,2,3,4]);
  >         assert.equal(m[name + i](input), input);
  >         assert.deepEqual(Array.from(input), expected);
  >       }
  >       const input = new Constructor([1,2,3]);
  >       for (const [name, expected] of [['map', [2,3,4]], ['mapi', [1,3,5]]]) {
  >         const seen = [];
  >         globalThis.auditIndex = n => { seen.push(n); };
  >         const result = m[name + i](input);
  >         assert.ok(result instanceof Constructor);
  >         assert.notEqual(result, input);
  >         assert.deepEqual(Array.from(result), expected);
  >         assert.deepEqual(Array.from(input), [1,2,3]);
  >         assert.deepEqual(seen, name === 'mapi' ? [0,1,2] : []);
  >       }
  >       const failure = {};
  >       const seen = [];
  >       globalThis.auditIndex = n => { seen.push(n); if (n === 1) throw failure; };
  >       assert.throws(() => m['mapi' + i](input), e => e === failure);
  >       assert.deepEqual(seen, [0,1]);
  >       assert.deepEqual(Array.from(input), [1,2,3]);
  >     });
  >     assert.equal(m.wrap(new Int8Array([1]))[0], -126);
  >     assert.equal(m.clamp(new Uint8ClampedArray([1]))[0], 255);
  >     assert.equal(m.fractional(new Float64Array([1]))[0], 1.25);
  >     console.log(ext, 'nine array kinds, copy identity, map values and effects: ok');
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js nine array kinds, copy identity, map values and effects: ok
  mjs nine array kinds, copy identity, map values and effects: ok
