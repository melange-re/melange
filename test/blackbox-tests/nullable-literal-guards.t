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
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx))
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const path = "./_build/default/out/input." + ext;
  >     const m = await import(path);
  >     const values = [null, undefined, "hello", "", 123, 0, -0, NaN, Infinity, false, true, {}, [], Symbol(), 123n];
  >     for (const [name, literal] of [["is_null", null], ["is_undefined", undefined], ["is_hello", "hello"], ["is_number", 123], ["is_true", true]]) {
  >       assert.deepEqual(values.map(m[name]), values.map(x => x === literal));
  >     }
  >     assert.deepEqual(values.map(m.strict_nullish), values.map(x => x === null || x === undefined));
  >     let reads = 0;
  >     globalThis.auditNullable = () => { reads++; return null; };
  >     assert.equal(m.captured(), true); assert.equal(reads, 1);
  >     for (const run of [m.repeated, () => m.getter({get value() { return globalThis.auditNullable(); }})]) {
  >       reads = 0;
  >       globalThis.auditNullable = () => { reads++; return reads === 1 ? null : "hello"; };
  >       assert.equal(run(), false); assert.equal(reads, 2);
  >       reads = 0;
  >       globalThis.auditNullable = () => { reads++; return "hello"; };
  >       assert.equal(run(), false); assert.equal(reads, 1);
  >       reads = 0;
  >       const failure = new Error("second read");
  >       globalThis.auditNullable = () => { if (++reads === 2) throw failure; return null; };
  >       assert.throws(run, e => e === failure); assert.equal(reads, 2);
  >     }
  >     const source = require("node:fs").readFileSync(path, "utf8");
  >     for (const name of ["is_null", "is_undefined", "is_hello", "is_number", "is_true"]) {
  >       const body = source.slice(source.indexOf("function " + name + "("));
  >       console.log(ext, name, "nullable guard:", body.slice(0, body.indexOf("\n}")).includes(" == null"));
  >     }
  >     console.log(ext, "strict equality and effects: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js is_null nullable guard: true
  js is_undefined nullable guard: true
  js is_hello nullable guard: true
  js is_number nullable guard: true
  js is_true nullable guard: true
  js strict equality and effects: ok
  mjs is_null nullable guard: true
  mjs is_undefined nullable guard: true
  mjs is_hello nullable guard: true
  mjs is_number nullable guard: true
  mjs is_true nullable guard: true
  mjs strict equality and effects: ok
