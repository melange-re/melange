Distinguish curried function values from explicitly uncurried aliases.
ReScript #7002.

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
  > type curried = int -> int -> int
  > type binary = (int -> int -> int [@u])
  > external curried : curried = "auditCurried"
  > external aliased : binary = "auditDefault"
  > external inline : int -> int -> int = "auditDefault"
  > external rest : binary = "auditRest"
  > let curried_value = curried
  > let aliased_value = aliased
  > let call_curried x y = curried x y
  > let partial x = curried x
  > let call_alias x y = (aliased x y [@u])
  > let call_inline x y = inline x y
  > let call_rest x y = (rest x y [@u])
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > const fs = require('node:fs');
  > globalThis.auditCurried = x => y => x*10+y;
  > globalThis.auditDefault = (x,y=9) => x*10+y;
  > globalThis.auditRest = (...args) => { assert.equal(args.length,2); return args[0]*10+args[1]; };
  > (async () => {
  >   for (const ext of ['js', 'mjs']) {
  >     const m = await import('./_build/default/out/input.'+ext);
  >     const code = fs.readFileSync('./_build/default/out/input.'+ext, 'utf8');
  > assert.equal(m.curried_value, globalThis.auditCurried);
  > assert.equal(m.aliased_value, globalThis.auditDefault);
  > assert.equal(m.call_curried(2,3),23);
  > assert.equal(m.partial(2)(4),24);
  > assert.equal(m.call_alias(2,3),23);
  > assert.equal(m.call_inline(2,3),23);
  > assert.equal(m.call_rest(2,3),23);
  > assert.match(code,/Curry\./);
  >     console.log(ext, 'controls: ok');
  >   }
  > 
  > 
  > })().catch(e => { console.error(e); process.exitCode=1; });
  > EOF
  $ node check.cjs
  js controls: ok
  mjs controls: ok
