Inspecting a caught exception must not change the value that is rethrown.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.13)' '(using melange 0.1)' > dune-project
  $ echo '(melange.emit (target out) (emit_stdlib false) (libraries melange.js) (preprocess (pps melange.ppx)))' > dune
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
  > const returned = Symbol('did not throw');
  > function thrown(f) { try { f(); return returned; } catch (e) { return e; } }
  > for (const method of ['direct', 'unmatched', 'inspected', 'aliased', 'nested', 'captured']) {
  >   console.log(method, ...[new Error('identity'), {custom:true}, null, undefined, 7].map(value => {
  >     global.identityThrow = () => { throw value; };
  >     global.identityObserve = e => assert.equal(e._1, value);
  >     assert.equal(t.payload(), value);
  >     assert.throws(() => t.replacement(), e => e.MEL_EXN_ID === t.Known && e._1 === 99);
  >     return thrown(t[method]) === value;
  >   }));
  > }
  > global.identityThrow = () => { throw t.known; };
  > global.identityObserve = e => assert.equal(e, t.known);
  > console.log('known', ...['direct', 'inspected', 'aliased', 'captured'].map(name => thrown(t[name]) === t.known));
  > assert.doesNotThrow(t.unmatched);
  > EOF
  direct true true true true true
  unmatched true true true true true
  inspected true true true true true
  aliased true true true true true
  nested true true true true true
  captured true true true true true
  known true true true true
