Unused fresh record copies can discard their field writes while preserving effects.
Cover both sides of the frontend copy threshold; the initial snapshot retains large copies.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.8)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit (target output) (alias melange))
  > EOF
  $ cat > input.ml <<'EOF'
  > module R19 = struct
  >   type t = { mutable f0 : int; f1 : int; f2 : int; f3 : int; f4 : int; f5 : int; f6 : int; f7 : int; f8 : int; f9 : int; f10 : int; f11 : int; f12 : int; f13 : int; f14 : int; f15 : int; f16 : int; f17 : int; f18 : int }
  >   let unused r = let _ = {r with f0 = 1} in r.f0
  >   let used r = {r with f0 = 1}
  >   let effects base update = let _ = {(base ()) with f0 = update 1; f1 = update 2} in ()
  >   let escaped r use = let copy = {r with f0 = 1} in use copy; copy.f0
  > end
  > module R20 = struct
  >   type t = { mutable f0 : int; f1 : int; f2 : int; f3 : int; f4 : int; f5 : int; f6 : int; f7 : int; f8 : int; f9 : int; f10 : int; f11 : int; f12 : int; f13 : int; f14 : int; f15 : int; f16 : int; f17 : int; f18 : int; f19 : int }
  >   let unused r = let _ = {r with f0 = 1} in r.f0
  >   let used r = {r with f0 = 1}
  >   let effects base update = let _ = {(base ()) with f0 = update 1; f1 = update 2} in ()
  >   let escaped r use = let copy = {r with f0 = 1} in use copy; copy.f0
  > end
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const t = require('./_build/default/output/input.js');
  > for (const n of [19,20]) {
  >   const r = Object.fromEntries(Array.from({length:n},(_,i)=>['f'+i,i+10]));
  >   const m = t['R'+n];
  >   assert.equal(m.unused(r),10);
  >   const copy = m.used(r);
  >   assert.notEqual(copy,r);
  >   assert.equal(copy.f0,1);
  >   assert.equal(copy.f1,11);
  >   assert.equal(r.f0,10);
  >   assert.equal(m.escaped(r,c=>{c.f0=9;}),9);
  >   let events = [];
  >   m.effects(()=>{events.push('base');return r;},i=>{events.push('update'+i);return i;});
  >   const order = events.join(',');
  >   events = [];
  >   const thrown = new Error('update failed');
  >   assert.throws(()=>m.effects(()=>{events.push('base');return r;},i=>{events.push('update'+i);throw thrown;}),e=>e===thrown);
  >   assert.deepEqual(events, ['base', n === 19 ? 'update1' : 'update2']);
  >   assert.equal(r.f0,10);
  >   console.log(n, 'unused clone:', /caml_obj_dup/.test(m.unused.toString()), 'effects:', order);
  > }
  > EOF
  19 unused clone: false effects: base,update1,update2
  20 unused clone: true effects: base,update2,update1
