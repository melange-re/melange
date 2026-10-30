Pure boolean expressions should not keep otherwise unused array allocations alive.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > external predicate : int -> bool = "booleanPurityPredicate"
  > external value : int -> int = "booleanPurityValue"
  > let pure_not x = Array.length [|not x|]
  > let pure_cond p = Array.length [|if p then 11 else 22|]
  > let pure_nested p q = Array.length [|if p then not q else q|]
  > let ignored_not x = ignore (not x)
  > let effect_not () = Array.length [|not (predicate 1)|]
  > let effect_condition () = Array.length [|if predicate 1 then 11 else 22|]
  > let effect_then p = Array.length [|if p then value 2 else 22|]
  > let effect_else p = Array.length [|if p then 11 else value 3|]
  > let effect_nested p = Array.length [|if p then not (predicate 4) else false|]
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const t = require('./_build/default/out/input.js');
  > for (const p of [false,true]) for (const q of [false,true]) {
  >   assert.equal(t.pure_not(p),1);
  >   assert.equal(t.pure_cond(p),1);
  >   assert.equal(t.pure_nested(p,q),1);
  >   assert.equal(t.ignored_not(p),undefined);
  > }
  > const cases = [['effect_not',[],[1]],['effect_condition',[],[1]],['effect_then',[true],[2]],['effect_then',[false],[]],['effect_else',[true],[]],['effect_else',[false],[3]],['effect_nested',[true],[4]],['effect_nested',[false],[]]];
  > for (const [name,args,expected] of cases) {
  >   const events = [];
  >   global.booleanPurityPredicate = n => { events.push(n); return true; };
  >   global.booleanPurityValue = n => { events.push(n); return n; };
  >   assert.equal(t[name](...args),1);
  >   assert.deepEqual(events,expected);
  >   const sentinel = new Error(name);
  >   global.booleanPurityPredicate = global.booleanPurityValue = () => { throw sentinel; };
  >   if (expected.length) assert.throws(()=>t[name](...args),e=>e===sentinel);
  >   else assert.equal(t[name](...args),1);
  > }
  > const retained = ['pure_not','pure_cond','pure_nested'].filter(n=>t[n].toString().includes('.length')).length;
  > console.log('CommonJS retained pure allocations: ' + retained);
  > console.log('CommonJS retained ignored negation: ' + t.ignored_not.toString().includes('!'));
  > EOF
  CommonJS retained pure allocations: 3
  CommonJS retained ignored negation: true
