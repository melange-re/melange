ReScript #7043: cover record copy representations.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > type r = { a:int; b:int; c:int; d:int; e:int; f:int; g:int; h:int; i:int; j:int; k:int }
  > let copy x = { x with b = 100 }
  > let dup x = Obj.dup x
  > let discard x = ignore { x with b = 100 }
  > type large = { f00:int; f01:int; f02:int; f03:int; f04:int; f05:int; f06:int; f07:int; f08:int; f09:int; f10:int; f11:int; f12:int; f13:int; f14:int; f15:int; f16:int; f17:int; f18:int; f19:int; f20:int }
  > let large_copy x = { x with f01 = 100 }
  > let large_discard x = ignore { x with f01 = 100 }
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js');
  > const record = Object.fromEntries('abcdefghijk'.split('').map((k,i) => [k,i]));
  > assert.deepEqual(m.copy(record), {...record,b:100});
  > assert.deepEqual(Object.keys(m.copy(record)), Object.keys(record));
  > const tuple = m.dup([1,2]);
  > assert.ok(Array.isArray(tuple));
  > assert.deepEqual(tuple, [1,2]);
  > const object = Object.assign(Object.create({inherited:7}), record), symbol = Symbol('x');
  > object[symbol] = 8;
  > const clone = m.dup(object);
  > assert.deepEqual([clone[symbol],Object.hasOwn(clone,'inherited'),Object.getPrototypeOf(clone) === Object.prototype], [8,false,true]);
  > let reads = 0;
  > const getter = {...record};
  > Object.defineProperty(getter, 'a', {enumerable:true, get() { reads++; return 7; }});
  > m.copy(getter);
  > assert.equal(reads, 1);
  > const large = Object.fromEntries(Array.from({length:21}, (_,i) => [`f${String(i).padStart(2,'0')}`,i]));
  > assert.deepEqual(m.large_copy(large), {...large,f01:100});
  > assert.deepEqual(Object.keys(m.large_copy(large)), Object.keys(large));
  > console.log('large copy uses runtime:', m.large_copy.toString().includes('caml_obj_dup'));
  > EOF
  large copy uses runtime: true
