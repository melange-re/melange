ReScript #7134: cover typeof guard simplification.

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
  > let bool_type x = Js.typeof x = "boolean"
  > let string_type x = Js.typeof x = "string"
  > let null_eq_typeof x = if bool_type x && x == Obj.magic Js.null then 3 else 4
  > let null_neq_typeof x = if bool_type x && x != Obj.magic Js.null then 3 else 4
  > let undefined_eq_typeof x = if bool_type x && x == Obj.magic Js.undefined then 3 else 4
  > let undefined_neq_typeof x = if bool_type x && x != Obj.magic Js.undefined then 3 else 4
  > let redundant_bool x = bool_type x && x == Obj.magic true
  > let contradictory x = string_type x && x == Obj.magic true
  > external effect_call : int -> bool = "auditEffect"
  > let and_false () = effect_call 1 && false
  > let or_true () = effect_call 2 || true
  > let composed x = (effect_call 3 || bool_type x) && x == Obj.magic true
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > let hits = [];
  > globalThis.auditEffect = n => { hits.push(n); return n === 3; };
  > 
  > const characterized = new Set([]);
  > function check(group, name, run, expected) {
  >   const actual = run();
  >   if (characterized.has(name)) console.log(group, name, JSON.stringify(actual));
  >   else assert.deepStrictEqual(actual, expected, name);
  > }
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const m = await import("./_build/default/out/input." + ext);
  >       const inputs=[null,undefined,false,true,0,1,"", "text", {}, []];
  >       for(const name of ["null_eq_typeof", "undefined_eq_typeof"])
  >         check(`7134/${ext}`, name, () => inputs.map(m[name]), inputs.map(()=>4));
  >       for(const name of ["null_neq_typeof", "undefined_neq_typeof"])
  >         check(`7134/${ext}`, name, () => inputs.map(m[name]), inputs.map(x=>typeof x==="boolean"?3:4));
  >       check(`7134/${ext}`, "redundant boolean guard", () => inputs.map(m.redundant_bool), inputs.map(x=>x===true));
  >       check(`7134/${ext}`, "contradictory guard", () => inputs.map(m.contradictory), inputs.map(()=>false));
  >       hits=[]; check(`7134/${ext}`, "and false keeps effect", () => [m.and_false(),hits], [false,[1]]);
  >       hits=[]; check(`7134/${ext}`, "or true keeps effect", () => [m.or_true(),hits], [true,[2]]);
  >       hits=[]; check(`7134/${ext}`, "compound keeps effect", () => [m.composed(true),hits], [true,[3]]);
  >     const js = require("node:fs").readFileSync("./_build/default/out/input." + ext, "utf8");
  >     for (const name of ["redundant_bool", "contradictory"]) {
  >       const fn = js.slice(js.indexOf("function " + name + "("));
  >       console.log(ext, name, "typeof guard:", fn.slice(0, fn.indexOf("\n}")).includes("typeof"));
  >     }
  >     console.log(ext, "controls: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js redundant_bool typeof guard: true
  js contradictory typeof guard: true
  js controls: ok
  mjs redundant_bool typeof guard: true
  mjs contradictory typeof guard: true
  mjs controls: ok
