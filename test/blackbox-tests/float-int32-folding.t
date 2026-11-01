Float arithmetic must preserve int32 boundaries and IEEE rounding.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.13)' '(using melange 0.1)' > dune-project
  $ echo '(melange.emit (target out) (libraries melange.js) (preprocess (pps melange.ppx)))' > dune
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
  $ node <<'EOF'
  > const m = require('./_build/default/out/input.js');
  > for (const prefix of ['converted', 'identity', 'literal'])
  >   console.log(prefix, m[prefix + '_low'], m[prefix + '_high']);
  > console.log('dynamic', m.dynamic_min(5), m.rounded(2 ** 53), m.combined(0));
  > console.log('integer', m.wrapped_add, m.wrapped_sub, m.integer_add(1), m.integer_min(5));
  > console.log('zero', Object.is(m.signed_zero(-0), 0));
  > const calls = [];
  > globalThis.readBoundary = n => { calls.push(n); return n === 1 ? 2147483647 : 1000000000; };
  > console.log('effects', m.effects(), calls);
  > const error = new Error('boundary');
  > globalThis.readBoundary = () => { throw error; };
  > try { m.effects(); } catch (e) { console.log('throws', e === error); }
  > EOF
  converted 1147483648 -1147483649
  identity 1147483648 -1147483649
  literal -3147483648 3147483647
  dynamic 2147483653 9007199254740994 -1147483649
  integer -1147483649 1147483648 -1147483648 -2147483643
  zero true
  effects 3147483647 [ 1, 2 ]
  throws true
