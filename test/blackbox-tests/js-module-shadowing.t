Local modules named Js resolve normally without compiler crashes.
ReScript #7007.

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
  > module Builtin = Js
  > module Js = struct let f () = 1 end
  > let value = Js.f ()
  > module Nested = struct
  >   module Js = struct let f x = x + 2 end
  >   let value = Js.f 3
  > end
  > let local () = let module Js = struct let f () = 7 end in Js.f ()
  > module Make (Js : sig val f : unit -> int end) = struct let value = Js.f () end
  > module Result = Make (Js)
  > let typ = Builtin.typeof value
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
  > assert.equal(m.value,1); assert.equal(m.Nested.value,5);
  > assert.equal(m.local(),7); assert.equal(m.Result.value,1);
  > assert.equal(m.typ,'number');
  >     console.log(ext, 'controls: ok');
  >   }
  > 
  > 
  > })().catch(e => { console.error(e); process.exitCode=1; });
  > EOF
  $ node check.cjs
  js controls: ok
  mjs controls: ok
