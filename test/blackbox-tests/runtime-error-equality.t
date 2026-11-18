ReScript #6937: distinguish native JavaScript values while retaining OCaml equality.
The first cases characterize current incorrect results.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > let equal a b = a = b
  > let hash x = Hashtbl.hash x
  > exception Payload of int
  > let exception_value x = Payload x
  > let caught_exception x = try raise (Payload x) with exn -> exn
  > let object_value x = object method value = x end
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require("node:assert/strict");
  > const m = require("./_build/default/out/input.js");
  > const equal = m.equal;
  > const bad = [
  >   ["error messages", new Error("a"), new Error("b")],
  >   ["error causes", new Error("a", {cause: 1}), new Error("a", {cause: 2})],
  >   ["error kinds", new Error("a"), new TypeError("a")],
  >   ["error/object", new Error("a"), {}],
  >   ["symbols", Symbol("a"), Symbol("b")],
  >   ["symbol/string", Symbol(""), ""],
  >   ["symbol/object", Symbol("a"), {}],
  >   ["date/object", new Date(0), {}],
  >   ["array/object", [], {length: 0}]
  > ];
  > for (const [name, a, b] of bad)
  >   console.log("js", name, equal(a, b), equal(b, a));
  > for (const [a, b] of [
  >   [new Error("same"), new Error("same")],
  >   [new Error("same", {cause: {a: [1]}}), new Error("same", {cause: {a: [1]}})],
  >   [new Date(1), new Date(1)], [[1, {a: 2}], [1, {a: 2}]],
  >   [m.exception_value(7), m.caught_exception(7)],
  >   [m.caught_exception(7), m.caught_exception(7)]
  > ]) {
  >   assert.equal(equal(a, b), true);
  >   assert.equal(equal(b, a), true);
  >   assert.equal(m.hash(a), m.hash(b));
  > }
  > assert.equal(equal(new Date(1), new Date(2)), false);
  > assert.equal(equal(m.exception_value(1), m.caught_exception(2)), false);
  > const a = m.object_value(1), b = m.object_value(1);
  > assert.equal(equal(a, a), true);
  > assert.equal(equal(a, b), false);
  > const fn = () => 1;
  > assert.equal(equal(fn, fn), true);
  > assert.throws(() => equal(fn, () => 1),
  >   e => e.MEL_EXN_ID === "Invalid_argument" && e._1 === "equal: functional value");
  > assert.throws(() => equal({TAG: 251}, {TAG: 251}),
  >   e => e.MEL_EXN_ID === "Invalid_argument" && e._1 === "equal: abstract value");
  > const extraA = Object.assign(new Error("a"), {extra: 1});
  > const extraB = Object.assign(new Error("a"), {extra: 2});
  > assert.equal(equal(extraA, extraB), false);
  > const symbol = Symbol("same");
  > assert.equal(equal(symbol, symbol), true);
  > EOF
  js error messages true true
  js error causes true true
  js error kinds true true
  js error/object true true
  js symbols true true
  js symbol/string true false
  js symbol/object true true
  js date/object true true
  js array/object true true
