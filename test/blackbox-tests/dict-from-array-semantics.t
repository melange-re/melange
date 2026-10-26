Dictionary construction preserves duplicate keys, prototypes, and effects.
ReScript #6538.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >       (target out)
  >       (libraries melange.js)
  >       (preprocess (pps melange.ppx))
  > 
  >       (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ cat > input.ml <<'EOF'
  > let simple () = Js.Dict.fromArray [| "a",1; "b",2 |]
  > let duplicate () = Js.Dict.fromArray [| "a",1; "a",2 |]
  > let dynamic xs = Js.Dict.fromArray xs
  > external next : int -> int = "auditNext"
  > let effects () = Js.Dict.fromArray [| "a",next 1; "a",next 2; "b",next 3 |]
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > const fs = require('node:fs');
  > globalThis.auditNext=x=>{ globalThis.auditEffects.push(x); return x; };
  > (async () => {
  >   for (const ext of ['js', 'mjs']) {
  >     const m = await import('./_build/default/out/input.'+ext);
  >     const code = fs.readFileSync('./_build/default/out/input.'+ext, 'utf8');
  > assert.deepEqual(m.simple(),{a:1,b:2});
  > assert.deepEqual(m.duplicate(),{a:2});
  > globalThis.auditEffects=[];
  > assert.deepEqual(m.effects(),{a:2,b:3});
  > assert.deepEqual(globalThis.auditEffects,[1,2,3]);
  > const proto={inherited:9}; const value=m.dynamic([['__proto__',proto],['own',4]]);
  > assert.equal(Object.getPrototypeOf(value),proto);
  > assert.equal(value.inherited,9);
  > assert.equal(Object.hasOwn(value,'__proto__'),false);
  > assert.deepEqual(Object.keys(value),['own']);
  >     console.log(ext, 'controls: ok');
  >   }
  > 
  > 
  > })().catch(e => { console.error(e); process.exitCode=1; });
  > EOF
  $ node check.cjs
  js controls: ok
  mjs controls: ok
