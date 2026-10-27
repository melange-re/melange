ReScript #6739: constant float-to-int conversion must agree with runtime ToInt32.
The baseline uses a host conversion outside its defined signed-int32 range.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > let values = [|22130921800000.; -22130921800000.; 2147483648.; -2147483649.; 4294967295.; 4294967296.; -4294967297.; 1e100; -1e100; 1e400; -1e400|]
  > let constants = [|int_of_float 22130921800000.; int_of_float (-22130921800000.); int_of_float 2147483648.; int_of_float (-2147483649.); int_of_float 4294967295.; int_of_float 4294967296.; int_of_float (-4294967297.); int_of_float 1e100; int_of_float (-1e100); int_of_float 1e400; int_of_float (-1e400)|]
  > let safe_values = [|0.; -0.; 1.9; -1.9; 2147483647.; -2147483648.; 2147483647.75; -2147483648.75|]
  > let safe_constants = [|int_of_float 0.; int_of_float (-0.); int_of_float 1.9; int_of_float (-1.9); int_of_float 2147483647.; int_of_float (-2147483648.); int_of_float 2147483647.75; int_of_float (-2147483648.75)|]
  > let runtime x = int_of_float (Sys.opaque_identity x)
  > let arithmetic x = int_of_float (x -. 0.)
  > let int32 x = Int32.to_int (Int32.of_float (Sys.opaque_identity x))
  > let int32_constant = Int32.to_int (Int32.of_float 22130921800000.)
  > external note : float -> float = "auditFloat"
  > let convert_effectful () = int_of_float (note 22130921800000.)
  > EOF
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (modules input)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx))
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const m = await import("./_build/default/out/input." + ext);
  >     const expected = m.values.map(x => x | 0);
  >     assert.deepEqual(m.safe_constants, m.safe_values.map(x => x | 0));
  >     for (const x of [...m.values, ...m.safe_values, NaN, Infinity, -Infinity, Number.MIN_VALUE, -Number.MIN_VALUE]) {
  >       for (const convert of [m.runtime, m.arithmetic, m.int32]) assert.equal(convert(x), x | 0);
  >     }
  >     console.log(ext, "out-of-range constants agree:", m.constants.every((x,i) => x === expected[i]));
  >     let count = 0;
  >     globalThis.auditFloat = x => {count++; return x;};
  >     assert.equal(m.convert_effectful(), expected[0]);
  >     assert.equal(count, 1);
  >     const failure = new Error("conversion input");
  >     globalThis.auditFloat = () => {throw failure;};
  >     assert.throws(() => m.convert_effectful(), e => e === failure);
  >     console.log(ext, "runtime, in-range constants and effects: ok");
  >   }
  > })().catch(e => {console.error(e);process.exitCode=1;});
  > EOF
  $ node check.cjs
  js out-of-range constants agree: false
  js runtime, in-range constants and effects: ok
  mjs out-of-range constants agree: false
  mjs runtime, in-range constants and effects: ok
