ReScript #6459: unit call syntax erases its argument; explicit undefined values retain theirs.
Requires the explicit-argument fixes in #2097; optional-argument omission is covered separately.

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
  $ cat > input.ml <<'EOF'
  > external count : unit -> int = "auditCount"
  > external required : 'a Js.undefined -> int = "auditCount"
  > external option : int option -> int = "auditCount"
  > external nested : int option option -> int = "auditCount"
  > external generic : 'a -> int = "auditCount"
  > external labelled : value:unit -> int = "auditCount"
  > external tick : unit -> unit = "auditEffect"
  > external send_unit : 'a -> unit -> int = "count" [@@mel.send]
  > external send_value : 'a -> 'b Js.undefined -> int = "count" [@@mel.send]
  > external new_unit : unit -> < count : int > Js.t = "AuditCtor" [@@mel.new]
  > external new_value : 'a Js.undefined -> < count : int > Js.t = "AuditCtor" [@@mel.new]
  > let empty () = count ()
  > let effectful () = count (tick ())
  > let explicit_undefined () = required Js.undefined
  > let none () = option None
  > let nested_none () = nested (Some None)
  > let explicit_unit () = generic ()
  > let labelled_unit () = labelled ~value:()
  > let forward value = generic value
  > let method_empty receiver = send_unit receiver ()
  > let method_undefined receiver = send_value receiver Js.undefined
  > let construct_empty () = new_unit ()
  > let construct_undefined () = new_value Js.undefined
  > type callback = (unit -> int [@u])
  > external callback : callback = "auditCount"
  > let uncurried_alias () = callback () [@u]
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > let effects;
  > globalThis.auditCount = function() { return arguments.length; };
  > globalThis.auditEffect = () => { effects++; };
  > globalThis.AuditCtor = function() { this.count = arguments.length; };
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     effects = 0;
  >     const m = await import("./_build/default/out/input." + ext);
  >     for (const name of ["empty", "effectful", "uncurried_alias"]) assert.equal(m[name](), 0, name);
  >     assert.equal(effects, 1);
  >     for (const name of ["explicit_undefined", "none", "nested_none", "explicit_unit", "labelled_unit"])
  >       assert.equal(m[name](), 1, name);
  >     assert.equal(m.forward(undefined), 1);
  >     const receiver = {count: function() { assert.equal(this, receiver); return arguments.length; }};
  >     assert.equal(m.method_empty(receiver), 0);
  >     assert.equal(m.method_undefined(receiver), 1);
  >     assert.equal(m.construct_empty().count, 0);
  >     assert.equal(m.construct_undefined().count, 1);
  >     console.log(ext + ": ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js: ok
  mjs: ok
