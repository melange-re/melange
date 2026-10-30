Dictionary construction preserves duplicate keys, prototypes, and effects.
ReScript #6538.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > let simple () = Js.Dict.fromArray [| "a",1; "b",2 |]
  > let duplicate () = Js.Dict.fromArray [| "a",1; "a",2 |]
  > let dynamic xs = Js.Dict.fromArray xs
  > external next : int -> int = "auditNext"
  > let effects () = Js.Dict.fromArray [| "a",next 1; "a",next 2; "b",next 3 |]
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js'), effects = [];
  > globalThis.auditNext = x => { effects.push(x); return x; };
  > assert.deepEqual(m.simple(), {a:1,b:2});
  > assert.deepEqual(m.duplicate(), {a:2});
  > assert.deepEqual(m.effects(), {a:2,b:3});
  > assert.deepEqual(effects, [1,2,3]);
  > const proto = {inherited:9}, value = m.dynamic([['__proto__',proto],['own',4]]);
  > assert.equal(Object.getPrototypeOf(value), proto);
  > assert.equal(value.inherited, 9);
  > assert.equal(Object.hasOwn(value,'__proto__'), false);
  > assert.deepEqual(Object.keys(value), ['own']);
  > EOF
