Negating ordered float comparisons must preserve unordered (NaN) results.
The initial snapshot records the bug; every mismatch count should become zero.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > let nlt (x : float) y = not (x < y)
  > let nle (x : float) y = not (x <= y)
  > let ngt (x : float) y = not (x > y)
  > let nge (x : float) y = not (x >= y)
  > let double_negation (x : float) y = not (not (x < y))
  > let branch (x : float) y = if x < y then 0 else 1
  > let integer (x : int) y = not (x < y)
  > external js_lt : float -> float -> bool = "#unsafe_lt"
  > let js_nlt x y = not (js_lt x y)
  > external js_le : float -> float -> bool = "#unsafe_le"
  > let js_nle x y = not (js_le x y)
  > external js_gt : float -> float -> bool = "#unsafe_gt"
  > let js_ngt x y = not (js_gt x y)
  > external js_ge : float -> float -> bool = "#unsafe_ge"
  > let js_nge x y = not (js_ge x y)
  > let effects = ref 0
  > let operand (x : float) = incr effects; x
  > let effectful x y = not (operand x < operand y)
  > EOF
  $ melc input.ml -o input.js
  $ node <<'EOF'
  > const assert = require("node:assert/strict");
  > const t = require("./input.js");
  > const comparisons = [
  >   ["nlt", (a, b) => !(a < b)], ["nle", (a, b) => !(a <= b)],
  >   ["ngt", (a, b) => !(a > b)], ["nge", (a, b) => !(a >= b)],
  > ];
  > const values = [NaN, -Infinity, -1, -0, 0, 1, Infinity];
  > for (const [name, expected] of comparisons) {
  >   let ml = 0, ffi = 0;
  >   for (const a of values) for (const b of values) {
  >     ml += t[name](a, b) !== expected(a, b);
  >     ffi += t["js_" + name](a, b) !== expected(a, b);
  >   }
  >   console.log(name, ml, ffi);
  > }
  > for (const a of values) for (const b of values) {
  >   assert.equal(t.double_negation(a, b), a < b);
  >   assert.equal(t.branch(a, b), a < b ? 0 : 1);
  > }
  > assert.equal(t.integer(1, 2), false);
  > assert.equal(t.integer(2, 1), true);
  > console.log("effectful NaN:", t.effectful(NaN, 0));
  > assert.equal(t.effects.contents, 2);
  > EOF
  nlt 13 13
  nle 13 13
  ngt 13 13
  nge 13 13
  effectful NaN: false
