ReScript #6729: unit callbacks passed through mel.uncurry have JavaScript arity zero.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx))
  >  (compile_flags :standard --mel-cross-module-opt)
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ cat > callbacks.ml <<'EOF'
  > external tick : string -> unit = "auditTick"
  > let named () = tick "named"
  > let make () = tick "factory"; fun () -> tick "made"
  > EOF
  $ cat > input.ml <<'EOF'
  > external register : string -> (unit -> unit [@mel.uncurry]) -> unit = "auditRegister"
  > external unary : (int -> int [@mel.uncurry]) -> unit = "auditUnary"
  > external binary : (int -> int -> int [@mel.uncurry]) -> unit = "auditBinary"
  > external unit_first : (unit -> int -> int [@mel.uncurry]) -> unit = "auditUnitFirst"
  > external tick : string -> unit = "auditTick"
  > external capture_unit : unit -> unit = "auditUnit"
  > let setup () =
  >   register "inline" (fun () -> tick "inline");
  >   register "alias" (fun (() as value) -> capture_unit value);
  >   register "typed" (fun (value : unit) -> capture_unit value);
  >   register "named" Callbacks.named;
  >   register "factory" (Callbacks.make ());
  >   unary (fun _ -> 7);
  >   binary (fun a b -> a + b);
  >   unit_first (fun () n -> n)
  > let forward callback = register "forward" callback
  > let wrap callback = register "wrapped" (fun () -> callback (); tick "wrapped")
  > let forward_factory make = register "unknown factory" (make ())
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > let callbacks, events;
  > globalThis.auditRegister = (name, fn) => {
  >   assert.equal(fn.length, 0, name);
  >   callbacks.set(name, fn);
  > };
  > globalThis.auditTick = name => events.push(name);
  > globalThis.auditUnit = value => { assert.equal(value, undefined); events.push("unit"); };
  > globalThis.auditUnary = fn => { assert.equal(fn.length, 1); assert.equal(fn(100), 7); };
  > globalThis.auditBinary = fn => { assert.equal(fn.length, 2); assert.equal(fn(3, 4), 7); };
  > globalThis.auditUnitFirst = fn => { assert.equal(fn.length, 2); assert.equal(fn(undefined, 9), 9); };
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     callbacks = new Map(); events = [];
  >     const m = await import("./_build/default/out/input." + ext);
  >     m.setup();
  >     assert.deepEqual(events, ["factory"]);
  >     for (const name of ["inline", "alias", "typed", "named", "factory"]) {
  >       events = [];
  >       callbacks.get(name)(); callbacks.get(name)();
  >       const event = {alias: "unit", typed: "unit", factory: "made"}[name] || name;
  >       assert.deepEqual(events, [event, event]);
  >     }
  >     const callback = function(value) { assert.equal(value, undefined); events.push("forward"); };
  >     m.forward(callback); m.wrap(callback);
  >     events = [];
  >     callbacks.get("forward")(); callbacks.get("wrapped")();
  >     assert.deepEqual(events, ["forward", "forward", "wrapped"]);
  >     events = [];
  >     m.forward_factory(function(unit) { assert.equal(unit, undefined); events.push("factory"); return callback; });
  >     callbacks.get("unknown factory")(); callbacks.get("unknown factory")();
  >     assert.deepEqual(events, ["factory", "forward", "forward"]);
  >     const error = new Error("callback");
  >     m.forward(() => { throw error; });
  >     assert.throws(() => callbacks.get("forward")(), e => e === error);
  >     console.log(ext + ": ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js: ok
  mjs: ok
