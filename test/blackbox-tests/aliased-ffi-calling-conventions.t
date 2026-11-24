Distinguish curried function values from explicitly uncurried aliases.
ReScript #7002.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
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
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > globalThis.auditCurried = x => y => x*10+y;
  > globalThis.auditDefault = (x,y=9) => x*10+y;
  > globalThis.auditRest = (...args) => { assert.equal(args.length,2); return args[0]*10+args[1]; };
  > const m = require('./_build/default/out/input.js');
  > assert.equal(m.curried_value, globalThis.auditCurried);
  > assert.equal(m.aliased_value, globalThis.auditDefault);
  > assert.equal(m.call_curried(2,3), 23);
  > assert.equal(m.partial(2)(4), 24);
  > for (const call of [m.call_alias, m.call_inline, m.call_rest]) assert.equal(call(2,3), 23);
  > EOF
