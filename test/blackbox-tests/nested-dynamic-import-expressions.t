Dynamic imports remain lazy inside nested expressions.
ReScript #6431.

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
  $ cat > y.ml <<'EOF'
  > [%%raw "globalThis.auditImported = (globalThis.auditImported || 0) + 1;"]
  > let value = 11
  > EOF
  $ cat > z.ml <<'EOF'
  > [%%raw "globalThis.auditImported = (globalThis.auditImported || 0) + 1;"]
  > let value = 22
  > EOF
  $ cat > input.ml <<'EOF'
  > module type S = sig val value : int end
  > let nested flag =
  >   let p = if flag then Js.import Y.value else Js.import Z.value in p
  > let branch flag = if flag then Js.import (module Y : S) else Js.import (module Z : S)
  > let lambda () = [| fun () -> let p = Js.import Y.value in p |]
  > let local_type (type a) (_ : a) = let p = Js.import Z.value in p
  > let paired () = let x = Js.import Y.value and y = Js.import Z.value in x,y
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > const fs = require('node:fs');
  > 
  > (async () => {
  >   for (const ext of ['js', 'mjs']) {
  >     const m = await import('./_build/default/out/input.'+ext);
  >     const code = fs.readFileSync('./_build/default/out/input.'+ext, 'utf8');
  > assert.equal(globalThis.auditImported || 0,0);
  > assert.equal(await m.nested(true),11);
  > assert.equal(globalThis.auditImported,1);
  > assert.equal(await m.nested(false),22);
  > assert.equal(globalThis.auditImported,2);
  > assert.equal((await m.branch(true)).value,11);
  > assert.equal((await m.branch(false)).value,22);
  > assert.equal(await m.lambda()[0](),11);
  > assert.equal(await m.local_type('ignored'),22);
  > assert.deepEqual(await Promise.all(m.paired()),[11,22]);
  > assert.equal(globalThis.auditImported,2);
  > globalThis.auditImported=0;
  >     console.log(ext, 'controls: ok');
  >   }
  > 
  > 
  > })().catch(e => { console.error(e); process.exitCode=1; });
  > EOF
  $ node check.cjs
  js controls: ok
  mjs controls: ok
