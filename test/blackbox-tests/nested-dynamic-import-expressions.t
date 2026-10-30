Dynamic imports remain lazy inside nested expressions.
ReScript #6431.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx))
  >  (module_systems (commonjs js) (es6 mjs)))
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
  $ node --input-type=module <<'EOF'
  > import assert from 'node:assert/strict';
  > for (const ext of ['js', 'mjs']) {
  >   globalThis.auditImported = 0;
  >   const m = await import('./_build/default/out/input.' + ext);
  >   assert.equal(globalThis.auditImported, 0);
  >   assert.equal(await m.nested(true), 11);
  >   assert.equal(globalThis.auditImported, 1);
  >   assert.equal(await m.nested(false), 22);
  >   assert.equal(globalThis.auditImported, 2);
  >   assert.equal((await m.branch(true)).value, 11);
  >   assert.equal((await m.branch(false)).value, 22);
  >   assert.equal(await m.lambda()[0](), 11);
  >   assert.equal(await m.local_type('ignored'), 22);
  >   assert.deepEqual(await Promise.all(m.paired()), [11,22]);
  >   assert.equal(globalThis.auditImported, 2);
  > }
  > EOF
