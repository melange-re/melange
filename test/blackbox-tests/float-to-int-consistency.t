ReScript #6739: constant float-to-int conversion must agree with runtime ToInt32.

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
  $ melc -ppx melppx input.ml -o input.js
  $ node <<'JS'
  > const m = require('./input.js');
  > const expected = m.values.map(x => x | 0);
  > console.log('constants', m.constants.every((x,i) => x === expected[i]), 'int32', m.int32_constant === expected[0]);
  > console.log('in range', m.safe_constants.every((x,i) => x === (m.safe_values[i] | 0)));
  > const values = [...m.values, ...m.safe_values, NaN, Infinity, -Infinity, Number.MIN_VALUE, -Number.MIN_VALUE];
  > console.log('runtime', [m.runtime, m.arithmetic, m.int32].map(convert => values.every(x => convert(x) === (x | 0))));
  > let count = 0;
  > global.auditFloat = x => { count++; return x; };
  > console.log('effect', m.convert_effectful(), 'calls', count);
  > const failure = new Error('conversion input');
  > global.auditFloat = () => { throw failure; };
  > try { m.convert_effectful(); } catch (error) { console.log('throws', error === failure); }
  > JS
  constants true int32 true
  in range true
  runtime [ true, true, true ]
  effect -1044676288 calls 1
  throws true
