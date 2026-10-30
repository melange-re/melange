An upper-bound default must not expand into a switch jump table ending at INT32_MAX.
Exercise the emitted switch, its fallback, guards and effects.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > external next : unit -> int = "switchNext"
  > external hit : int -> int = "switchHit"
  > external allow : unit -> bool = "switchAllow"
  > let dispatch = function 2147483639 -> 1 | 2147483640 -> 2 | 2147483641 -> 3 | _ -> -1
  > let effectful () =
  >   match next () with
  >   | 2147483639 -> hit 1
  >   | 2147483640 -> hit 2
  >   | 2147483641 -> hit 3
  >   | _ -> hit (-1)
  > let guarded = function
  >   | 2147483639 when allow () -> 1
  >   | 2147483640 -> 2
  >   | 2147483641 -> 3
  >   | _ -> -1
  > let continuation x y =
  >   let result = match x with
  >     | 2147483639 -> y + 1
  >     | 2147483640 -> y + 2
  >     | 2147483641 -> y + 3
  >     | _ -> y - 1
  >   in result + 42
  > EOF
  $ melc -ppx melppx input.ml -o input.js
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const t = require('./input.js');
  > const values = [-2147483648, -1, 0, 2147483638, ...Array.from({length:9}, (_,i) => 2147483639+i)];
  > for (const x of values) {
  >   const expected = x >= 2147483639 && x <= 2147483641 ? x - 2147483638 : -1;
  >   assert.equal(t.dispatch(x), expected);
  >   assert.equal(t.continuation(x, 10), expected + 52);
  >   let reads = 0, writes = 0;
  >   global.switchNext = () => { reads++; return x; };
  >   global.switchHit = y => { writes++; return y; };
  >   assert.equal(t.effectful(), expected);
  >   assert.equal(reads, 1);
  >   assert.equal(writes, 1);
  >   for (const permitted of [false, true]) {
  >     let guards = 0;
  >     global.switchAllow = () => { guards++; return permitted; };
  >     assert.equal(t.guarded(x), x === 2147483639 && !permitted ? -1 : expected);
  >     assert.equal(guards, x === 2147483639 ? 1 : 0);
  >   }
  > }
  > const failure = new Error('branch');
  > global.switchNext = () => 2147483647;
  > global.switchHit = () => { throw failure; };
  > assert.throws(() => t.effectful(), e => e === failure);
  > EOF
