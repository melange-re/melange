Tagged switches may omit type dispatch only when constant values cannot match a block tag.

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
  > type t = A | B | C of int | D of int | E of int | F of int
  > let values = [|A; B; C 10; D 20; E 30; F 40|]
  > let ordinary = function C n -> n + 1 | D n -> n + 2 | _ -> 0
  > let assigned x = (match x with C n -> n + 1 | D n -> n + 2 | _ -> 0) + 5
  > let all_blocks = function
  >   | C n -> n + 1 | D n -> n + 2 | E n -> n + 3 | F n -> n + 4
  >   | _ -> 0
  > external select : unit -> t = "taggedSwitchSelect"
  > external fallback : unit -> int = "taggedSwitchFallback"
  > let effectful () = match select () with C n -> n + 1 | D n -> n + 2 | _ -> 0
  > let default_effect = function C n -> n + 1 | D n -> n + 2 | _ -> fallback ()
  > module Nullish = struct
  >   type t = A [@mel.as null] | B [@mel.as undefined] | C of int | D of int | E of int
  >   let values = [|A; B; C 10; D 20; E 30|]
  >   let f = function C n -> n + 1 | D n -> n + 2 | _ -> 0
  > end
  > module Undefined_tag = struct
  >   type t = A | B | C of int [@mel.as undefined] | D of int | E of int
  >   let values = [|A; B; C 10; D 20; E 30|]
  >   let f = function C n -> n + 1 | D n -> n + 2 | _ -> 0
  > end
  > module Custom_tag = struct
  >   type[@mel.tag "length"] t =
  >     | A [@mel.as "a"] | B [@mel.as "xx"] | C of int | D of int | E of int
  >   let values = [|A; B; C 10; D 20; E 30|]
  >   let f = function C n -> n + 1 | D n -> n + 2 | _ -> 0
  > end
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > (async () => {
  >   for (const [format,t] of [['CommonJS',require('./_build/default/out/input.js')],['ESM',await import('./_build/default/out/input.mjs')]]) {
  >     const expected = [0,0,11,22,0,0];
  >     assert.deepEqual(t.values.map(x=>t.ordinary(x)),expected);
  >     assert.deepEqual(t.values.map(x=>t.assigned(x)),expected.map(x=>x+5));
  >     assert.deepEqual(t.values.map(x=>t.all_blocks(x)),[0,0,11,22,33,44]);
  >     for (const m of [t.Nullish,t.Undefined_tag,t.Custom_tag]) {
  >       assert.deepEqual(m.values.map(x=>m.f(x)),[0,0,11,22,0]);
  >     }
  >     for (const [i,value] of t.values.entries()) {
  >       let calls = 0;
  >       global.taggedSwitchSelect = () => { ++calls; return value; };
  >       assert.equal(t.effectful(),expected[i]);
  >       assert.equal(calls,1);
  >       calls = 0;
  >       global.taggedSwitchFallback = () => { ++calls; return 99; };
  >       assert.equal(t.default_effect(value),expected[i] || 99);
  >       assert.equal(calls,expected[i] ? 0 : 1);
  >     }
  >     const sentinel = new Error('tagged switch');
  >     global.taggedSwitchSelect = global.taggedSwitchFallback = () => { throw sentinel; };
  >     assert.throws(()=>t.effectful(),e=>e===sentinel);
  >     assert.throws(()=>t.default_effect(t.values[0]),e=>e===sentinel);
  >     assert.equal(t.default_effect(t.values[2]),11);
  >     console.log(format + ' ordinary switch type guards: ' + (t.ordinary.toString().match(/typeof/g)||[]).length);
  >   }
  > })().catch(e=>{console.error(e);process.exitCode=1;});
  > EOF
  $ node check.cjs
  CommonJS ordinary switch type guards: 2
  ESM ordinary switch type guards: 2
