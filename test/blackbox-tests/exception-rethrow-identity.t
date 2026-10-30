Inspecting a caught exception must not change the value that is rethrown.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > external throw : unit -> 'a = "identityThrow"
  > external observe : exn -> unit = "identityObserve"
  > external invoke : (unit -> unit) -> unit = "identityInvoke"
  > exception Known of int
  > let known = Known 42
  > let direct () = try throw () with e -> raise e
  > let unmatched () = try throw () with Known _ -> ()
  > let inspected () = try throw () with e -> observe e; raise e
  > let aliased () = try throw () with e -> let same = e in observe same; raise same
  > let nested () = try unmatched () with e -> observe e; raise e
  > let captured () = try throw () with e -> observe e; invoke (fun () -> raise e)
  > let replacement () = try throw () with _ -> raise (Known 99)
  > let payload () = try throw () with Js.Exn.Error err -> Obj.magic err
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > global.identityInvoke = f => f();
  > const t = require('./_build/default/out/input.js');
  > const values = [new Error('identity'), {custom:true}, null, undefined, 7];
  > const methods = ['direct','unmatched','inspected','aliased','nested','captured'];
  > const counts = methods.map(() => 0);
  > for (const value of values) {
  >   global.identityThrow = () => { throw value; };
  >   global.identityObserve = e => { assert.equal(e._1, value); };
  >   for (const [i,method] of methods.entries()) {
  >     let caught = false;
  >     try { t[method](); } catch(e) { caught = true; if(e === value) counts[i]++; }
  >     assert.equal(caught,true,method);
  >   }
  >   assert.equal(t.payload(),value);
  >   assert.throws(() => t.replacement(), e => e.MEL_EXN_ID === t.Known && e._1 === 99);
  > }
  > global.identityThrow = () => { throw t.known; };
  > global.identityObserve = e => { assert.equal(e,t.known); };
  > for (const method of ['direct','inspected','aliased','captured'])
  >   assert.throws(() => t[method](), e => e === t.known);
  > assert.doesNotThrow(() => t.unmatched());
  > console.log('CommonJS original values: ' + counts.join(','));
  > EOF
  CommonJS original values: 5,0,0,0,0,0
