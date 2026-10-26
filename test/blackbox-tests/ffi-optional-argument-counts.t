ReScript #6653: cover ffi optional argument counts.
Presence is preserved through argument conversion and runtime omission.

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
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ cat > input.ml <<'EOF'
  > external count : ?x:int -> ?y:int -> unit -> int = "auditCount"
  > external opt_undefined : ?x:int Js.undefined -> unit -> int = "auditCount"
  > external opt_unit : ?x:unit -> unit -> int = "auditCount"
  > external required_undefined : int Js.undefined -> int = "auditCount"
  > external ignored_before : (int [@mel.ignore]) -> ?x:int -> unit -> int = "auditCount"
  > external ignored_after : ?x:int -> (int [@mel.ignore]) -> unit -> int = "auditCount"
  > external unit_before : unit -> ?x:int -> unit -> int = "auditCount"
  > external tick : int -> int = "auditTick"
  > external construct : ?x:int -> unit -> < count : int > Js.t = "AuditCtor" [@@mel.new]
  > external send : 'a -> ?x:int -> unit -> int = "count" [@@mel.send]
  > external capture : ?x:'a -> ?y:'b -> unit -> 'c array = "auditCapture"
  > external constant : (_ [@mel.as 7]) -> ?x:int -> unit -> int = "auditCount"
  > external variant : ([ `Tag of int ] [@mel.string]) -> ?x:int -> unit -> int = "auditCount"
  > external opt_variant : ?x:[ `A [@mel.as "alpha"] | `B ] -> unit -> string array = "auditCapture"
  > external get_variant : unit -> [ `A | `B ] option = "auditVariant"
  > external get_option : unit -> int option = "auditOption"
  > external get_unit : unit -> unit option = "auditUnit"
  > let effectful_unit () = opt_unit ?x:(get_unit ()) ()
  > external set_optional : 'a -> ?x:int -> unit = "value" [@@mel.set]
  > let assign_optional receiver x = set_optional receiver ?x
  > let dynamic_unit x = opt_unit ?x ()
  > let dynamic_undefined x = opt_undefined ?x ()
  > let dynamic_capture x y = capture ?x ?y ()
  > let dynamic_construct x = construct ?x ()
  > let dynamic_send receiver x = send receiver ?x ()
  > let effectful_send receiver = send receiver ?x:(get_option ()) ()
  > let dynamic_variant x = opt_variant ?x ()
  > let effectful_variant () = opt_variant ?x:(get_variant ()) ()
  > let inserted_constant () = constant ()
  > let expanded_variant () = variant (`Tag 7) ()
  > let nested_none () = capture ~x:None ()
  > external polymorphic : 'a -> int = "auditCount"
  > external variadic_unit : unit array -> int = "auditCount" [@@mel.variadic]
  > let generic_unit () = polymorphic ()
  > let literal_unit_array () = variadic_unit [|()|]
  > let dynamic_unit_array values = variadic_unit values
  > let omitted () = count ()
  > let none () = count ?x:None ?y:None ()
  > let some () = count ~x:1 ()
  > let interior () = count ~y:2 ()
  > let dynamic x = count ?x ()
  > let explicit_undefined () = opt_undefined ~x:Js.undefined ()
  > let explicit_unit () = opt_unit ~x:() ()
  > let required () = required_undefined Js.undefined
  > let erased_before () = ignored_before 7 ()
  > let erased_after () = ignored_after 7 ()
  > let erased_effect () = ignored_before (tick 7) ()
  > let erased_unit () = unit_before () ()
  > let new_omitted () = construct ()
  > let send_omitted receiver = send receiver ()
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > let hits = [];
  > globalThis.auditCapture = function() { return Array.from(arguments); };
  > globalThis.auditUnit = () => { hits.push("unit"); return {MEL_PRIVATE_NESTED_SOME_NONE:0}; };
  > globalThis.auditVariant = () => { hits.push("variant"); return "A"; };
  > globalThis.auditOption = () => { hits.push("option"); return undefined; };
  > globalThis.auditCount = function() { return arguments.length; };
  > globalThis.auditTick = n => { hits.push(n); return n; };
  > globalThis.AuditCtor = function() { this.count = arguments.length; };
  > 
  > const characterized = new Set(["explicit_undefined", "explicit_unit", "erased_before", "erased_after", "erased_unit", "dynamic None", "ignored effect count"]);
  > function check(group, name, run, expected) {
  >   const actual = run();
  >   if (characterized.has(name)) console.log(group, name, JSON.stringify(actual));
  >   else assert.deepStrictEqual(actual, expected, name);
  > }
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const m = await import("./_build/default/out/input." + ext);
  >       for (const [name, expected] of [["omitted",0],["none",0],["some",1],["interior",2],["explicit_undefined",1],["explicit_unit",1],["required",1],["erased_before",0],["erased_after",0],["erased_unit",0]])
  >         check(`6653/${ext}`, name, () => m[name](), expected);
  >       check(`6653/${ext}`, "dynamic None", () => m.dynamic(undefined), 0);
  >       check(`6653/${ext}`, "dynamic Some", () => m.dynamic(7), 1);
  >       hits = [];
  >       check(`6653/${ext}`, "ignored effect count", () => m.erased_effect(), 0);
  >       check(`6653/${ext}`, "ignored effect exactly once", () => hits, [7]);
  >       check(`6653/${ext}`, "constructor", () => m.new_omitted().count, 0);
  >       check(`6653/${ext}`, "method", () => m.send_omitted({count: globalThis.auditCount}), 0);
  >     hits = [];
  >     assert.equal(m.effectful_unit(), 1);
  >     assert.deepEqual(hits, ["unit"]);
  >     assert.equal(m.generic_unit(), 1);
  >     assert.equal(m.literal_unit_array(), 1);
  >     assert.equal(m.dynamic_unit_array([undefined]), 1);
  >     assert.equal(m.dynamic_unit_array([]), 0);
  >     const assignment = {};
  >     m.assign_optional(assignment, undefined);
  >     assert.equal(Object.hasOwn(assignment, "value"), true);
  >     assert.equal(assignment.value, undefined);
  >     m.assign_optional(assignment, 7);
  >     assert.equal(assignment.value, 7);
  >     const someUndefined = {MEL_PRIVATE_NESTED_SOME_NONE:0};
  >     for (const fn of [m.dynamic_unit, m.dynamic_undefined]) {
  >       assert.equal(fn(undefined), 0);
  >       assert.equal(fn(someUndefined), 1);
  >     }
  >     assert.deepEqual(m.dynamic_capture(undefined, undefined), []);
  >     assert.deepEqual(m.dynamic_capture(7, undefined), [7]);
  >     assert.deepEqual(m.dynamic_capture(undefined, 8), [undefined, 8]);
  >     assert.deepEqual(m.dynamic_capture(someUndefined, undefined), [undefined]);
  >     assert.deepEqual(m.nested_none(), [undefined]);
  >     assert.equal(m.inserted_constant(), 1);
  >     assert.equal(m.expanded_variant(), 2);
  >     assert.equal(m.dynamic_construct(undefined).count, 0);
  >     assert.equal(m.dynamic_construct(7).count, 1);
  >     const receiver = { count: function() { assert.equal(this, receiver); return arguments.length; } };
  >     assert.equal(m.dynamic_send(receiver, undefined), 0);
  >     assert.equal(m.dynamic_send(receiver, 7), 1);
  >     assert.deepEqual(m.dynamic_variant(undefined), []);
  >     assert.deepEqual(m.dynamic_variant("A"), ["alpha"]);
  >     hits = [];
  >     assert.deepEqual(m.effectful_variant(), ["alpha"]);
  >     assert.deepEqual(hits, ["variant"]);
  >     hits = [];
  >     const getter = {get count() { hits.push("getter"); return globalThis.auditCount; }};
  >     assert.equal(m.effectful_send(getter), 0);
  >     assert.deepEqual(hits, ["getter", "option"]);
  >     console.log(ext, "controls: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  6653/js explicit_undefined 1
  6653/js explicit_unit 1
  6653/js erased_before 0
  6653/js erased_after 0
  6653/js erased_unit 0
  6653/js dynamic None 0
  6653/js ignored effect count 0
  js controls: ok
  6653/mjs explicit_undefined 1
  6653/mjs explicit_unit 1
  6653/mjs erased_before 0
  6653/mjs erased_after 0
  6653/mjs erased_unit 0
  6653/mjs dynamic None 0
  6653/mjs ignored effect count 0
  mjs controls: ok
