Float arithmetic on converted int32 constants must not use wrapping integer folds.
ReScript #6422. The observations below record the unfixed compiler's results.

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
  > external identity_float : int -> float = "%identity"
  > let converted_low = float_of_int (-2147483648) -. float_of_int 1000000000
  > let converted_high = float_of_int 2147483647 +. float_of_int 1000000000
  > let identity_low = identity_float (-2147483648) -. identity_float 1000000000
  > let identity_high = identity_float 2147483647 +. identity_float 1000000000
  > let literal_low = -2147483648. -. 1000000000.
  > let literal_high = 2147483647. +. 1000000000.
  > let dynamic_min x = x +. float_of_int (-2147483648)
  > let rounded x = (x +. float_of_int 1) +. float_of_int 1
  > let combined x = (x +. float_of_int 2147483647) +. float_of_int 1000000000
  > let signed_zero x = x +. float_of_int 0
  > let wrapped_add = 2147483647 + 1000000000
  > let wrapped_sub = -2147483648 - 1000000000
  > let integer_add x = (x + 2147483647) + 1000000000
  > let integer_min x = x + -2147483648
  > external read : int -> int = "readBoundary"
  > let effects () =
  >   let left = read 1 in
  >   let right = read 2 in
  >   float_of_int left +. float_of_int right
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > let calls = [];
  > globalThis.readBoundary = n => {
  >   calls.push(n);
  >   return n === 1 ? 2147483647 : 1000000000;
  > };
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const m = await import("./_build/default/out/input." + ext);
  >     assert.equal(m.literal_low, -3147483648);
  >     assert.equal(m.literal_high, 3147483647);
  >     assert.equal(m.wrapped_add, -1147483649);
  >     assert.equal(m.wrapped_sub, 1147483648);
  >     assert.equal(m.integer_add(1), -1147483648);
  >     assert.equal(m.integer_min(5), -2147483643);
  >     assert.equal(Object.is(m.signed_zero(-0), 0), true);
  >     calls = [];
  >     assert.equal(m.effects(), 3147483647);
  >     assert.deepEqual(calls, [1, 2]);
  >     const error = {};
  >     globalThis.readBoundary = () => { throw error; };
  >     assert.throws(() => m.effects(), e => e === error);
  >     globalThis.readBoundary = n => {
  >       calls.push(n);
  >       return n === 1 ? 2147483647 : 1000000000;
  >     };
  >     console.log(ext, JSON.stringify({
  >       low: m.converted_low, high: m.converted_high,
  >       identityLow: m.identity_low, identityHigh: m.identity_high,
  >       dynamicMin: m.dynamic_min(5),
  >       rounded: m.rounded(2 ** 53), combined: m.combined(0)
  >     }));
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js {"low":1147483648,"high":-1147483649,"identityLow":1147483648,"identityHigh":-1147483649,"dynamicMin":2147483653,"rounded":9007199254740994,"combined":-1147483649}
  mjs {"low":1147483648,"high":-1147483649,"identityLow":1147483648,"identityHigh":-1147483649,"dynamicMin":2147483653,"rounded":9007199254740994,"combined":-1147483649}
