Boolean-returning variant matches should compile to comparisons.
ReScript #6741. Runtime behavior is correct before the optimization.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > type status = Open | Closed
  > let is_open = function Open -> true | Closed -> false
  > let is_closed = function Open -> false | Closed -> true
  > type named = Yes [@mel.as "yes"] | No [@mel.as "no"]
  > let is_yes = function Yes -> true | No -> false
  > let is_no = function Yes -> false | No -> true
  > let poly = function `Open -> true | `Closed -> false
  > type boxed = Left of int | Right of int
  > let is_left = function Left _ -> true | Right _ -> false
  > type nullable = Null [@mel.as null] | Undefined [@mel.as undefined] | Value of int
  > let is_null = function Null -> true | _ -> false
  > let is_undefined = function Undefined -> true | _ -> false
  > external next : unit -> status = "nextStatus"
  > let effectful () = match next () with Open -> true | Closed -> false
  > let effect_inverse () = match next () with Open -> false | Closed -> true
  > external hit : int -> unit = "branchHit"
  > let branch_effect = function
  >   | Open -> hit 1; true
  >   | Closed -> hit 2; false
  > let truthiness x = if x then true else false
  > let float_equality x = if x = 0. then true else false
  > let float_inequality x = if x = 0. then false else true
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require("node:assert/strict");
  > let count = 0, status = 0, hits = [];
  > globalThis.nextStatus = () => { count++; return status; };
  > globalThis.branchHit = n => { hits.push(n); };
  > const m = require("./_build/default/out/input.js");
  > for (const [f, x, expected] of [
  >   [m.is_open, 0, true], [m.is_open, 1, false],
  >   [m.is_closed, 0, false], [m.is_closed, 1, true],
  >   [m.is_yes, "yes", true], [m.is_yes, "no", false],
  >   [m.is_no, "yes", false], [m.is_no, "no", true],
  >   [m.poly, "Open", true], [m.poly, "Closed", false],
  >   [m.is_left, {TAG: 0, _0: 4}, true],
  >   [m.is_left, {TAG: 1, _0: 4}, false],
  >   [m.is_null, null, true], [m.is_null, undefined, false],
  >   [m.is_null, {TAG: 0, _0: 4}, false],
  >   [m.is_undefined, null, false], [m.is_undefined, undefined, true],
  >   [m.is_undefined, {TAG: 0, _0: 4}, false],
  >   [m.truthiness, true, true], [m.truthiness, false, false],
  >   [m.float_equality, NaN, false], [m.float_inequality, NaN, true],
  >   [m.float_equality, -0, true], [m.float_inequality, -0, false]
  > ]) {
  >   assert.equal(f(x), expected);
  > }
  > for (status of [0, 1]) {
  >   count = 0;
  >   assert.equal(m.effectful(), status === 0);
  >   assert.equal(m.effect_inverse(), status !== 0);
  >   assert.equal(count, 2);
  > }
  > hits = [];
  > assert.equal(m.branch_effect(0), true);
  > assert.equal(m.branch_effect(1), false);
  > assert.deepEqual(hits, [1, 2]);
  > const error = {};
  > globalThis.nextStatus = () => { throw error; };
  > assert.throws(() => m.effectful(), e => e === error);
  > const names = ["is_open", "is_closed", "is_yes", "is_no", "is_left", "poly"];
  > console.log("js", "conditional branches:", names.map(name =>
  >   (m[name].toString().match(/\bif\s*\(|\?/g) || []).length).join(", "));
  > EOF
  js conditional branches: 1, 1, 1, 1, 1, 0
