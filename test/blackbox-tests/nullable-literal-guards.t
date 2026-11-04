ReScript #7142: nullable guards around strict literal comparisons are redundant.
Keep the behavior of strict equality, repeated getter reads, and effects.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > let is_null x = match Js.Nullable.toOption x with None -> x == Js.Nullable.null | Some _ -> false
  > let is_undefined x = match Js.Nullable.toOption x with None -> x == Js.Nullable.undefined | Some _ -> false
  > let is_hello x = match Js.Nullable.toOption x with None -> false | Some s -> s = "hello"
  > let is_number x = match Js.Nullable.toOption x with None -> false | Some n -> n = 123
  > let is_true x = match Js.Nullable.toOption x with None -> false | Some b -> b == true
  > external get : unit -> string Js.Nullable.t = "auditNullable"
  > type holder
  > external value : holder -> string Js.Nullable.t = "value" [@@mel.get]
  > let captured () = let x = get () in is_null x
  > let repeated () = if Js.Nullable.isNullable (get ()) then get () == Js.Nullable.null else false
  > let getter obj = if Js.Nullable.isNullable (value obj) then value obj == Js.Nullable.null else false
  > let strict_nullish x = x == Js.Nullable.null || x == Js.Nullable.undefined
  > EOF
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require("node:assert/strict");
  > const path = "./_build/default/out/input.js";
  > const m = require(path);
  > const values = [null, undefined, "hello", "", 123, 0, -0, NaN, Infinity, false, true, {}, [], Symbol(), 123n];
  > for (const [name, literal] of [["is_null", null], ["is_undefined", undefined], ["is_hello", "hello"], ["is_number", 123], ["is_true", true]]) {
  >   assert.deepEqual(values.map(m[name]), values.map(x => x === literal));
  > }
  > assert.deepEqual(values.map(m.strict_nullish), values.map(x => x === null || x === undefined));
  > let reads = 0;
  > globalThis.auditNullable = () => { reads++; return null; };
  > assert.equal(m.captured(), true); assert.equal(reads, 1);
  > for (const run of [m.repeated, () => m.getter({get value() { return globalThis.auditNullable(); }})]) {
  >   reads = 0;
  >   globalThis.auditNullable = () => { reads++; return reads === 1 ? null : "hello"; };
  >   assert.equal(run(), false); assert.equal(reads, 2);
  >   reads = 0;
  >   globalThis.auditNullable = () => { reads++; return "hello"; };
  >   assert.equal(run(), false); assert.equal(reads, 1);
  >   reads = 0;
  >   const failure = new Error("second read");
  >   globalThis.auditNullable = () => { if (++reads === 2) throw failure; return null; };
  >   assert.throws(run, e => e === failure); assert.equal(reads, 2);
  > }
  > for (const name of ["is_null", "is_undefined", "is_hello", "is_number", "is_true"]) {
  >   console.log(name, "nullable guard:", m[name].toString().includes(" == null"));
  > }
  > EOF
  is_null nullable guard: true
  is_undefined nullable guard: true
  is_hello nullable guard: true
  is_number nullable guard: true
  is_true nullable guard: true
