ReScript #7134/#7141: cover typeof guards around boolean, string, and number literals.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
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
  > let literal_string x = string_type x && x == Obj.magic "abc"
  > let literal_number x = Js.typeof x = "number" && x == Obj.magic 123
  > external effect_call : int -> bool = "auditEffect"
  > let and_false () = effect_call 1 && false
  > let or_true () = effect_call 2 || true
  > let composed x = (effect_call 3 || bool_type x) && x == Obj.magic true
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js');
  > let hits = [];
  > globalThis.auditEffect = n => { hits.push(n); return n === 3; };
  > const inputs = [null,undefined,false,true,0,1,'','text',{},[]];
  > for (const name of ['null_eq_typeof', 'undefined_eq_typeof'])
  >   assert.deepEqual(inputs.map(m[name]), inputs.map(() => 4), name);
  > for (const name of ['null_neq_typeof', 'undefined_neq_typeof'])
  >   assert.deepEqual(inputs.map(m[name]), inputs.map(x => typeof x === 'boolean' ? 3 : 4), name);
  > assert.deepEqual(inputs.map(m.redundant_bool), inputs.map(x => x === true));
  > assert.deepEqual(inputs.map(m.contradictory), inputs.map(() => false));
  > const literals = [...inputs, 'abc', 123, NaN, Infinity, Symbol(), 123n];
  > assert.deepEqual(literals.map(m.literal_string), literals.map(x => x === 'abc'));
  > assert.deepEqual(literals.map(m.literal_number), literals.map(x => x === 123));
  > assert.deepEqual([m.and_false(), hits], [false,[1]]);
  > hits = [];
  > assert.deepEqual([m.or_true(), hits], [true,[2]]);
  > hits = [];
  > assert.deepEqual([m.composed(true), hits], [true,[3]]);
  > for (const name of ['redundant_bool', 'contradictory'])
  >   console.log(name, 'typeof guard:', m[name].toString().includes('typeof'));
  > EOF
  redundant_bool typeof guard: true
  contradictory typeof guard: true
