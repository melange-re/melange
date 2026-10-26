Option record fields with constant payloads should not need redundant None checks.

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
  > type record = { x : int option; y : string option; z : bool option }
  > let fields = function { x = Some 1; y = Some "hi"; _ } -> 1 | _ -> 0
  > let booleans = function { x = Some 1; z = Some false; _ } -> 1 | _ -> 0
  > type nested_record = { nested : int option option; other : int option }
  > let nested = function
  >   | { nested = Some None; other = Some 1 } -> 1
  >   | { nested = Some (Some 2); other = Some 1 } -> 2
  >   | _ -> 0
  > let nested_cases () =
  >   List.map nested
  >     [ { nested = None; other = Some 1 };
  >       { nested = Some None; other = Some 1 };
  >       { nested = Some (Some 2); other = Some 1 };
  >       { nested = Some (Some 3); other = Some 1 };
  >       { nested = Some None; other = None } ]
  > external make_record : unit -> record = "optionalFieldsRecord"
  > external guard : unit -> bool = "optionalFieldsGuard"
  > external hit : int -> unit = "optionalFieldsHit"
  > let effectful () = fields (make_record ())
  > let guarded = function
  >   | { x = Some 1; y = Some "hi"; _ } when guard () -> 1
  >   | _ -> 0
  > let falling_through r =
  >   (match r with
  >   | { x = Some 1; y = Some "hi"; _ } -> hit 1
  >   | _ -> hit 2);
  >   hit 3
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > (async () => {
  >   for (const [format,t] of [['CommonJS',require('./_build/default/out/input.js')],['ESM',await import('./_build/default/out/input.mjs')]]) {
  >     for (const x of [undefined,0,1,2]) for (const y of [undefined,"","hi","other"]) for (const z of [undefined,false,true]) {
  >       const r = {x,y,z};
  >       assert.equal(t.fields(r), +(x===1 && y==="hi"));
  >       assert.equal(t.booleans(r), +(x===1 && z===false));
  >       for (const answer of [false,true]) {
  >         let calls = 0;
  >         global.optionalFieldsGuard = () => { ++calls; return answer; };
  >         assert.equal(t.guarded(r), +(x===1 && y==="hi" && answer));
  >         assert.equal(calls, +(x===1 && y==="hi"));
  >       }
  >       const events = [];
  >       global.optionalFieldsHit = n => {events.push(n);};
  >       t.falling_through(r);
  >       assert.deepEqual(events,[x===1 && y==="hi" ? 1 : 2,3]);
  >     }
  >     const list = t.nested_cases();
  >     const nested = [];
  >     for (let cell=list; cell; cell=cell.tl) nested.push(cell.hd);
  >     assert.deepEqual(nested,[0,1,2,0,0]);
  >     let calls = 0;
  >     global.optionalFieldsRecord = () => { ++calls; return {x:1,y:"hi"}; };
  >     assert.equal(t.effectful(),1);
  >     assert.equal(calls,1);
  >     const sentinel = new Error('optional field effects');
  >     global.optionalFieldsRecord = global.optionalFieldsGuard = () => { throw sentinel; };
  >     assert.throws(()=>t.effectful(),e=>e===sentinel);
  >     assert.throws(()=>t.guarded({x:1,y:"hi"}),e=>e===sentinel);
  >     assert.equal(t.guarded({x:undefined,y:"hi"}),0);
  >     console.log(format + ' redundant undefined checks: ' + (t.fields.toString().match(/=== undefined/g)||[]).length);
  >   }
  > })().catch(e=>{console.error(e);process.exitCode=1;});
  > EOF
  $ node check.cjs
  CommonJS redundant undefined checks: 1
  ESM redundant undefined checks: 1
