Physical comparisons of float constants should fold using their numeric values.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > external read : unit -> float = "floatFoldingRead"
  > let equal_same () = 1. == 1.
  > let unequal_same () = 1. != 1.
  > let equal_different () = 1. == 2.
  > let unequal_different () = 1. != 2.
  > let equal_signed_zero () = 0. == -0.
  > let unequal_signed_zero () = 0. != -0.
  > let equal_spellings () = 1. == 0x1p0
  > let unequal_spellings () = 1. != 0x1p0
  > let equal_infinities () = 1e309 == 1e309
  > let unequal_infinities () = 1e309 != -1e309
  > let unequal_subnormal () = 0x1p-1074 != 0.
  > let dynamic (x:float) (y:float) = x != y
  > let dynamic_equal (x:float) (y:float) = x == y
  > let effectful () = read () != 1.
  > let original = [|1. = 1.; 1. == 1.; 1. <> 1.; 1. != 1.;
  >                   1. >= 1.; 1. > 1.; 1. <= 1.; 1. < 1.|]
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const t = require('./_build/default/out/input.js');
  > const cases = [['equal_same',true],['unequal_same',false],['equal_different',false],['unequal_different',true],['equal_signed_zero',true],['unequal_signed_zero',false],['equal_spellings',true],['unequal_spellings',false],['equal_infinities',true],['unequal_infinities',true],['unequal_subnormal',true]];
  > let comparisons = 0;
  > for (const [name,value] of cases) {
  >   assert.equal(t[name](),value,name);
  >   if (/===|!==/.test(t[name].toString())) comparisons++;
  > }
  > const values = [NaN,Infinity,-Infinity,-0,0,Number.MIN_VALUE,1,2];
  > for (const a of values) for (const b of values) {
  >   assert.equal(t.dynamic(a,b),a!==b);
  >   assert.equal(t.dynamic_equal(a,b),a===b);
  > }
  > let reads = 0;
  > global.floatFoldingRead = () => { reads++; return NaN; };
  > assert.equal(t.effectful(),true);
  > assert.equal(reads,1);
  > const error = new Error('comparison');
  > global.floatFoldingRead = () => { throw error; };
  > assert.throws(()=>t.effectful(),e=>e===error);
  > assert.deepEqual(t.original,[true,true,false,false,true,false,true,false]);
  > console.log('CommonJS remaining constant comparisons: ' + comparisons);
  > EOF
  CommonJS remaining constant comparisons: 9
