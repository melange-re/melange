ReScript #6653: cover ffi optional argument counts.
The printed cases characterize the current incorrect behavior.

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
  >     console.log(ext, "controls: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  6653/js explicit_undefined 0
  6653/js explicit_unit 0
  6653/js erased_before 1
  6653/js erased_after 1
  6653/js erased_unit 1
  6653/js dynamic None 1
  6653/js ignored effect count 1
  js controls: ok
  6653/mjs explicit_undefined 0
  6653/mjs explicit_unit 0
  6653/mjs erased_before 1
  6653/mjs erased_after 1
  6653/mjs erased_unit 1
  6653/mjs dynamic None 1
  6653/mjs ignored effect count 1
  mjs controls: ok
