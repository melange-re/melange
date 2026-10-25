Integer matching uses the signed 32-bit target range and normalized constants.
The initial snapshot records wrong branches at the upper limit and wrapped aliases.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > let high = function 2147483645 | 2147483646 | 2147483647 -> true | _ -> false
  > let low = function -2147483648 | -2147483647 | -2147483646 -> true | _ -> false
  > let distinct = function 2147483645 -> 1 | 2147483646 -> 2 | 2147483647 -> 3 | _ -> 0
  > type record = { value : int }
  > let record r = match r.value with 2147483645 | 2147483646 | 2147483647 -> true | _ -> false
  > let tuple (a,b) = match a,b with (2147483645 | 2147483646 | 2147483647), true -> true | _ -> false
  > type item = I of int
  > let variant = function I (2147483645 | 2147483646 | 2147483647) -> true | _ -> false
  > let array = function [|2147483645 | 2147483646 | 2147483647|] -> true | _ -> false
  > let int32_high = function 2147483645l | 2147483646l | 2147483647l -> true | _ -> false
  > let wrapped_hex b = function -0xFFFF_FFFF when b -> 1 | 1 -> 2 | _ -> 0
  > let wrapped_octal b = function -0o37777777777 when b -> 1 | 1 -> 2 | _ -> 0
  > let wrapped_binary b = function -0b11111111111111111111111111111111 when b -> 1 | 1 -> 2 | _ -> 0
  > let wrapped_negative = function 0xFFFF_FFFF -> 1 | -1 -> 2 | _ -> 0
  > let literals = 0xFFFF_FFFF, -0xFFFF_FFFF, 4294967296
  > EOF
  $ melc -w -11 input.ml -o input.js
  File "input.ml", line 15, characters 42-52:
  15 | let literals = 0xFFFF_FFFF, -0xFFFF_FFFF, 4294967296
                                                 ^^^^^^^^^^
  Warning 107 [melange-literal-int-overflow]: Integer literal exceeds the range of representable integers of type int
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > const t = require('./input.js');
  > const high = [2147483644, 2147483645, 2147483646, 2147483647];
  > for (const [name, wrap] of [['high', x=>x], ['record', x=>({value:x})], ['tuple', x=>[x,true]], ['variant', x=>({_0:x})], ['array', x=>[x]]])
  >   console.log(name, JSON.stringify(high.map(x=>t[name](wrap(x)))));
  > console.log('distinct', JSON.stringify(high.map(t.distinct)));
  > for (const name of ['wrapped_hex','wrapped_octal','wrapped_binary'])
  >   console.log(name, t[name](false,1), t[name](true,1));
  > console.log('wrapped_negative', t.wrapped_negative(-1));
  > for (const x of [-2147483648, -2147483647, -2147483646]) assert.equal(t.low(x),true);
  > assert.equal(t.low(-2147483645),false);
  > for (const x of high) assert.equal(t.int32_high(x),x>=2147483645);
  > assert.deepEqual(t.literals,[-1,1,0]);
  > console.log('lower limit, int32 and emitted literal controls: ok');
  > EOF
  $ node check.cjs
  high [false,false,false,false]
  record [false,false,false,false]
  tuple [false,false,false,false]
  variant [false,false,false,false]
  array [false,false,false,false]
  distinct [0,0,0,0]
  wrapped_hex 0 1
  wrapped_octal 0 1
  wrapped_binary 0 1
  wrapped_negative 2
  lower limit, int32 and emitted literal controls: ok

Normalization must also make duplicate-case diagnostics consistent.

  $ cat > duplicate.ml <<'EOF'
  > let f = function 0xFFFF_FFFF -> 1 | -1 -> 2 | _ -> 0
  > EOF
  $ melc -w +11 duplicate.ml -o duplicate.js
