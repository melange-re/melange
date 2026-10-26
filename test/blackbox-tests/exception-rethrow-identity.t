Inspecting a caught exception must not change the value that is rethrown.

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
  > external throw : unit -> 'a = "identityThrow"
  > external observe : exn -> unit = "identityObserve"
  > exception Known of int
  > let known = Known 42
  > let direct () = try throw () with e -> raise e
  > let unmatched () = try throw () with Known _ -> ()
  > let inspected () = try throw () with e -> observe e; raise e
  > let aliased () = try throw () with e -> let same = e in observe same; raise same
  > let nested () = try unmatched () with e -> observe e; raise e
  > let captured () = try throw () with e -> observe e; (fun () -> raise e) ()
  > let replacement () = try throw () with _ -> raise (Known 99)
  > let payload () = try throw () with Js.Exn.Error err -> Obj.magic err
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > (async () => {
  >   for (const [format,t] of [['CommonJS',require('./_build/default/out/input.js')], ['ESM',await import('./_build/default/out/input.mjs')]]) {
  >     const values = [new Error('identity'), {custom:true}, null, undefined, 7];
  >     const methods = ['direct','unmatched','inspected','aliased','nested','captured'];
  >     const counts = methods.map(() => 0);
  >     for (const value of values) {
  >       global.identityThrow = () => { throw value; };
  >       global.identityObserve = e => { assert.equal(e._1, value); };
  >       for (const [i,method] of methods.entries()) {
  >         let caught = false;
  >         try { t[method](); } catch(e) { caught = true; if(e === value) counts[i]++; }
  >         assert.equal(caught,true,method);
  >       }
  >       assert.equal(t.payload(),value);
  >       assert.throws(() => t.replacement(), e => e.MEL_EXN_ID === t.Known && e._1 === 99);
  >     }
  >     global.identityThrow = () => { throw t.known; };
  >     global.identityObserve = e => { assert.equal(e,t.known); };
  >     for (const method of ['direct','inspected','aliased','captured'])
  >       assert.throws(() => t[method](), e => e === t.known);
  >     assert.doesNotThrow(() => t.unmatched());
  >     console.log(format + ' original values: ' + counts.join(','));
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  CommonJS original values: 5,5,5,5,5,5
  ESM original values: 5,5,5,5,5,5
