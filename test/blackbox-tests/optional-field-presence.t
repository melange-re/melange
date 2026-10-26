ReScript #6485: cover optional field presence.

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
  > type object_
  > external make : ?x:'a -> unit -> object_ = "" [@@mel.obj]
  > let direct () = make ?x:None ()
  > let dynamic x = make ?x ()
  > let alias x = match x with Some v -> make ~x:v () | None as y -> make ?x:y ()
  > let from_result x = match x with Ok v -> make ?x:v () | Error _ -> make ()
  > let nested_none () = make ~x:None ()
  > let explicit_undefined () = make ~x:Js.undefined ()
  > type properties = { x : int option [@mel.optional] } [@@deriving jsProperties]
  > let derived_direct () = properties ()
  > let derived_dynamic x = properties ?x ()
  > let properties_literal () : properties = { x = None }
  > let properties_literal_dynamic x : properties = { x }
  > type ordinary = { y : int option }
  > let ordinary_direct () = { y = None }
  > let ordinary_dynamic y = { y }
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > 
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
  >       for (const [name, fn] of [["direct",()=>m.direct()],["dynamic",()=>m.dynamic(undefined)],["alias",()=>m.alias(undefined)],["result",()=>m.from_result({TAG:0,_0:undefined})],["derived direct",()=>m.derived_direct()],["derived dynamic",()=>m.derived_dynamic(undefined)]])
  >         check(`6485/${ext}`, name, () => Object.keys(fn()), []);
  >       check(`6485/${ext}`, "false payload is present", () => m.dynamic(false), {x:false});
  >       check(`6485/${ext}`, "zero payload is present", () => m.dynamic(0), {x:0});
  >       check(`6485/${ext}`, "Some None is present", () => Object.keys(m.nested_none()), ["x"]);
  >       check(`6485/${ext}`, "Some undefined is present", () => Object.keys(m.explicit_undefined()), ["x"]);
  >       check(`6485/${ext}`, "ordinary records retain fields", () => [m.ordinary_direct(), m.ordinary_dynamic(undefined)], [{y:undefined},{y:undefined}]);
  >       check(`6485/${ext}`, "ordinary construction of derived record retains fields", () => [m.properties_literal(),m.properties_literal_dynamic(undefined)], [{x:undefined},{x:undefined}]);
  >     console.log(ext, "controls: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js controls: ok
  mjs controls: ok
